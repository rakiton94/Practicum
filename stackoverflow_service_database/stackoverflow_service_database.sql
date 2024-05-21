--1. Найдем количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки».
SELECT COUNT(*)
FROM stackoverflow.posts AS p
WHERE post_type_id='1' AND score>300 OR favorites_count>=100

--2. Среднее количество вопросов в день, которые задавали  с 1 по 18 ноября 2008 включительно. Результат округлим до целого числа.
WITH q AS (SELECT DISTINCT DATE_TRUNC('day', creation_date)::date AS date,
                  COUNT(*) OVER (PARTITION BY DATE_TRUNC('day', creation_date)) AS question_per_day
           FROM stackoverflow.posts
           WHERE post_type_id='1' AND creation_date BETWEEN '2008-11-01' AND '2008-11-19')
SELECT ROUND(AVG(question_per_day))
FROM q

--3. Количество уникальных пользователей, получивших значки сразу в день регистрации.
WITH a AS (SELECT u.id,
                  u.creation_date::date,
                  b.creation_date::date AS badges_date 
           FROM stackoverflow.users AS u
           JOIN stackoverflow.badges AS b ON b.user_id=u.id)
SELECT COUNT(DISTINCT id)
FROM a
WHERE badges_date=creation_date

--4. Количество уникальных постов пользователя с именем Joel Coehoorn, которые получили хотя бы один голос.
WITH a AS (SELECT id
           FROM stackoverflow.users
           WHERE display_name='Joel Coehoorn'),
     b AS (SELECT p.id
           FROM stackoverflow.posts AS p 
           JOIN a ON a.id=p.user_id)
SELECT COUNT(DISTINCT post_id)
FROM stackoverflow.votes AS v
JOIN b ON b.id=v.post_id

--5. Выгрузим все поля таблицы vote_types. Добавим к таблице поле rank, в которое войдут номера записей в обратном порядке. Таблицу отсортируем по полю id.
SELECT *,
       RANK() OVER(ORDER BY id DESC)
FROM stackoverflow.vote_types
ORDER BY id

--6. Отберем 10 пользователей, которые поставили больше всего голосов типа Close. Отобразим таблицу из двух полей: идентификатором пользователя и количеством голосов.
--Отсортируем данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя.
WITH vt AS (SELECT id
            FROM stackoverflow.vote_types
            WHERE name='Close'),
     u AS (SELECT DISTINCT user_id, 
                  COUNT(v.id) OVER(PARTITION BY user_id) 
           FROM stackoverflow.votes AS v
           JOIN vt ON vt.id=v.vote_type_id)
SELECT *
FROM u
ORDER BY count DESC, user_id DESC
LIMIT 10

--7. Отберем 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно. Отобразим несколько полей:
-- - идентификатор пользователя;
-- - число значков;
-- - место в рейтинге — чем больше значков, тем выше рейтинг.
--Пользователям, которые набрали одинаковое количество значков, присвоим одно и то же место в рейтинге. Отсортируем записи по количеству значков по убыванию,
--а затем по возрастанию значения идентификатора пользователя.
SELECT user_id,
       COUNT(id) AS cnt_badges,
       DENSE_RANK() OVER(ORDER BY COUNT(id) DESC)
FROM stackoverflow.badges
WHERE DATE_TRUNC('day', creation_date) BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY user_id
ORDER BY cnt_badges DESC, user_id
LIMIT 10

--8. Сформируем таблицу из следующих полей:
-- - заголовок поста;
-- - идентификатор пользователя;
-- - число очков поста;
-- - среднее число очков пользователя за пост, округлённое до целого числа.
--Не учитываем посты без заголовка, а также те, что набрали ноль очков.
SELECT title, user_id, score,
       ROUND(AVG(score) OVER(PARTITION BY user_id))
FROM stackoverflow.posts
WHERE score!=0 AND title!='NULL'

