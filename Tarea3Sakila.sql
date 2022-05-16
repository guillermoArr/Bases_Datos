--Tarea 3 de Sakila 
--Guillermo Arrredondo 

/*Usando la BD de Sakila, y en un script de SQL separado, y en su propio repo de Github, 
 * escribir los queries necesarios y suficientes para dar respuesta a las siguientes preguntas:
 * 
 * C�mo obtenemos todos los nombres y correos de nuestros clientes canadienses para una campa�a?
 * Qu� cliente ha rentado m�s de nuestra secci�n de adultos?
 * Qu� pel�culas son las m�s rentadas en todas nuestras stores?
 * Cu�l es nuestro revenue por store?
 * 
 * Timestamp l�mite de entrega: Lunes 16 de Mayo, a las 12:59:59 del medio d�a.
 */

 -- C�mo obtenemos todos los nombres y correos de nuestros clientes canadienses para una campa�a?

select c.first_name || ' ' || c.last_name as name, c.email from customer c 
join address a using(address_id) join city c2 using(city_id) join country c3 using(country_id)
where c.activebool -- en realidad esto no afecta en nada en este caso, pero me parece mas logico buscar aquellos que sigan activos actualmente 
group by customer_id, c3.country_id 
having c3.country = 'Canada';

/*
 * 
 * select cl."name" , c.email  from customer_list cl join customer c on(customer_id = id) where cl.country = 'Canada';
 */

-- Qu� cliente ha rentado m�s de nuestra secci�n de adultos?
select c.customer_id, c.first_name || ' ' || c.last_name as name, count(f.film_id) 
from rental r join inventory i using (inventory_id) join customer c using(customer_id) join film f using(film_id)
group by c.customer_id, f.rating 
having f.rating = 'NC-17' 
order by 3 desc
limit 3;


-- Qu� pel�culas son las m�s rentadas en todas nuestras stores?
/*
 * Yo considero m�s importante entender esta pregunta como las peliculas mas rentadas en cada tienda, pues esto ofrece mayor relevancia 
 * para las respectivas tiendas; sin embargo, tambi�n puede ser importante conocer la pelicula de mayor renta entre ambas tiendas, por eso 
 * realizamos un distinct on y un rollup que garantiza que tomara en cuenta primero los titulos por tienda y despu�s unicamente el titulo,
 * como el distinct on considerara el null como un dato distinto obtendremos tambien la pelicula de mayor renta en general
 */
/*
 * select distinct on (store_id) store_id as store, count(f.film_id), f.title
 * from rental r join inventory i using (inventory_id) join film f using (film_id)
 * group by film_id, store_id 
 * order by 1,2 desc;
 */
select distinct on (store_id) store_id , count(f.title), f.title
from rental r join inventory i using(inventory_id) join film f using(film_id)
group by rollup(f.title, store_id)
having f.title is not null
order by 1, 2 desc;

-- Cu�l es nuestro revenue por store?
/*
 * Pens� ir un paso mas y buscar responder el revenue por store en cada a�o, as�o podemos contabilizar todos los ingresos por su correspondiente
 * origen; asimismo decido hacerlo por rollup para conseguir los ingresos de la tienda en total, y de ambas tiendas en total. 
 */
select store_id, sum(p.amount) as revenue, extract(year from p.payment_date) as payment_year
from rental r join payment p using (rental_id) join inventory i using(inventory_id) join store s using (store_id)
group by rollup(store_id, payment_year);
