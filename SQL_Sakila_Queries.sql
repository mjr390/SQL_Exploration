-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from sakila.actor
;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
select concat_ws(" ", first_name, last_name) as 'Actor Name' from sakila.actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name from sakila.actor
where first_name = 'Joe';


-- 2b. Find all actors whose last name contain the letters GEN:
select * from sakila.actor
where last_name like '%GEN%'
;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from sakila.actor
where last_name like '%LI%'
order by last_name, first_name ASC
;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from sakila.country
where country in ('Afghanistan', 'Bangladesh', 'China')
;

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
#select actor_id, middle_Name, last_name, last_update from sakila.actor
alter table sakila.actor
add middle_Name varchar(30)
;
select actor_id, first_name, middle_Name, last_name, last_update from sakila.actor
;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table sakila.actor
modify column middle_name blob
;

-- 3c. Now delete the middle_name column.
alter table sakila.actor
drop middle_name
;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as 'Count'
from sakila.actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
create view Last_name_count as
select last_name, count(last_name) as 'Counter'
from sakila.actor
group by last_name
;
select * from Last_name_count
where Counter > 1
;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
update sakila.actor
	set first_name = 'HARPO'
where first_name = 'GROUCHO' AND last_name = 'WILLIAMS'
;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
select if(first_name = 'HARPO', 'GROUCHO', 'MUCHO GROUCHO')
from sakila.actor
;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table sakila.actor
;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT sakila.staff.first_name, sakila.staff.last_name, sakila.address.address
FROM sakila.staff
INNER JOIN sakila.address ON
sakila.staff.address_id = sakila.address.address_id
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select sakila.payment.staff_id, sakila.staff.first_name, sakila.staff.last_name, sum(sakila.payment.amount) as 'Total Rung Up'
from sakila.payment
inner join sakila.staff on
sakila.staff.staff_id = sakila.payment.staff_id
group by sakila.payment.staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select sakila.film_actor.film_id,  sakila.film.title, count(sakila.film_actor.film_id) as 'Number of Actors'
from sakila.film_actor
inner join sakila.film on
sakila.film.film_id = sakila.film_actor.film_id
group by sakila.film_actor.film_id
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as 'Total Copies of Hunchback Impossible' from sakila.inventory
where film_id =(
select film_id from sakila.film
where title = 'Hunchback Impossible'
)
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select sakila.payment.customer_id, sakila.customer.first_name, sakila.customer.last_name, sum(sakila.payment.amount) as 'Total Paid'
from sakila.payment
inner join sakila.customer on
sakila.customer.customer_id = sakila.payment.customer_id
group by sakila.payment.customer_id
order by sakila.customer.last_name ASC
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
--  films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select sakila.film.title from sakila.film
where (sakila.film.title like 'K%' or sakila.film.title like'Q%')
and sakila.film.language_id = (
select language_id from sakila.language
where sakila.language.name = 'English'
)
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
create view Alone_Trip_actor_ids as
select sakila.film_actor.actor_id 
from sakila.film_actor
where film_id = (
select film_id from sakila.film
where title = 'Alone Trip'
)
;

select sakila.actor.first_name, sakila.actor.last_name, Alone_Trip_actor_ids.actor_id
from sakila.actor
inner join Alone_Trip_actor_ids on
sakila.actor.actor_id = Alone_Trip_actor_ids.actor_id
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
create view Canada_with_city_id as
select sakila.country.country, sakila.country.country_id, sakila.city.city_id
from sakila.country
inner join sakila.city on
sakila.country.country_id = sakila.city.country_id
where sakila.country.country = 'Canada' 
;
create view Canada_with_address_id as
select sakila.Canada_with_city_id.country, sakila.Canada_with_city_id.country_id, Canada_with_city_id.city_id, sakila.address.address_id
from sakila.Canada_with_city_id
inner join sakila.address on
sakila.Canada_with_city_id.city_id = sakila.address.city_id
;
select sakila.customer.first_name, sakila.customer.last_name, sakila.customer.email
from sakila.customer
inner join sakila.Canada_with_address_id on
sakila.customer.address_id = sakila.Canada_with_address_id.address_id
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
create view Family_film_ids as
select film_id
from sakila.film_category
where category_id = (
select category_id
from sakila.category
where name = 'Family'
)
;
select sakila.film.title as 'Family Movies'
from sakila.film
inner join sakila.Family_film_ids on
sakila.film.film_id = sakila.Family_film_ids.film_id
;

