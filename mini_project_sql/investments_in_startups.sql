-- 1. Отобразим все записи из таблицы company по компаниям, которые закрылись.
SELECT COUNT(id)
FROM company
WHERE status='closed'

2. Отобразим количество привлечённых средств для новостных компаний США. Используем данные из таблицы company. Отсортируем таблицу по убыванию значений в поле funding_total. 
3. Найдем общую сумму сделок по покупке одних компаний другими в долларах. Отберем сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
4. Отобразим имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'.
5. Выведем на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'.
6. Для каждой страны отобразим общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируем данные по убыванию суммы.
7. Составим таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату. Оставим в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
8. Создадим поле с категориями: Для фондов, которые инвестируют в 100 и более компаний, назначим категорию high_activity. Для фондов, которые инвестируют в 20 и более компаний до 100, назначим категорию middle_activity. Если количество инвестируемых компаний фонда не достигает 20, назначим категорию low_activity. Отобразим все поля таблицы fund и новое поле с категориями.
9. Для каждой из категорий, назначенных в предыдущем пункте, посчитаем округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведем на экран категории и среднее число инвестиционных раундов. Отсортируем таблицу по возрастанию среднего.
10. Проанализируем, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы.  Для каждой страны посчитаем минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключим страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю.  Выгрузим десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавим сортировку по коду страны в лексикографическом порядке.
11. Отобразим имя и фамилию всех сотрудников стартапов. Добавим поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
12. Для каждой компании найдем количество учебных заведений, которые окончили её сотрудники. Выведем название компании и число уникальных названий учебных заведений. Составим топ-5 компаний по количеству университетов.
13. Составим список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
14. Составим список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
15. Составим таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
16. Посчитаем количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учтем, что некоторые сотрудники могли окончить одно и то же заведение дважды.
17. Дополним предыдущий запрос и выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. 
18. Выведем среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.
19. Составим таблицу из полей: name_of_fund — название фонда; name_of_company — название компании; amount — сумма инвестиций, которую привлекла компания в раунде. В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
20. Выгрузим таблицу, в которой будут такие поля: название компании-покупателя; сумма сделки; название компании, которую купили; сумма инвестиций, вложенных в купленную компанию; доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа. Не будем учитыватьте сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключим такую компанию из таблицы.  Отсортируем таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничим таблицу первыми десятью записями.
21. Выгрузим таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверим, что сумма инвестиций не равна нулю. Выведем также номер месяца, в котором проходил раунд финансирования.
22. Отберем данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируем данные по номеру месяца и получим таблицу, в которой будут поля: номер месяца, в котором проходили раунды; количество уникальных названий фондов из США, которые инвестировали в этом месяце; количество компаний, купленных за этот месяц; общая сумма сделок по покупкам в этом месяце.
23. Составим сводную таблицу и выведем среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год будут в отдельном поле. Отсортируем таблицу по среднему значению инвестиций за 2011 год от большего к меньшему. 