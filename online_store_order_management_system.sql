--Database creation OnlineStore
create database OnlineStore;

--Verify current database
select current_database();

--Tables creation
-- Customers
/* customer_id as primary key with auto-increment
	name is not null,
	email as unique
*/

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


-- Sample data inserts

-- Customers

insert into Customers (name, email, phone, address) values 
						('Alice Johnson', 'alice.johnson@example.com', '9876543210', 'New York'),
						('Bob Smith', 'bob.smith@example.com', '9123456789', 'Los Angeles'),
						('Carol Davis', 'carol.davis@example.com', '9988776655', 'Chicago'),
						('David Wilson', 'david.wilson@example.com', '9345678901', 'Houston'),
						('Eva Brown', 'eva.brown@example.com', '9234567890', 'Miami'),
						('Arun Prince', 'arun.prince@example.com', '9234167890', 'Chennai'),
						('Priya Ghosh', 'priya.ghosh@example.com', '98555-01054', 'Hyderabad'),
						('Karan Kumar', 'karan.kumar@example.com', '95555-01064', 'Bangalore'),
						('Manish Yadev', 'manish.yadev@example.com', '9976573211', 'Delhi');



select * from Customers;

-- Products

insert into Products (product_name, category, price, stock) values
						('Laptop Pro 15"', 'Electronics', 1299.99, 8),
						('Wireless Mouse', 'Electronics', 39.99, 45),
						('USB-C Hub', 'Electronics', 79.99, 0),
						('Mechanical Keyboard', 'Electronics', 149.99, 12),
						('Yoga Mat Premium', 'Sports', 59.99, 30),
						('Running Shoes', 'Sports', 119.99, 25),
						('Coffee Maker', 'Home', 89.99, 15),
						('Blender Pro', 'Home', 129.99, 0),
						('Desk Lamp LED', 'Home', 44.99, 50),
						('Novel Bestseller 2025', 'Books', 24.99, 100),
						('Bluetooth Headphones', 'Electronics', 150.00, 0),
						('Office Chair', 'Furniture', 200.00, 25),
						('Electric Kettle', 'Home', 40.00, 5),
						('Gaming Mouse', 'Electronics', 60.00, 12),
						('Atomic Habits', 'Books', 21.99, 100);

						


select * from Products;


-- Orders

insert into Orders  (Customer_ID, Product_ID, Quantity, Order_Date) values 
						(1, 1, 1, '2025-01-10'),
						(1, 2, 2, '2025-02-15'),
						(2, 3, 1, '2025-03-05'),
						(3, 1, 1, '2025-01-25'),
						(3, 5, 3, '2025-02-10'),
						(4, 4, 2, '2025-02-18'),
						(2, 5, 1, '2025-03-12'),
						(7, 3, 1, '2025-01-11'),
						(1, 1, 1, '2025-01-15'),
						(1, 2, 2, '2025-02-20'),
						(2, 5, 1, '2025-03-10'),
						(8, 6, 1, '2025-03-12'),
						(3, 1, 1, '2025-04-05'),
						(3, 4, 1, '2025-05-18'),
						(4, 7, 2, '2025-06-22'),
						(7, 10, 5, '2025-07-01'),
						(1, 4, 1, '2025-08-14'),
						(5, 9, 3, '2025-09-30'),
						(2, 1, 1, '2025-10-25'),
						(8, 2, 1, '2025-11-15'),
						(1, 7, 1, '2025-01-22'),
						(3, 15, 1, '2025-04-27');;


insert into Orders  (Customer_ID, Product_ID, Quantity, Order_Date) values 
						


select * from Orders;

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

--###########################################################################################################
-- Order Management:
--###########################################################################################################

-- a) Retrieve all orders placed by a specific customer. Here: 'Alice Johnson'

--v1 using customer id
select o.order_id, p.product_name, p.category, o.quantity, o.order_date, o.quantity * p.price AS Total_Amount
from Orders o
join Products p on o.product_id = p.product_id
where o.customer_id = (
	select customer_id from customers 
	where name = 'Alice Johnson'
)
order by o.order_date desc;

--v2 using customer name with multiple joins
select o.order_id, p.product_name, o.quantity, o.order_date, o.quantity * p.price AS Total_Amount
from Orders o
join Products p on o.product_id = p.product_id
join Customers c on o.customer_id = c.customer_id
where c.name = 'Alice Johnson'
order by o.order_date desc;


-- b) Find products that are out of stock.

select product_id, product_name, category, price 
from Products
where Stock = 0
order by category;

-- c) Calculate the total revenue generated per product.

select p.product_id, p.product_name, p.category, coalesce(sum(o.quantity), 0) as unit_solds,
		round(coalesce(sum(o.quantity * p.price), 0), 2) as Total_Revenue
from Products p
left join Orders o on p.product_id = o.product_id
group by p.product_id, p.product_name, p.category
order by Total_Revenue desc;

-- d) Retrieve the top 5 customers by total purchase amount.

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


-- e) Find customers who placed orders in at least two different product categories.

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


-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

--############################################################################################
-- Analytics:
--############################################################################################

-- a) Find the month with the highest total sales.

select to_char(DATE_TRUNC('Month', order_date), 'Mon YYYY') AS Month_Year, 
		round(sum(o.quantity * p.price), 2) as Total_sales
from Orders o
join Products p on p.product_id = o.product_id
group by DATE_TRUNC('Month', order_date)
order by Total_sales desc
limit 1;


-- b) Identify products with no orders in the last 6 months.

select p.product_id, p.product_name, p.category, p.stock
from Products p
left join Orders o on p.product_id = o.product_id and o.order_date >= (current_date - interval '6 Months')
where o.order_id is null
group by p.product_id
order by p.stock desc, p.category


-- c) Retrieve customers who have never placed an order. 

select c.customer_id, c.name, c.email, 'Never ordered' AS status
from Customers c
left join Orders o on o.customer_id = c.customer_id 
where o.order_id is null
order by c.name

-- d) Calculate the average order value across all orders. 

with order_value as (
	select o.order_id, sum(o.quantity * p.price) as Total_value
	from Orders o
	join Products p on p.product_id = o.product_id
	group by o.order_id
)

select round(avg(Total_value), 2) as Avg_Order_Value
from order_value





