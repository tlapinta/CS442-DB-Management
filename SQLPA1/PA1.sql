/*Report 1*/
With MinT as (
	select cust, quant, prod, date, state
	from sales
	where (cust, quant) in (
		select cust, min(quant)
		from sales
		group by cust)
), MaxT as (
	select cust, quant, prod, date, state
	from sales
	where (cust, quant) in (
		select cust, max(quant)
		from sales
		group by cust)
), AvgT as (
	select cust, avg(quant) as AVG_Q
	from sales
	group by cust
)
select 
	MinT.cust as Cust,
	MinT.quant as Min_Q,
	MinT.prod as Min_Prod,
	MinT.date as Min_date,
	MinT.state as ST,
	MaxT.quant as Max_Q,
	MaxT.prod as Max_Prod,
	MaxT.date as Max_date,
	MaxT.state as ST,
	AvgT.AVG_Q	
from MinT
join MaxT using(cust) join AvgT using(cust);
	
/*Report 2*/
With MaxP as (With TotalQuant as (select
	sales.month,
	sales.day,
	sum(quant) as Sums
from 
	sales
group by
	sales.month, sales.day
order by
	sales.month ASC, sales.day ASC)
select month, day as Most_Profit_day, Sums as Most_Profit_Total
from TotalQuant
where (month, Sums) in
	(select
		TotalQuant.month,
		max(TotalQuant.Sums)
	from TotalQuant
	group by month)), 
MinP as (With TotalQuant as (select
	sales.month,
	sales.day,
	sum(quant) as Sums
from 
	sales
group by
	sales.month, sales.day
order by
	sales.month ASC, sales.day ASC)
select month, day as Least_Profit_day, Sums as Least_Profit_Total
from TotalQuant
where (month, Sums) in
	(select
		TotalQuant.month,
		min(TotalQuant.Sums)
	from TotalQuant
	group by month))
select
*
from MaxP join MinP using(month);

/*Report 3*/
With MaxMonth as (
	With ProdQuants as (
		select prod, month, sum(quant) as Sums
		from sales
		group by prod, month)
	select prod, month as Most_Fav_Month
	from ProdQuants 
	where (prod, Sums) in
		(select prod, max(Sums)
		from ProdQuants
		group by prod)),
MinMonth as (With ProdQuants as (
		select prod, month, sum(quant) as Sums
		from sales
		group by prod, month)
	select prod, month as Least_Fav_month
	from ProdQuants 
	where (prod, Sums) in 
		(select prod, min(Sums)
		from ProdQuants
		group by prod))
select *
from MaxMonth
join MinMonth using(prod);
	
/*Report 4*/
With Q1 as (
	select cust, prod, avg(quant) as Q1_avg
	from sales
	where month < 4
	group by cust, prod
), Q2 as (
	select cust, prod, avg(quant) as Q2_avg
	from sales
	where month > 3 and month < 7
	group by cust, prod
), Q3 as (
	select cust, prod, avg(quant) as Q3_avg
	from sales
	where month > 6 and month < 10
	group by cust, prod
), Q4 as (
	select cust, prod, avg(quant) as Q4_avg
	from sales
	where month > 9
	group by cust, prod
), AvgTot as (
	select cust, prod, avg(quant) as Average
	from sales
	group by cust, prod
), TotQuant as (
	select cust, prod, sum(quant) as Total
	from sales
	group by cust, prod
), Count as (
	select cust, prod, count(prod)
	from sales
	group by cust, prod
)
select *
from Q1 join Q2 using(cust, prod) join Q3 using(cust, prod) 
	 join Q4 using(cust, prod) join AvgTot using(cust, prod) 
	 join TotQuant using(cust, prod) join Count using(cust,prod);

/*Report 5*/
/*With NJ as (
	select cust, prod, max(quant) as NJ_Max
	from sales
	where state = 'NJ'
	group by cust, prod
), NY as(
	select cust, prod, max(quant) as NY_Max
	from sales
	where state = 'NY'
	group by cust, prod
), CT as (
	select cust, prod, max(quant) as CT_Max
	from sales
	where state = 'CT'
	group by cust, prod
)
select *
from NJ
join NY using(cust, prod) join CT using(cust,prod);*/

With NJ as (
	select cust, prod, quant as NJ_Max, date
	from sales
	where (cust, prod, quant) in (
		select cust, prod, max(quant)
		from sales
		where state = 'NJ'
		group by cust, prod
	)
), NY as (
	select cust, prod, quant as NY_Max, date
	from sales
	where (cust, prod, quant) in (
		select cust, prod, max(quant)
		from sales
		where state = 'NY'
		group by cust, prod
	)
), CT as (
	select cust, prod, quant as CT_Max, date
	from sales
	where (cust, prod, quant) in (
		select cust, prod, max(quant)
		from sales
		where state = 'CT'
		group by cust, prod
	)
)
select *
from NJ join NY using (cust, prod) join CT using(cust, prod)
where NY_max > NJ_max or NY_max > CT_max;
	