-- 7e. Display the most frequently rented movies in descending order.
create view Inventory_rental_Count as
select sakila.rental.inventory_id, count(sakila.rental.inventory_id) as 'Times_Rented'
from sakila.rental
group by sakila.rental.inventory_id
;
create view Film_rental_count as
select sakila.Inventory_rental_Count.inventory_id, sakila.Inventory_rental_Count.Times_Rented, sakila.inventory.film_id, count(sakila.inventory.film_id) as 'Film_Rental_Count'
from sakila.Inventory_rental_Count
inner join sakila.inventory on
sakila.Inventory_rental_Count.inventory_id = sakila.inventory.inventory_id
group by film_id
;
select sakila.film.title, sakila.Film_rental_count.Film_Rental_Count
from sakila.film
inner join sakila.Film_rental_count on
sakila.film.film_id = sakila.Film_rental_count.film_id
order by sakila.Film_rental_count.Film_Rental_Count DESC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
create view Business_by_employee as
select sakila.payment.staff_id, sum(sakila.payment.amount) as 'Total_Rung_Up'
from sakila.payment
inner join sakila.staff on
sakila.staff.staff_id = sakila.payment.staff_id
group by sakila.payment.staff_id
;
create view Business_by_store as
select sakila.Business_by_employee.Total_Rung_Up, sakila.staff.store_id
from sakila.Business_by_employee 
join sakila.staff on
sakila.Business_by_employee.staff_id = sakila.staff.staff_id
;
create view Business_by_address as
select sakila.Business_by_store.Total_Rung_up, sakila.store.address_id
from sakila.Business_by_store
inner join sakila.store on
sakila.Business_by_store.store_id = sakila.store.store_id
;
select sakila.address.address as 'Store', sakila.Business_by_address.Total_Rung_up as 'Money_Brought_In ($)'
from sakila.address
inner join sakila.Business_by_address on
sakila.address.address_id = sakila.Business_by_address.address_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
select * from sakila.Need_Address_Name;
select * from sakila.address;

create view Store_id_with_city_id as
select sakila.store.store_id, sakila.address.city_id
from sakila.store
inner join sakila.address on
sakila.store.address_id = sakila.address.address_id
;
create view Store_id_with_city_and_country_id as
select sakila.Store_id_with_city_id.store_id, sakila.city.city, sakila.city.country_id
from sakila.Store_id_with_city_id
inner join sakila.city on
sakila.Store_id_with_city_id.city_id = sakila.city.city_id
;
create view Store_missing_address as
select sakila.Store_id_with_city_and_country_id.store_id, sakila.Store_id_with_city_and_country_id.city, sakila.country.country
from sakila.Store_id_with_city_and_country_id
inner join sakila.country on
sakila.Store_id_with_city_and_country_id.country_id = sakila.country.country_id
;
create view Need_Address_Name as
select sakila.Store_missing_address.store_id, sakila.Store_missing_address.city, sakila.Store_missing_address.country, sakila.store.address_id
from sakila.Store_missing_address
inner join sakila.store on
sakila.Store_missing_address.store_id = sakila.store.store_id
;
select sakila.address.address as 'Store', sakila.Need_Address_Name.store_id, sakila.Need_Address_Name.city, sakila.Need_Address_Name.country, sakila.Need_Address_Name.address_id
from sakila.address
inner join sakila.Need_Address_Name on
sakila.address.address_id = sakila.Need_Address_Name.address_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
create view Price_by_inventory_id as
select sakila.rental.inventory_id, sum(sakila.payment.amount) as 'Inventory_id_sum'
from sakila.rental
inner join sakila. payment on
sakila.rental.rental_id = sakila.payment.rental_id
group by sakila.rental.inventory_id
;
create view Film_id_sumed as
select sakila.inventory.film_id, sum(sakila.Price_by_inventory_id.Inventory_id_sum) as 'Film_id_sum'
from sakila.inventory
inner join sakila.Price_by_inventory_id on
sakila.inventory.inventory_id = sakila.Price_by_inventory_id.inventory_id
group by sakila.inventory.film_id
;
create view Cat_id_sumed as 
select sakila.film_category.category_id, sum(sakila.Film_id_sumed.Film_id_sum) as 'Cat_id_sum'
from sakila.film_category
inner join sakila.Film_id_sumed on
sakila.film_category.film_id = sakila.Film_id_sumed.film_id
group by sakila.film_category.category_id
;
select sakila.category.name as 'Genre', sakila.Cat_id_sumed.Cat_id_sum as 'Revenue'
from sakila.category
inner join sakila.Cat_id_sumed on
sakila.category.category_id = sakila.Cat_id_sumed.category_id
order by sakila.Cat_id_sumed.Cat_id_sum DESC
Limit 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
select sakila.category.name as 'Genre', sakila.Cat_id_sumed.Cat_id_sum as 'Revenue'
from sakila.category
inner join sakila.Cat_id_sumed on
sakila.category.category_id = sakila.Cat_id_sumed.category_id
order by sakila.Cat_id_sumed.Cat_id_sum DESC
Limit 5
;

-- 8b. How would you display the view that you created in 8a?
select * from sakila.top_five_genres
;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres
;