use msdb;
with customer_points AS(
select s.customer_id,count(product_name) as total_items,
Sum(price) as total_amount,product_name,
CASE
when product_name in ('curry','ramen') then (sum(price*10))
else (sum(price*20))
end as points
from sales s
inner join menu m
on s.product_id=m.product_id
group by s.customer_id,product_name)
select * from customer_points;
