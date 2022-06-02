/*
Tarea 5
Parte de la infraestructura es diseñar contenedores cilíndricos giratorios para facilitar 
la colocación y extracción de discos por brazos automatizados. Cada cajita de Blu-Ray mide 20cm x 13.5cm x 1.5cm, 
y para que el brazo pueda manipular adecuadamente cada cajita, debe estar contenida dentro de un arnés que cambia 
las medidas a 30cm x 21cm x 8cm para un espacio total de 5040 centímetros cúbicos y un peso de 500 gr por película.

Se nos ha encargado formular la medida de dichos cilindros de manera tal que quepan todas las copias de los Blu-Rays 
de cada uno de nuestros stores. Las medidas deben ser estándar, es decir, la misma para todas nuestras stores, y en 
cada store pueden ser instalados más de 1 de estos cilindros. Cada cilindro aguanta un peso máximo de 50kg como máximo. 
El volúmen de un cilindro se calcula de [ésta forma.](volume of a cylinder) pir**2h

Esto no se resuelve con 1 solo query. El problema se debe partir en varios cachos y deben resolver cada uno con SQL.

La información que no esté dada por el enunciado del problema o el contenido de la BD, podrá ser establecida como 
supuestos o assumptions, pero deben ser razonables para el problem domain que estamos tratando.
*/

-- Contamos el número de películas en cada tienda
/*
 * select s.store_id, count(i.film_id) as tot_peliculas from store s 
	join inventory i using (store_id) group by store_id;
 */

/*
 * Dado que cada cilindro a lo más puede cargar 50 kg
 * y cada película con su arnés pesa 500 gr, entonces cada cilindro puede cargar como máximo 100 películas
 * pero esto produciría la utilización del tope total, por lo que considero una buena medida tomar una cantidad menor 
 * y así asegurar que no sobrepasará el límite de peso o que se desgaste en menor tiempo
 * establezcamos entonces que almacenaremos 12 peliculas menos que el tope
 */
/*
 * with contador as(
	select s.store_id, count(i.film_id) as tot_peliculas from store s 
		join inventory i using (store_id) group by store_id	
	)
	select store_id, tot_peliculas, ceil(tot_peliculas/((50000/500)-12.00)) as num_cilindros
		from contador;
 */


/* 
 * Este query nos regresa la cantidad de cilindros necesarios por tienda para que soporten la medida especificada
 * 
 * Cálculo de las medidas del cilindro estandar: 
 */

-- Altura:
/*
 * Ya obtuvimos que cada cilindro tendrá 88 películas 
 * Sin embargo, para intentar maximizar el numero de peliculas en los cilindros, entonces pensemos que más allá
 * de encontrar peliculas al rededor de la circunferencia, también se apilarán hacia arriba (verticalmente)
 * entonces dado que recibimos un número tope de 88 películas
 * usemos 8 niveles y en cada nivel haya 11 películas
 * Como cada cajita con arnes mide 30cm x 21cm x 8cm (altura, profundidad, ancho, suponiendolas paradas)
 * apilaremos 8 peliculas entonces obtenemos 8 x 30 = 240 cm pero pensemos en poner estantes que separen cada nivel
 * de 1 cm cada una, entonces tenemos 9 cm más (contando el de la base) entonces altura igual a 249
 * redondeamos a 250
 */ 
 
/*
 * with contador as(
	select s.store_id, count(i.film_id) as tot_peliculas from store s 
		join inventory i using (store_id) group by store_id	
),
cont_cilindros as(
	select store_id, tot_peliculas, ceil(tot_peliculas/((50000/500)-12.00)) as num_cilindros
		from contador;
)
select store_id, tot_peliculas, num_cilindros, 30 * 8 + 10 as altura_cilindro_cm
	from cilindros;
 */


-- Radio:
/*
 * Como dijimos, tendremos 8 niveles de 11 películas, es decir, las 11 películas se ajustan a la circunferencia, por lo tanto
 * para calcular el radio necesitamos la medida de la profundidad de la película, más el centro (ya que las películas no pueden estar encimadas)
 * por lo tanto en el centro resulta un polígono de 11 lados (por ser 11 películas)
 * Así, el radio de la circunferencia será la hipotenusa del triángulo rectángulo entre las siguientes medidas:
 * 		- a = profundidad del arnés (21 cm) + apotema del polígono del centro (dado por lado/2*tan(360/(2*num_lados))
 * 		- b = la mitad del ancho del arnés (4 cm)
 * calculadas éstas, obtenemos que el radio = raiz(a**2 + b**2)
 */
/*
 * with cateto1 as(
	select 21+(8/(2*tan(pi()/11))) as a
)
select sqrt(power(a,2) + power(4,2))
	from cateto1;
 */

 
/*
 * Resultado:35 cm aprox 
 * Nuevamente, demosle más espacio redondemos a 40 cm
 */

with contador as(
	select s.store_id, count(i.film_id) as tot_peliculas from store s 
		join inventory i using (store_id) group by store_id	
),
cont_cilindros as(
	select store_id, ceil(tot_peliculas/((50000/500)-12.00)) as num_cilindros from contador
),
altura as(
	select store_id, 30 * 8 + 10 as altura_cilindro_cm from cont_cilindros
),
cateto1 as(
	select store_id, 21+(8/(2*tan(pi()/11))) as a from altura
)
select store_id, tot_peliculas, num_cilindros, altura_cilindro_cm, round((sqrt(power(a,2) + power(4,2)))) + 5 as radio_cilindro_cm
from cateto1 join altura using (store_id) join cont_cilindros using (store_id) join contador using (store_id);