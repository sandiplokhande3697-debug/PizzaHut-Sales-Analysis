create database pizza_hut;
use pizza_hut;

select * from orders;

select * from order_details limit 5;

select * from pizzas;

select * from pizza_types limit 5;

select count(*) from orders;

select count(*) from order_details;

select count(*) from pizzas;

select count(*) from pizza_types;

describe orders;
describe order_details;
describe pizzas;
describe pizza_types;

-- Total Orders.
select count(distinct order_id) as total_orders
from orders;

-- Total Pizza sold.
select sum(quantity) as total_pizzas_sold
from order_details;

-- Total Revenue.
select round(sum(od.quantity * p.price), 2) as total_revenue
from order_details od join pizzas p 
on od.pizza_id = p.pizza_id;

-- Top 5 best_selling pizzas
select
    pt.name as pizza_name,
    sum(od.quantity) as total_sold
from order_details od
join pizzas p
    on od.pizza_id = p.pizza_id
join pizza_types pt
    on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by total_sold desc
limit 5;

-- Category-wise sales analysis
select
    pt.category,
    sum(od.quantity) as total_pizzas_sold,
    round(sum(od.quantity * p.price), 2) as total_revenue
from order_details od
join pizzas p
    on od.pizza_id = p.pizza_id
join pizza_types pt
    on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by total_revenue desc;

-- Peak ordering hour find
select 
	hour(time) as order_hour,
    count(distinct order_id) as total_orders
from orders
group by hour(time)
order by total_orders desc;

-- Top 3 revenue-generating pizzas
with pizza_revenue as (
    select
        pt.name as pizza_name,
        pt.category,
        sum(od.quantity * p.price) as revenue
    from order_details od
    join pizzas p
        on od.pizza_id = p.pizza_id
    join pizza_types pt
        on p.pizza_type_id = pt.pizza_type_id
    group by pt.name, pt.category
),
ranked_pizzas as (
    select *,
        rank() over (
            order by revenue desc
        ) as revenue_rank
    from pizza_revenue
)
select *
from ranked_pizzas
where revenue_rank <= 3;


-- pizza category 3 top pizzas
with pizza_revenue as (
    select
        pt.name as pizza_name,
        pt.category,
        sum(od.quantity * p.price) as revenue
    from order_details od
    join pizzas p
        on od.pizza_id = p.pizza_id
    join pizza_types pt
        on p.pizza_type_id = pt.pizza_type_id
    group by pt.name, pt.category
),
ranked_pizzas as (
    select *,
        rank() over (
            partition by category
            order by revenue desc
        ) as pizza_rank
    from pizza_revenue
)
select *
from ranked_pizzas
where pizza_rank <= 3;

-- Pizza type total revenue contribution percentage
select
    pt.name as pizza_name,
    round(sum(od.quantity * p.price), 2) as revenue,
    round(
        sum(od.quantity * p.price) * 100 /
        (select sum(od2.quantity * p2.price)
         from order_details od2
         join pizzas p2
             on od2.pizza_id = p2.pizza_id),
        2
    ) as revenue_percentage
from order_details od
join pizzas p
    on od.pizza_id = p.pizza_id
join pizza_types pt
    on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue desc;

-- Cumulative revenue over time
with daily_revenue as (
    select
        o.date as order_date,
        sum(od.quantity * p.price) as revenue
    from orders o
    join order_details od
        on o.order_id = od.order_id
    join pizzas p
        on od.pizza_id = p.pizza_id
    group by o.date
)
select
    order_date,
    revenue,
    sum(revenue) over (
        order by order_date
    ) as cumulative_revenue
from daily_revenue
order by order_date;

-- **Business Insight
-- Average daily orders
select round(avg(daily_orders), 2) as avg_daily_orders
from (
    select date, count(distinct order_id) as daily_orders
    from orders
    group by date
) as daily_summary;

-- Daily revenue
select
    o.date,
    round(sum(od.quantity * p.price), 2) as daily_revenue
from orders o
join order_details od
    on o.order_id = od.order_id
join pizzas p
    on od.pizza_id = p.pizza_id
group by o.date
order by o.date;

-- Pizza size-wise sales
select
    p.size,
    sum(od.quantity) as total_pizzas_sold,
    round(sum(od.quantity * p.price), 2) as total_revenue
from order_details od
join pizzas p
    on od.pizza_id = p.pizza_id
group by p.size
order by total_revenue desc;

-- Monthly revenue trend
select
    month(date) as month_number,
    round(sum(od.quantity * p.price), 2) as monthly_revenue
from orders o
join order_details od
    on o.order_id = od.order_id
join pizzas p
    on od.pizza_id = p.pizza_id
group by month(date)
order by month_number;

