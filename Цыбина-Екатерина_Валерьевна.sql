--1. Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.

select distinct tr.brand  
from transaction tr
where tr.standard_cost > 1500.0;

-- Посмотрите схему базы данных здесь: https://raw.githubusercontent.com/KaterinaKuhne/HW_data_storage_and_processing_2/refs/heads/main/Task_1_result.png


--2. Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.

select tr.transaction_id, tr.transaction_date, tr.order_status    
from transaction tr
where (to_date(transaction_date, 'DD.MM.YYYY') between '2017-04-01' and '2017-04-09') and (tr.order_status = 'Approved')
order by transaction_date asc;  --добавим, чтобы наглядно убедиться что выбрались только нужные даты
 
--3. Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.

select distinct cm.job_title     
from customer cm
where (cm.job_industry_category = 'IT' or cm.job_industry_category = 'Financial Services') and (cm.job_title like 'Senior%');

--другой вариант:
select distinct cm.job_title     
from customer cm
where cm.job_industry_category in ('IT', 'Financial Services') and cm.job_title like 'Senior%';

--4. Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services

-- в колонке brand есть пропущенные значения
 
select distinct tr.brand 
from transaction tr
where tr.customer_id in (
		select cm.customer_id 
		from customer cm 
		where cm.job_industry_category = 'Financial Services'
		);

--или если для указанных клиентов важны только строки, где бренд явно указан, можно не учитывать пропущенные бренды: 
select distinct tr.brand 
from transaction tr
where tr.brand != '' and tr.customer_id in (
		select cm.customer_id 
		from customer cm 
		where cm.job_industry_category = 'Financial Services'
		);

--тоже самое через join:
select distinct tr.brand 
from transaction tr
join customer cm on tr.customer_id = cm.customer_id
where cm.job_industry_category = 'Financial Services' and tr.brand != '';

--5. Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.
--Не совсем понятно какую именно информацию о клиентах нужно вывести, поэтому я ограничилась идентификатором и ИФ

select customer_id, first_name, last_name
from customer 
where customer_id in (
      select customer_id
      from transaction 
      where brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles') and online_order = TRUE
  )
limit 10;

--тоже самое через join с добавлением бренда и вида заказа для большей наглядности:
select cm.customer_id, cm.first_name, cm.last_name, tr.brand, tr.online_order
from customer cm
inner join transaction tr
on cm.customer_id = tr.customer_id
where tr.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles') and tr.online_order = true
limit 10;

--6. Вывести всех клиентов, у которых нет транзакций.
--Не совсем понятно какую именно информацию о клиентах нужно вывести, поэтому я ограничилась идентификатором и ИФ

select cm.customer_id, cm.first_name, cm.last_name
from customer cm
left join transaction tr
on cm.customer_id = tr.customer_id
where tr.customer_id is NULL

--7. Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.

select distinct cm.customer_id, cm.first_name, cm.last_name, tr.standard_cost, cm.job_industry_category
from customer cm
inner join transaction tr on cm.customer_id = tr.customer_id
where cm.job_industry_category = 'IT' and tr.standard_cost = (select max(standard_cost) from transaction);

--8. Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.

select distinct cm.customer_id, cm.first_name, cm.last_name, tr.transaction_date, tr.order_status, cm.job_industry_category
from customer cm
inner join transaction tr on cm.customer_id = tr.customer_id
where cm.job_industry_category in ('IT', 'Health') and tr.order_status = 'Approved' and
(to_date(tr.transaction_date, 'DD.MM.YYYY') between '2017-07-07' and '2017-07-17');

--тоже самое только с использованием временной таблицы CTE
with filtered_transactions as (select customer_id, transaction_date, order_status 
	from transaction
    where order_status = 'Approved' and to_date(transaction_date, 'DD.MM.YYYY') between '2017-07-07' and '2017-07-17')
select distinct cm.customer_id, cm.first_name, cm.last_name, cm.job_industry_category, 
filtered_transactions.transaction_date, filtered_transactions.order_status
from customer cm       
inner join filtered_transactions on cm.customer_id = filtered_transactions.customer_id
where cm.job_industry_category in ('IT', 'Health');
