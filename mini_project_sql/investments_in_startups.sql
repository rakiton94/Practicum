--1. Отобразим все записи из таблицы company по компаниям, которые закрылись.
SELECT *
FROM company
WHERE status='closed'

--2. Отобразим количество привлечённых средств для новостных компаний США. Используем данные из таблицы company. Отсортируем таблицу по убыванию значений в поле funding_total.
SELECT funding_total
FROM company
WHERE country_code='USA' AND category_code='news'
ORDER BY funding_total DESC
  
--3. Найдем общую сумму сделок по покупке одних компаний другими в долларах. Отберем сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code='cash' AND EXTRACT(YEAR FROM CAST(acquired_at as date)) BETWEEN '2011' AND '2013'

--4. Отобразим имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.
SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%'

--5. Выведем на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.
SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%'

--6. Для каждой страны отобразим общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируем данные по убыванию суммы.
SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC

--7. Составим таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату. Оставим в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount)!=0 AND MIN(raised_amount)!=MAX(raised_amount)

--8. Создадим поле с категориями:
--  - Для фондов, которые инвестируют в 100 и более компаний, назначим категорию high_activity.
--  - Для фондов, которые инвестируют в 20 и более компаний до 100, назначим категорию middle_activity.
--  - Если количество инвестируемых компаний фонда не достигает 20, назначим категорию low_activity.
--  Отобразим все поля таблицы fund и новое поле с категориями.
SELECT *,
       CASE 
           WHEN invested_companies>=100 THEN 'high_activity' 
           WHEN invested_companies<20 THEN 'low_activity'
           ELSE 'middle_activity'        
       END
FROM fund

--9. Для каждой из категорий, назначенных в предыдущем пункте, посчитаем округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведем на экран категории и среднее число инвестиционных раундов. Отсортируем таблицу по возрастанию среднего.
SELECT
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds))
FROM fund
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds))

--10. Проанализируем, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы.  Для каждой страны посчитаем минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключим страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю.  Выгрузим десять самых активных стран-инвесторов: отсортируем таблицу по среднему количеству компаний от большего к меньшему. Затем добавим сортировку по коду страны в лексикографическом порядке.
SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) BETWEEN '2010' AND '2012'
GROUP BY country_code
HAVING MIN(invested_companies)!=0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10

--11. Отобразим имя и фамилию всех сотрудников стартапов. Добавим поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p LEFT JOIN education AS e ON p.id=e.person_id

--12. Для каждой компании найдем количество учебных заведений, которые окончили её сотрудники. Выведем название компании и число уникальных названий учебных заведений. Составим топ-5 компаний по количеству университетов.
SELECT name,
       COUNT(DISTINCT instituition)
FROM company AS c JOIN (SELECT p.company_id,
                               e.instituition
                        FROM people AS p LEFT JOIN education AS e ON p.id=e.person_id) AS e ON c.id=e.company_id
GROUP BY name
ORDER BY COUNT(DISTINCT instituition) DESC
LIMIT 5

--13. Составим список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
SELECT DISTINCT name
FROM company
WHERE status='closed' AND id IN (SELECT company_id
                                 FROM funding_round
                                 WHERE is_first_round=1 AND is_last_round=1)

--14. Составим список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
SELECT DISTINCT id
FROM people
WHERE company_id IN (SELECT DISTINCT id
                     FROM company
                     WHERE status='closed' AND id IN (SELECT company_id
                                                      FROM funding_round
                                                      WHERE is_first_round=1 AND is_last_round=1))

--15. Составим таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
WITH 
p AS (SELECT DISTINCT id
      FROM people
      WHERE company_id IN (SELECT DISTINCT id
                           FROM company
                           WHERE status='closed' AND id IN (SELECT company_id
                                                            FROM funding_round
                                                            WHERE is_first_round=1 AND is_last_round=1)))
SELECT DISTINCT p.id,
       instituition
FROM education AS e JOIN p ON e.person_id=p.id

--16. Посчитаем количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учтем, что некоторые сотрудники могли окончить одно и то же заведение дважды.
WITH 
p AS (SELECT DISTINCT id
      FROM people
      WHERE company_id IN (SELECT DISTINCT id
                           FROM company
                           WHERE status='closed' AND id IN (SELECT company_id
                                                            FROM funding_round
                                                            WHERE is_first_round=1 AND is_last_round=1)))
SELECT DISTINCT e.person_id,
       COUNT(instituition)
FROM education AS e JOIN p ON e.person_id=p.id
GROUP BY person_id

--17. Дополним предыдущий запрос и выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний.
WITH 
p AS (SELECT DISTINCT e.person_id,
             COUNT(instituition)
      FROM education AS e JOIN (SELECT DISTINCT id
                                FROM people
                                WHERE company_id IN (SELECT DISTINCT id
                                                     FROM company
                                                     WHERE status='closed' AND id IN
                                                    (SELECT company_id
                                                     FROM funding_round
                                                     WHERE is_first_round=1 AND is_last_round=1)))
                                                     AS p ON e.person_id=p.id
       GROUP BY person_id)
SELECT AVG(count)
FROM p

--18. Выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.
SELECT AVG(count)
FROM (SELECT person_id,
             COUNT(instituition)
      FROM education
      WHERE person_id IN (SELECT id
                          FROM people 
                          WHERE company_id IN (SELECT id
                                               FROM company
                                               WHERE name LIKE 'Facebook'))
      GROUP BY person_id) AS e 

