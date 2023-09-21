/*
Name: Thomas LaPinta
CWID: 10462128
*/

/*Report 1*/

With Current as (
	select prod, month, avg(quant) as AVG_q
	from sales
	group by prod, month
), Before as(
	select t1.prod, t1.month, t2.AVG_q as prev_avg
	from Current t1 left join Current t2
	on t1.prod = t2.prod and t1.month - 1 = t2.month
), After as(
	select t1.prod, t1.month, t2.AVG_q as next_avg
	from Current t1 left join Current t2
	on t1.prod = t2.prod and t1.month + 1 = t2.month
), Ref as (
	select * from Before
	join After using(prod, month)
), Joined as(
	select s.prod, s.month, count(*)
	from sales s, Ref r
	where s.prod = r.prod and s.month = r.month
	and ((s.quant between r.prev_avg and r.next_avg)
	or (s.quant between r.next_avg and r.prev_avg))
	group by s.prod, s.month
), q1 as(
	select distinct prod, month
	from sales
	except
	select distinct prod, month
	from Joined
), q2 as(
	select prod, month, 0
	from q1
)
select * from Joined
Union
select * from q2;

/*Report 2*/

With ext_sales As(
	select cust, prod, day, month, ceiling(month/3.0) as qtr, year, state, quant, date
	from sales
), base As(
	select cust, prod, qtr, avg(quant) as During_AVG
	from ext_sales
	group by cust, prod, qtr
), before As(
	select b1.cust, b1.prod, b1.qtr, b2.During_AVG as Before_Avg
	from base b1 left join base b2
	on b1.cust = b2.cust and b1.prod = b2.prod and b1.qtr - 1 = b2.qtr
), after As(
	select b1.cust, b1.prod, b1.qtr, b2.During_AVG as After_AVG
	from base b1 left join base b2
	on b1.cust = b2.cust and b1.prod = b2.prod and b1.qtr + 1 = b2.qtr
)

select *
from before
join base using (cust, prod, qtr)
join after using (cust, prod, qtr);

/*Report 3*/

With q1 as (
	select cust, prod, state, avg(quant) as Current_AVG
	from sales
	group by cust, prod, state
), q2 as (
	select q1.cust, q1.prod, q1.state, avg(s.quant) as Other_Prod_Avg
	from q1, sales s
	where q1.cust = s.cust AND q1.state = s.state AND q1.prod != s.prod
	group by q1.cust, q1.prod, q1.state
), q3 as (
	select q1.cust, q1.prod, q1.state, avg(s.quant) as Other_Cust_Avg
	from q1, sales s
	where q1.cust != s.cust AND q1.state = s.state AND q1.prod = s.prod
	group by q1.cust, q1.prod, q1.state
)

select * from q1
join q3 using (cust, prod, state)
join q2 using (cust, prod, state);

/*Report 4*/

With q1 as (
	select distinct prod, quant
	from sales
), ordered_position As(
	select s1.prod, s1.quant, count(s2.quant) as pos
	from q1 s1 join sales s2
	on s1.prod = s2.prod and s2.quant <= s1.quant
	group by s1.prod, s1.quant
), ceilings as (
	select prod, ceiling(count(*)/2) as c
	from sales
	group by prod
), comp as (
	select *
	from ordered_position
	join ceilings using (prod)
	where ordered_position.pos >= ceilings.c
), med_pos as (
	select prod, min(pos) as pos
	from comp
	group by prod
), median as (
    select ordered_position.prod, ordered_position.quant
    from ordered_position, med_pos
    where ordered_position.prod = med_pos.prod
    and ordered_position.pos = med_pos.pos
)

select * from median;









