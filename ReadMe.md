# Online Store Order Management System (PostgreSQL)
The Online Store Order Management System is a PostgreSQL-based project designed to manage customers, products, and orders in an e-commerce environment.
It demonstrates SQL concepts such as relational schema design, foreign keys, joins, aggregations, analytics, window functions, and revenue calculations.

## Database Structure
### Database Name
OnlineStore

## Tables Overview

```
create table Customers (
						Customer_ID int generated always as identity primary key,
						Name varchar(50) not null,
						Email varchar(50) unique not null,
						Phone varchar(20),
						Address text
);


-- Products 

/* Product_ID will be primary key
	product name cant be null
	price and stock cant be null and also should be >= 0
*/

create table Products (
						Product_ID int generated always as identity primary key,
						Product_Name varchar(100) not null,
						Category varchar(50),
						Price decimal(10,2) not null check (Price >= 0),
						Stock int not null check (Stock >= 0) 
);


-- Orders

/* 
*/

create table Orders (
					  Order_ID int generated always as identity primary key,
					  Customer_ID int not null,
					  Product_ID int not null,
					  Quantity int not null check (Quantity > 0),
					  Order_Date date not null default current_date,

					  --foreign keys
					  foreign key (Customer_ID) references Customers(Customer_ID),
					  foreign key (Product_ID) references Products(Product_ID)
					  
					  
);
```

## Order Management:

### a) Retrieve all orders placed by a specific customer. Here: 'Alice Johnson'


### v1 using customer id
```
select o.order_id, p.product_name, p.category, o.quantity, o.order_date, o.quantity * p.price AS Total_Amount
from Orders o
join Products p on o.product_id = p.product_id
where o.customer_id = (
	select customer_id from customers 
	where name = 'Alice Johnson'
)
order by o.order_date desc;
```

### v2 using customer name with multiple joins
```
select o.order_id, p.product_name, o.quantity, o.order_date, o.quantity * p.price AS Total_Amount
from Orders o
join Products p on o.product_id = p.product_id
join Customers c on o.customer_id = c.customer_id
where c.name = 'Alice Johnson'
order by o.order_date desc;
```

### b) Find products that are out of stock.
```
select product_id, product_name, category, price 
from Products
where Stock = 0
order by category;
```
### c) Calculate the total revenue generated per product.
```
select p.product_id, p.product_name, p.category, coalesce(sum(o.quantity), 0) as unit_solds,
		round(coalesce(sum(o.quantity * p.price), 0), 2) as Total_Revenue
from Products p
left join Orders o on p.product_id = o.product_id
group by p.product_id, p.product_name, p.category
order by Total_Revenue desc;
```

### d) Retrieve the top 5 customers by total purchase amount.
```
with customer_purchase_value as(
select c.customer_id, c.name, c.email, count(o.order_id) as Total_Orders,
		round(sum(o.quantity * p.price), 2) as Amount_Spent
from Orders o
join Customers c on c.customer_id = o.customer_id
join Products p on p.product_id = o.product_id
group by c.customer_id, c.name, c.email
)

select * from customer_purchase_value
order by Amount_Spent desc, Total_Orders desc, name
limit 5;
```

### e) Find customers who placed orders in at least two different product categories.
```
with customer_cat_buy as (
select c.customer_id, c.name, c.email, count(o.order_id) as Order_count, count(distinct p.category) as Category_Count,
		string_agg(distinct p.category, ' | ' order by p.category) as Category_List
from Customers c
join Orders o on c.customer_id = o.customer_id
join Products p on p.product_id = o.product_id
group by c.customer_id, c.name, c.email
)

select * from customer_cat_buy
where Category_Count >= 2
order by Category_Count desc;
```

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------


## Analytics:


### a) Find the month with the highest total sales.
```
select to_char(DATE_TRUNC('Month', order_date), 'Mon YYYY') AS Month_Year, 
		round(sum(o.quantity * p.price), 2) as Total_sales
from Orders o
join Products p on p.product_id = o.product_id
group by DATE_TRUNC('Month', order_date)
order by Total_sales desc
limit 1;
```

### b) Identify products with no orders in the last 6 months.
```
select p.product_id, p.product_name, p.category, p.stock
from Products p
left join Orders o on p.product_id = o.product_id and o.order_date >= (current_date - interval '6 Months')
where o.order_id is null
group by p.product_id
order by p.stock desc, p.category
```

### c) Retrieve customers who have never placed an order. 
```
select c.customer_id, c.name, c.email, 'Never ordered' AS status
from Customers c
left join Orders o on o.customer_id = c.customer_id 
where o.order_id is null
order by c.name
```
### d) Calculate the average order value across all orders. 
```
with order_value as (
	select o.order_id, sum(o.quantity * p.price) as Total_value
	from Orders o
	join Products p on p.product_id = o.product_id
	group by o.order_id
)

select round(avg(Total_value), 2) as Avg_Order_Value
from order_value
```