--9. Отобразим заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список.
WITH a AS (SELECT user_id,
                  COUNT(id) AS cnt_badges
           FROM stackoverflow.badges
           GROUP BY user_id),
     b AS (SELECT *
           FROM a
           WHERE cnt_badges>1000)
SELECT title
FROM stackoverflow.posts AS p
JOIN b ON b.user_id=p.user_id
WHERE title!='NULL'

--10. Напишем запрос, который выгрузит данные о пользователях из Канады (англ. Canada). Разделим пользователей на три группы в зависимости от количества просмотров их профилей:
-- - пользователям с числом просмотров больше либо равным 350 присвоим группу 1;
-- - пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
-- - пользователям с числом просмотров меньше 100 — группу 3.
--Отобразим в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу.
--Пользователи с количеством просмотров меньше либо равным нулю не должны войти в итоговую таблицу.
SELECT id, views,
       CASE
           WHEN views < 100  THEN 3
           WHEN views >= 100 AND views < 350 THEN 2
           WHEN views >= 350 THEN 1
       END
FROM stackoverflow.users
WHERE location LIKE '%Canada%' AND views>0

--11. Дополним предыдущий запрос. Отобразим лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе.
--Выведим поля с идентификатором пользователя, группой и количеством просмотров.
--Отсортируем таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора.
WITH a AS (SELECT id, views,
                  CASE
                      WHEN views < 100  THEN 3
                      WHEN views >= 100 AND views < 350 THEN 2
                      WHEN views >= 350 THEN 1
                  END AS view_group
           FROM stackoverflow.users
           WHERE location LIKE '%Canada%' AND views>0),
      b AS (SELECT *,
                   MAX(views) OVER(PARTITION BY view_group) AS max_views
            FROM a)
SELECT id, view_group, views
FROM b
WHERE views=max_views
ORDER BY views DESC, id

--12. Посчитаем ежедневный прирост новых пользователей в ноябре 2008 года. Сформируем таблицу с полями:
-- - номер дня;
-- - число пользователей, зарегистрированных в этот день;
-- - сумму пользователей с накоплением.
WITH a AS (SELECT DISTINCT EXTRACT(DAY FROM creation_date) AS nday,
                  COUNT(id) OVER(PARTITION BY EXTRACT(DAY FROM creation_date)) AS cnt_daily
           FROM stackoverflow.users
           WHERE EXTRACT(MONTH FROM creation_date) = 11 AND EXTRACT(YEAR FROM creation_date) = 2008)
SELECT *,
       SUM(cnt_daily) OVER(ORDER BY nday)
FROM a

--13. Для каждого пользователя, который написал хотя бы один пост, найдем интервал между регистрацией и временем создания первого поста. Отобразим:
-- - идентификатор пользователя;
-- - разницу во времени между регистрацией и первым постом.
WITH a AS (SELECT user_id,
                  MIN(creation_date) AS min_date
           FROM stackoverflow.posts
           GROUP BY user_id)
SELECT id,
       min_date-creation_date
FROM stackoverflow.users AS u
JOIN a ON a.user_id=u.id
  
--1. Выведем общую сумму просмотров у постов, опубликованных в каждый месяц 2008 года. Если данных за какой-либо месяц в базе нет, такой месяц пропускаем.
--Результат отсортируем по убыванию общего количества просмотров.
SELECT DISTINCT DATE_TRUNC('month', creation_date)::date,
       SUM(views_count) OVER(PARTITION BY DATE_TRUNC('month', creation_date))
FROM stackoverflow.posts
WHERE EXTRACT(YEAR from creation_date) = 2008
ORDER BY sum DESC

--2. Выведем имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов.
--Вопросы, которые задавали пользователи, не учитываем. Для каждого имени пользователя выведем количество уникальных значений user_id.
--Отсортируем результат по полю с именами в лексикографическом порядке.
WITH p AS (SELECT p.id, creation_date, user_id, type
           FROM stackoverflow.posts p 
           JOIN stackoverflow.post_types pt ON pt.id=p.post_type_id)
SELECT display_name,
       COUNT(DISTINCT u.id)