--19. Составим таблицу из полей:
--*name_of_fund — название фонда;
--*name_of_company — название компании;
--*amount — сумма инвестиций, которую привлекла компания в раунде.
--В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
WITH
i AS (SELECT fund_id, company_id, funding_round_id
      FROM investment),
c AS (SELECT id, name
      FROM company
      WHERE milestones>6),
f AS (SELECT id, name
      FROM fund),
fr AS (SELECT id, company_id, raised_amount
       FROM funding_round
       WHERE EXTRACT(YEAR FROM CAST(funded_at as date)) BETWEEN '2012' AND '2013')
SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM i RIGHT JOIN c ON i.company_id=c.id INNER JOIN f ON i.fund_id=f.id INNER JOIN fr ON i.funding_round_id=fr.id

--20. Выгрузим таблицу, в которой будут такие поля:
-- - название компании-покупателя;
-- - сумма сделки;
-- - название компании, которую купили;
-- - сумма инвестиций, вложенных в купленную компанию;
-- - доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
--  Не будем учитыватьте сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключим такую компанию из таблицы.
--  Отсортируем таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничим таблицу первыми десятью записями.
WITH
a AS (SELECT ac.id, 
             co.name AS acquiring_company_name,
             ac.price_amount      
      FROM acquisition AS ac LEFT JOIN company AS co ON ac.acquiring_company_id=co.id
      WHERE price_amount!=0),
b AS (SELECT ac.id, 
             co.name AS acquired_company_name,
             co.funding_total       
      FROM acquisition AS ac LEFT JOIN company AS co ON ac.acquired_company_id=co.id
      WHERE funding_total!=0)
SELECT acquiring_company_name,
       price_amount,
       acquired_company_name,
       funding_total,
       ROUND(price_amount/funding_total)
FROM a JOIN b ON a.id=b.id
ORDER BY price_amount DESC, acquired_company_name
LIMIT 10


--21. Выгрузим таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверим, что сумма инвестиций не равна нулю. Выведем также номер месяца, в котором проходил раунд финансирования.
WITH
a AS (SELECT id, name      
      FROM company
      WHERE category_code='social'),
b AS (SELECT company_id, 
             EXTRACT(MONTH FROM CAST(funded_at as date)) as month      
      FROM funding_round
      WHERE EXTRACT(YEAR FROM CAST(funded_at as date)) BETWEEN '2010' AND '2013'
      AND raised_amount !=0)
SELECT a.name,
       b.month
FROM a JOIN b ON a.id=b.company_id

--22. Отберем данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируем данные по номеру месяца и получим таблицу, в которой будут поля:
--  - номер месяца, в котором проходили раунды;
--  - количество уникальных названий фондов из США, которые инвестировали в этом месяце; 
--  - количество компаний, купленных за этот месяц; 
--  - общая сумма сделок по покупкам в этом месяце.
WITH
a AS (SELECT fr.month,
             COUNT(DISTINCT f.name) AS fund_name_USA_count
      FROM investment AS i JOIN (SELECT id, EXTRACT(MONTH FROM CAST(funded_at as date)) AS month
                                       FROM funding_round
                                       WHERE EXTRACT(YEAR FROM CAST(funded_at as date)) BETWEEN '2010' AND '2013') AS fr
                                       ON i.funding_round_id=fr.id JOIN (SELECT id, name  
                                                                         FROM fund
                                                                         WHERE country_code='USA') AS f
                                                                         ON i.fund_id=f.id
     GROUP BY month),
b AS (SELECT EXTRACT(MONTH FROM CAST(acquired_at as date)) as month, 
             COUNT(acquired_company_id) AS acquired_company_count,
             SUM(price_amount) AS common_price_amount
      FROM acquisition
      WHERE EXTRACT(YEAR FROM CAST(acquired_at as date)) BETWEEN '2010' AND '2013'
      GROUP BY month)
SELECT a.month,
       a.fund_name_USA_count,
       b.acquired_company_count,
       b.common_price_amount
FROM a INNER JOIN b ON a.month=b.month

--23. Составим сводную таблицу и выведем среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год будут в отдельном поле. Отсортируем таблицу по среднему значению инвестиций за 2011 год от большего к меньшему. 
WITH
     inv_2011 AS (SELECT country_code,
                         AVG(funding_total) AS inv_2011_avg
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) = '2011'  -- сформируйте первую временную таблицу
                  GROUP BY country_code),
     inv_2012 AS (SELECT country_code,
                         AVG(funding_total) AS inv_2012_avg
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) = '2012'  -- сформируйте первую временную таблицу
                  GROUP BY country_code),
     inv_2013 AS (SELECT country_code,
                         AVG(funding_total) AS inv_2013_avg
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) = '2013'  -- сформируйте первую временную таблицу
                  GROUP BY country_code)      
SELECT inv_2011.country_code,
       inv_2011.inv_2011_avg,
       inv_2012.inv_2012_avg,
       inv_2013.inv_2013_avg-- отобразите нужные поля
FROM inv_2011 INNER JOIN inv_2012 ON inv_2011.country_code=inv_2012.country_code INNER JOIN inv_2013 ON inv_2011.country_code=inv_2013.country_code
ORDER BY inv_2011_avg DESC
