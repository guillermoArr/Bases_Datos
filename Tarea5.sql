/*
Tarea 5
Parte de la infraestructura es dise�ar contenedores cil�ndricos giratorios para facilitar 
la colocaci�n y extracci�n de discos por brazos automatizados. Cada cajita de Blu-Ray mide 20cm x 13.5cm x 1.5cm, 
y para que el brazo pueda manipular adecuadamente cada cajita, debe estar contenida dentro de un arn�s que cambia 
las medidas a 30cm x 21cm x 8cm para un espacio total de 5040 cent�metros c�bicos y un peso de 500 gr por pel�cula.

Se nos ha encargado formular la medida de dichos cilindros de manera tal que quepan todas las copias de los Blu-Rays 
de cada uno de nuestros stores. Las medidas deben ser est�ndar, es decir, la misma para todas nuestras stores, y en 
cada store pueden ser instalados m�s de 1 de estos cilindros. Cada cilindro aguanta un peso m�ximo de 50kg como m�ximo. 
El vol�men de un cilindro se calcula de [�sta forma.](volume of a cylinder) pir**2h

Esto no se resuelve con 1 solo query. El problema se debe partir en varios cachos y deben resolver cada uno con SQL.

La informaci�n que no est� dada por el enunciado del problema o el contenido de la BD, podr� ser establecida como 
supuestos o assumptions, pero deben ser razonables para el problem domain que estamos tratando.
*/

-- Contamos el n�mero de pel�culas en cada tienda
/*
 * select s.store_id, count(i.film_id) as tot_peliculas from store s 
	join inventory i using (store_id) group by store_id;
 */

/*
 * Dado que cada cilindro a lo m�s puede cargar 50 kg
 * y cada pel�cula con su arn�s pesa 500 gr, entonces cada cilindro puede cargar como m�ximo 100 pel�culas
 * pero esto producir�a la utilizaci�n del tope total, por lo que considero una buena medida tomar una cantidad menor 
 * y as� asegurar que no sobrepasar� el l�mite de peso o que se desgaste en menor tiempo
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
 * C�lculo de las medidas del cilindro estandar: 
 */

-- Altura:
/*
 * Ya obtuvimos que cada cilindro tendr� 88 pel�culas 
 * Sin embargo, para intentar maximizar el numero de peliculas en los cilindros, entonces pensemos que m�s all�
 * de encontrar peliculas al rededor de la circunferencia, tambi�n se apilar�n hacia arriba (verticalmente)
 * entonces dado que recibimos un n�mero tope de 88 pel�culas
 * usemos 8 niveles y en cada nivel haya 11 pel�culas
 * Como cada cajita con arnes mide 30cm x 21cm x 8cm (altura, profundidad, ancho, suponiendolas paradas)
 * apilaremos 8 peliculas entonces obtenemos 8 x 30 = 240 cm pero pensemos en poner estantes que separen cada nivel
 * de 1 cm cada una, entonces tenemos 9 cm m�s (contando el de la base) entonces altura igual a 249
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
 * Como dijimos, tendremos 8 niveles de 11 pel�culas, es decir, las 11 pel�culas se ajustan a la circunferencia, por lo tanto
 * para calcular el radio necesitamos la medida de la profundidad de la pel�cula, m�s el centro (ya que las pel�culas no pueden estar encimadas)
 * por lo tanto en el centro resulta un pol�gono de 11 lados (por ser 11 pel�culas)
 * As�, el radio de la circunferencia ser� la hipotenusa del tri�ngulo rect�ngulo entre las siguientes medidas:
 * 		- a = profundidad del arn�s (21 cm) + apotema del pol�gono del centro (dado por lado/2*tan(360/(2*num_lados))
 * 		- b = la mitad del ancho del arn�s (4 cm)
 * calculadas �stas, obtenemos que el radio = raiz(a**2 + b**2)
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
 * Nuevamente, demosle m�s espacio redondemos a 40 cm
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