FROM stackoverflow.users u
JOIN p ON p.user_id=u.id
WHERE DATE_TRUNC('day', p.creation_date) BETWEEN DATE_TRUNC('day', u.creation_date) AND DATE_TRUNC('day', u.creation_date) + INTERVAL '1 month' AND type='Answer'   
GROUP BY display_name
HAVING COUNT(*)>100
ORDER BY display_name             

--3. Выведем количество постов за 2008 год по месяцам. Отберем посты от пользователей, которые зарегистрировались в сентябре 2008 года
--и сделали хотя бы один пост в декабре того же года. Отсортируем таблицу по значению месяца по убыванию.
WITH list AS (SELECT DISTINCT u.id
              FROM stackoverflow.posts p
              JOIN stackoverflow.users u ON u.id=p.user_id
              WHERE DATE_TRUNC('month', u.creation_date) = '2008-09-01' AND DATE_TRUNC('month', p.creation_date) = '2008-12-01')
SELECT DISTINCT DATE_TRUNC('month', creation_date)::date AS date,
       COUNT(*) OVER(PARTITION BY DATE_TRUNC('month', creation_date))
FROM stackoverflow.posts p
JOIN list on list.id=p.user_id
WHERE DATE_TRUNC('year', creation_date) = '2008-01-01'
ORDER BY date DESC

--4. Используя данные о постах, выведем несколько полей:
-- -идентификатор пользователя, который написал пост;
-- -дата создания поста;
-- -количество просмотров у текущего поста;
-- -сумма просмотров постов автора с накоплением.
--Данные в таблице отсортируем по возрастанию идентификаторов пользователей, а данные об одном и том же пользователе — по возрастанию даты создания поста.
SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER(PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts
ORDER BY user_id, creation_date

--5. Среднее количество дней в период с 1 по 7 декабря 2008 года включительно, в которые пользователи взаимодействовали с платформой.
--Для каждого пользователя отберем дни, в которые он или она опубликовали хотя бы один пост.
WITH a AS (SELECT user_id, 
                  DATE_TRUNC('day', creation_date) AS day_post,
                  COUNT(DATE_TRUNC('day', creation_date)) AS cnt
           FROM stackoverflow.posts
           WHERE DATE_TRUNC('day', creation_date) BETWEEN '2008-12-01' AND '2008-12-08'
           GROUP BY user_id, DATE_TRUNC('day', creation_date))
SELECT ROUND(AVG(cnt))
FROM a

--6. Отобразим таблицу со следующими полями:
-- -Номер месяца.
-- -Количество постов за месяц.
-- -Процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим (с 1 сентября по 31 декабря 2008 года).
--Если постов стало меньше, значение процента будет отрицательным, если больше — положительным. Округлим значение процента до двух знаков после запятой.
WITH a AS (SELECT EXTRACT(MONTH from creation_date) AS month,
                  COUNT(id) AS cnt,
                  LAG(COUNT(id)) OVER()
           FROM stackoverflow.posts
           WHERE DATE_TRUNC('day', creation_date) BETWEEN '2008-09-01' AND '2008-12-31' 
           GROUP BY EXTRACT(MONTH from creation_date))
SELECT month, cnt,
       ROUND((cnt - lag)/lag::numeric*100, 2)
FROM a

--7. Найдем пользователя, который опубликовал больше всего постов за всё время с момента регистрации. Выведем данные его активности за октябрь 2008 года в таком виде:
-- -номер недели;
-- -дата и время последнего поста, опубликованного на этой неделе.
WITH a AS (SELECT user_id, COUNT(*) 
           FROM stackoverflow.posts
           GROUP BY user_id
           ORDER BY COUNT(*) DESC
           LIMIT 1)
SELECT EXTRACT(WEEK from creation_date),
       MAX(creation_date)
FROM stackoverflow.posts p
JOIN a ON a.user_id=p.user_id
WHERE DATE_TRUNC('month', creation_date) = '2008-10-01'
GROUP BY EXTRACT(WEEK from creation_date) 
