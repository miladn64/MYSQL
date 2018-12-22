SELECT * FROM sakila.actor;

use sakila;

select first_name,last_name from sakila.actor;

select concat(first_name,' ' ,last_name) ActorName from sakila.actor;

select actor_id, last_name from sakila.actor where first_name='JOE';

##b. Find all actors whose last name contain the letters GEN:
select * from sakila.actor where last_name like '%GEN%';

##2c. Find all actors whose last names contain the letters LI. 
##This time, order the rows by last name and first name, in that order:
select * from sakila.actor where last_name like '%LI%'
order by last_name,first_name;

#2d. Using IN, display the country_id and country columns of the following countries: 
#Afghanistan, Bangladesh, and China:
select * from country;
select * from country where country in ('Afghanistan', 'Bangladesh','China');

#3a. You want to keep a description of each actor.
# You don't think you will be performing queries on a description, 
#so create a column in the table actor named description 
#and use the data type BLOB (Make sure to research the type BLOB, 
#as the difference between it and VARCHAR are significant).

alter table actor
ADD COLUMN description blob;

select * from actor;

#3b. Very quickly you realize that
# entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop COLUMN description ;

#4a. List the last names of actors, as well as how many actors have that last name.

select last_name , count(*) from actor group by last_name order by count(*) desc;

#4b. List last names of actors and the number of actors who have that last name,
# but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) 
FROM sakila.actor
GROUP BY last_name
HAVING COUNT(*) > 1  order by count(*) desc;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.

update  actor
set first_name='HARPO' where first_name='GROUCHO' and last_name='WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
#It turns out that GROUCHO was the correct name after all! In a single query, 
#if the first name of the actor is currently HARPO, change it to GROUCHO.

update  actor
set first_name='GROUCHO' where first_name='HARPO' and last_name='WILLIAMS';

SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names,
# as well as the address, of each staff member. Use the tables staff and address:
select * from staff;
select * from address;
select first_name,Last_name,address from staff s join address a on s.address_id=a.address_id;

#Use JOIN to display the total amount rung up by each staff 
#member in August of 2005. Use tables staff and payment.

select sum(amount) from payment where staff_id in (1,2) and month(payment_date)=8 group by staff_id ;

select first_name,Last_name, sum(amount) from staff s join payment p on s.staff_id=p.staff_id
where month(payment_date)=8 group by first_name;

#List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.

select * from film;
select * from film_actor where film_id=1;

select title,count(actor_id) from film f join film_actor a on f.film_id=a.film_id group by title;

#How many copies of the film Hunchback Impossible exist in the inventory system?
select * from film where title='Hunchback Impossible';
select count(title) from inventory i join film f on i.film_id=f.film_id where title='Hunchback Impossible' ;

# Using the tables payment and customer and the JOIN command, 
#list the total paid by each customer. List the customers alphabetically by last name:
select * from payment;
select * from customer;

select first_name,last_name,sum(amount) as 'Total Payment' from payment a
 join customer b on a.customer_id=b.customer_id
 group by a.customer_id order by last_name ;
 
 #7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
 #As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
 #Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select * from film
where (title like 'K%' or title like 'Q%') 
and language_id= (select language_id from language where name='English') ;

#Use subqueries to display all actors who appear in the film Alone Trip.

select * from film;
select * from actor;
select * from film_actor;

select first_name,last_name from actor
 where actor_id in (select actor_id from film_actor
 where film_id=(select film_id from film where title='Alone Trip'));
 
 #You want to run an email marketing campaign in Canada, 
 #for which you will need the names and email addresses of all Canadian customers.
 #Use joins to retrieve this information.

select * from customer;
select * from address;
select * from city;

select a.name,c.email from customer_list a join customer c on a.ID=c.customer_id where country='Canada';

#7d. Sales have been lagging among young families,
# and you wish to target all family movies for a promotion. Identify all movies categorized as family films.


select * from film_list where category='Family';
#7e. Display the most frequently rented movies in descending order.
select * from payment order by customer_id desc;

select f.film_id,title,r.inventory_id,count(customer_id) as "Times rented out" from rental r join inventory i 
on r.inventory_id=i.inventory_id 
join film f on i.film_id=f. film_id
group by title
order by count(customer_id) desc;

#7f. Write a query to display how much business, in dollars, each store brought in.

select staff_id,sum(amount) from payment group by staff_id;

#7g. Write a query to display for each store its store ID, city, and country.
select s.store_id,c.city,cc.country from store s join address a on s.address_id=a.address_id
join city c on a.city_id=c.city_id join country cc on c.country_id=cc.country_id;

#7h. List the top five genres in gross revenue in descending order.
# (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)


SELECT c.name as Generes, SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON c.category_id=fc.category_id
JOIN inventory i ON fc.film_id=i.film_id
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross desc  LIMIT 5;

#8a. In your new role as an executive, 
#you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

create VIEW Top_5_category AS

SELECT c.name as Generes, SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON c.category_id=fc.category_id
JOIN inventory i ON fc.film_id=i.film_id
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross desc  LIMIT 5;


#How would you display the view that you created in 8a?

select * from top_5_category;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it

drop view top_5_category;