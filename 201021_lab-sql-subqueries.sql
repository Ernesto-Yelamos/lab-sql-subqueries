# Lab | SQL Subqueries
# In this lab, you will be using the Sakila database of movie rentals.
use sakila;
set sql_safe_updates=0;
SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

### Instructions
	-- 1. How many copies of the film _Hunchback Impossible_ exist in the inventory system?
# CHILD query to find the film ID for the mentioned film.
select film_id, title from sakila.film
where title in ('Hunchback Impossible'); 

# Getting the answer manually by inserting film_ID in sakila.inventory
select count(inventory_id) from sakila.inventory
where film_id = 439;

# PARENT query to get FILM_ID
select film_id from (
	select film_id, title from sakila.film
	where title in ('Hunchback Impossible')
) as sub1; 

# GRANDPARENT query returning the amount of films in the Inventory (also checking the film_id)
select film_id, count(inventory_id) as 'Amount' from sakila.inventory
where film_id in (
select film_id from (
	select film_id, title from sakila.film
	where title in ('Hunchback Impossible')
	) as sub1
); 


	-- 2. List all films longer than the average.
# CHILD query to get the Average Length
select title, length from sakila.film;  

# CHILD query 2 - Average length
select avg(length) as 'Average length' from sakila.film;

# FINAL QUERY RETURNS SOLUTION
select * from (
	select title, length from sakila.film
	) as sub1
where length > (select avg(length) as 'Average length' from (
	select title, length from sakila.film
	order by length desc
	) as sub2)
order by length desc;


	-- 3. Use subqueries to display all actors who appear in the film _Alone Trip_.
# CHILD query to find the film ID for the mentioned film
select film_id, title from sakila.film
where title in ('alone trip'); -- 

select actor_id, film_id from sakila.film_actor
where film_id = 17;

select concat(first_name, ' ', last_name) as 'Name' from sakila.actor;

# PARENT query to get FILM_ID
select film_id from (
	select film_id, title from sakila.film
	where title in ('alone trip')
) as sub1; 

# GRANDPARENT query returning the actor_id that was in the film with film_id=17 (also checking the film_id)
select film_id, actor_id from sakila.film_actor
where film_id in (
select film_id from (
	select film_id, title from sakila.film
	where title in ('alone trip')
) as sub1); 

# FINAL QUERY RETURNS SOLUTION
select a.actor_id, concat(b.first_name, ' ', b.last_name) as 'Name', a.film_id from sakila.film_actor as a
left join sakila.actor as b on a.actor_id = b.actor_id
where a.film_id in (select film_id from sakila.film where title in ('Alone Trip'));


	-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
# Using joins is enough to get the result.
select a.film_id , a.title , c.name from sakila.film a
join film_category as b on a.film_id = b.film_id
join category as c on b.category_id = c.category_id
where c.name = 'family';


	-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins.
# Subqueries
	# Query 1
select concat(first_name, ' ', last_name) as 'Name', email from sakila.customer;
	# Query 2
select country_id from sakila.country
where country in ('canada');
	# Query 3
select city_id from sakila.city
where country_id in (select country_id from sakila.country
where country in ('canada'));
	# Query 4
select address_id from sakila.address
where city_id in (
select city_id from sakila.city
where country_id in (select country_id from sakila.country
where country in ('canada')));
	# FINAL QUERY RETURNING SOLUTION
Select concat(first_name, ' ', last_name) as 'Name', email from sakila.customer
where address_id in (
select address_id from sakila.address
where city_id in (
select city_id from sakila.city
where country_id in (select country_id from sakila.country
where country in ('canada'))));

# Joins
select a.country, concat(d.first_name, ' ', d.last_name) as 'Name', d.email from sakila.country as a
join sakila.city as b on a.country_id = b.country_id
join sakila.address as c on b.city_id = c.city_id
join sakila.customer as d on c.address_id = d.address_id
where country in ('canada');


	-- 6. Which are films starred by the most prolific (appeared in most films) actor?
# CHILD query to get the actor who appeared in most films.
select actor_id, count(film_id) as 'Amount films', row_number() over (order by count(film_id) desc) as 'position' from sakila.film_actor
group by 1;

# PARENT query to get the actor_id of the most prolific actor.
select actor_id from (select actor_id, count(film_id) as 'Amount films', row_number() over (order by count(film_id) desc) as 'position' from sakila.film_actor
group by 1) as sub1 where position = 1; 

# GRANDPARENT query to get the film_id of the films in which the most prolific actor appeared.
select film_id from sakila.film_actor where actor_id in (select actor_id from (select actor_id, count(film_id) as 'Amount films', row_number() over (order by count(film_id) desc) as 'position' from sakila.film_actor
group by 1) as sub1 where position = 1); 

# GREATGRANDPARENT query to get the name of the films in which the most prolific actor appeared.
select title from sakila.film where film_id in (select film_id from sakila.film_actor where actor_id in (select actor_id from (select actor_id, count(film_id) as 'Amount films', row_number() over (order by count(film_id) desc) as 'position' from sakila.film_actor
group by 1) as sub1 where position = 1));


	-- 7. Films rented by most profitable customer.
# Highest spending customer
select customer_id , sum(amount) as 'Amount spent' , row_number() over (order by sum(amount) desc) as 'position'from payment
group by 1;

# customer_id of highest spending customer
select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'position'from payment
group by 1) as sub1 where position = 1;

# Getting inventory id
select inventory_id from rental where customer_id in (select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'position'from payment
group by 1) as sub1 where position = 1) ;

# Getting film_id
select film_id from inventory where inventory_id in (select inventory_id from rental where customer_id in (select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'position'from payment
group by 1) as sub1 where xyz = 1));

# FINAL QUERY RETURNING SOLUTION
select title from film where film_id in (select film_id from inventory where inventory_id in (select inventory_id from rental where customer_id in (select customer_id from (select customer_id , sum(amount) as most_money_spent , row_number() over (order by sum(amount) desc) as 'position'from payment
group by 1) as sub1 where xyz = 1)));


	-- 8. Customers who spent more than the average.
select * from sakila.payment;

select concat(a.first_name, ' ', a.last_name) as 'Name', round(sum(amount), 2) as 'Amount' from sakila.customer as a
join sakila.payment as b on b.customer_id = a.customer_id
group by Name;

select avg(Amount) from (
	select concat(a.first_name, ' ', a.last_name) as 'Name', round(sum(amount), 2) as 'Amount' from sakila.customer as a
	join sakila.payment as b on b.customer_id = a.customer_id
	group by Name) as sub1;
    
select concat(a.first_name, ' ', a.last_name) as 'Name', round(sum(amount), 2) as 'Amount' from sakila.customer as a
join sakila.payment as c on c.customer_id = a.customer_id
group by Name
having Amount > (select avg(Amount) from (
	select concat(a.first_name, ' ', a.last_name) as 'Name', round(sum(amount), 2) as 'Amount' from sakila.customer as a
	join sakila.payment as b on b.customer_id = a.customer_id
	group by Name) as sub1)
order by Amount;

