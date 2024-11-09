/*************************
********** 01 **********
SELECT, OPERACIONES BÁSICAS Y FILTROS
Vamos a entender cómo funciona la SELECT a nivel básico.
El lenguaje SQL es case insensitive, por lo que puede escribirse tanto en mayúsculas como en minúsculas, incluidos los nombres de las columnas en MySQL (depende del motor de BBDD).

Lista el apellido y nombre de los empleados (formato Apellido, Nombre en un mismo campo), así como su email y cargo.
- Tabla Employees
**************************/
SELECT concat(lastname, ", ", firstname) as nombre_completo,email,jobtitle
from employees
;
/*************************
********** 02 **********
Ordénalos por orden alfabético de apellido, nombre y el e-mail
**************************/
SELECT concat(lastname, ", ", firstname) as nombre_completo,email,jobtitle
from employees
order by lastname, firstname, email
;
/*************************
********** 03 **********
Lista los productos (código, nombre, línea, escala y cantidad) que corresponden a la escala 1:18
**************************/
SELECT * FROM 
PRODUCTS;
SELECT productcode, productname, productline, productScale, quantityInstock
from products
Where productScale = "1:18"
;

/*************************
********** 04 **********
Y de los que son escala 1:18, ahora busca los que pertenecen al proveedor 
"Classic Metal Creations"
**************************/
SELECT productcode, productname, productline, productScale, quantityInstock,productvendor
from products
Where productScale = "1:18" 
and productvendor = "Classic Metal Creations"
;

/*************************
********** 06 **********
De los productos, lista únicamente aquellos que sabemos que son "Corvette" por su nombre y ordénalos por cantidad en stock ascendiente.
La cláusula LIKE permite realizar búsquedas por patrones (cuidado con la versión de MySQL que puede que algunos patrones no estén todavía habilitados).
- % significa cualquier carácter (p.e. n% cualquier palabra que empiece por n)
- _ significa que debe existir un carácter cualquiera (p.e. l__ sería los, las, les, lis...)
A partir de aquí se pueden combinar estas "wildcards".
Por otro lado, tenemos las búsquedas case sensitive/in-sensitive, es decir, búsquedas que deben respetar las mayúsculas o no. Puede ser que no queramos interpretar U como u. Los tipos de fuentes NO binarios, son no sensitivas, mientras que los tipos binarios sí que lo son. Si queremos que sea sensitiva, deberemos forzar el tipo de dato en la búsqueda a través del operador BINARY.
- Utilizar BINARY antes de la operación lógica (p.e. LIKE BINARY "maYúsCulas")
Eso sí, si un campo es susceptible de requerir búsquedas sensibles, lo mejor es alterar su definición para que sea del tipo binaria.
**************************/
SELECT *
from products
where lower(productname) like '%CORVETTE%'
;
/*************************
********** 07 **********
Listar los proveedores/fabricantes (vendors) únicos de los productos ordenados alfabéticamente
**************************/
SELECT 
Distinct productVendor
from products
order by productVendor
;
/*************************
********** 08 **********
Listar los proveedores postales de los clientes (únicos)
**************************/
SELECT distinct postalcode
FROM customers
;
-- Forma de ver registros nulos de postal code
select sum(1),count(1),count(1)
from customers
where postalCode is null 
;
/*********************************** 09 **********
Cuenta los códigos postales únicos de los clientes
**************************/
SELECT count(distinct customernumber) as codigos_unicos 
from customers
;
/*************************
********** 10 **********
Cuenta el número total de clientes
**************************/
SELECT count(distinct customernumber) as codigos_unicos 
from customers ;

-- Otra forma de hacerlo con mas funciones de agregacion
SELECT count(distinct customernumber) as '5',
count(customernumber) as '1',
sum(1) as '2' ,count(*) as '3'
from customers
;
/*************************
********** 11 **********
Cuenta el número de clientes con un límite de crédito entre 60.000 y 70.000
**************************/
SELECT *
from customers
where creditlimit between 60000 and 70000
order by creditLimit
;
-- Otra forma de hacerlo es:
SELECT * 
from customers 
where creditlimit<=70000 AND creditlimit >=60000
order by creditlimit
;
/*************************
********** 12 **********
Lista las ciudades y países únicos en los que la empresa tiene clientes, 
por orden ascendente de país y ciudad
Concatena la ciudad y el país con una coma.
**************************/
SELECT distinct city, country, concat(trim(city),',' ,country) as Ciudad_pais 
from customers 
ORDER BY city,country
;
/*************************
********** 13 **********
Cuenta el número de clientes que han realizado un pedido o más
¿Cuántas formas hay de hacerlo?
**************************/
SELECT count(distinct customernumber)
from customers 
where customernumber in
(select customernumber from orders)
;
-- ---------	 ---------------------------------------
-- Contar el número de clientes que han hecho pedidos: (Coincidentes)
SELECT count(distinct(o.customerNumber)) AS Numero_Pedidos
FROM customers c
inner JOIN orders o ON c.customerNumber = o.customerNumber
;
-- Contar los pedidos de cada cliente
SELECT c.customerNumber, COUNT(o.orderNumber) AS total_pedidos
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber;


-- ----------------------------
SELECT customernumber, count(*) as Pedidos_realizados
FROM orders
group by customernumber
;
-- Otra forma de hacerlo: Haciendo una subconsulta para contar los pedidos de cada cliente dentro del SELECT
SELECT Customernumber,
(Select count(*)
from orders o2
Where o1.customerNumber = o2.customerNumber) as Pedidos_realizados
FROM orders o1
group by Customernumber
;


/*************************
********** 14 **********
Lista los clientes que NO han realizado ningún pedido y que NO son de USA.
- ¿se puede hacer con las mismas opciones que antes?
- ¿hay alguna otra manera de hacerlo más allá que con el IN?
**************************/
-- 2. LEFT JOIN: Quieres ver todo en la tabla de la izquierda, aunque no tenga coincidencias en la derecha
-- Cuándo usarlo: Cuando quieres ver todos los datos de una tabla (izquierda), y solo los datos coincidentes de la otra (derecha).
-- Probando hacerlo con Left Join
Select c.customerNumber,c.country,o.orderdate
from customers c
left join orders o on c.customerNumber = o.customerNumber
where o.orderdate is null 
and c.country != 'USA'
;
-- -------------------------------
SELECT *
from customers  
where customernumber
 not in
 (select customernumber from orders)
and country not in ('USA')
;

/*************************
********** 15 **********
Listar los pedidos que se han hecho en el 2005 y que ya han sido enviados

1. Investigar qué status existen y ver si pueden sernos útiles
2. Por curiosidad, miremos el mínimo y máximo de fechas de los pedidos
3. Veamos si existen otros campos que puedan sernos de utilidad
4. Decidamos cómo hacer la búsqueda solicitada
**************************/
-- Listar los pedidos que se han hecho en el 2005 y que ya han sido enviados

SELECT ordernumber, shippedDate, status
from orders o
Where orderdate like '2005%' 
and status = 'Shipped'
;
-- 2. Año mino y Maximo de Pedido
select customernumber, min(year(orderDate)) as Año_Minimo_de_pedido, max(year(orderDate)) as Año_Maximo_de_pedido
from orders
group by customernumber
;
/*************** GROUP BY *******************/

/*************************
********** 16 **********
Calcular el número de empleados por cargo
- Ordenado ascendente por nombre del cargo
**************************/
SELECT jobTitle, count(employeeNumber) as Cuenta_empleados
from employees
group by jobTitle
;
-- Solucion:
SELECT jobtitle, sum(1),count(employeenumber)
from employees
group by jobtitle
;
/*************************
********** 17 **********
Número de empleados por cargo ordenados de más a menos número
**************************/
SELECT jobtitle,count(employeenumber) as Numero_de_Empleados
from employees
group by jobtitle
order by Numero_de_Empleados DESC
;

/*************************
********** 18 **********
Listar el número de proveedores (vendors) que tenemos, así como el número de productos distintos
-- y el stock total para cada proveedor, ordenador por nombre del proveedor.
- Formatear la cantidad para que aparezca el punto de miles
-- y con céntimos de euro vía coma (FORMAT(num,numDec,locale) 'es_ES'
**************************/
SELECT productVendor, count(productCode) as Productos_Distintos,
format(sum(quantityInStock),0, 'de_DE') as suma_stock_total
from products
group by productVendor
order by productVendor
;

/*************************
********** 19 **********
Lista de proveedores (vendors) con más de 35000 unidades en stock ordenados por nombre de proveedor
**************************/
SELECT productVendor, sum(quantityInStock) as Stock_Total
from products
group by productVendor
having Stock_Total > 35000
order by productVendor
;

/*************************
********** 20 **********
Listar el número de pedidos por año y status que NO han sido enviados
**************************/
SELECT ordernumber, year(orderdate) as Año_Pedido,status
from orders
Where status !='Shipped'
order by ordernumber
;
-- Otra forma de hacerlo:
SELECT YEAR(orderdate) AS Año_Pedido, status, COUNT(*) AS Numero_Pedidos
FROM orders
WHERE status != 'Shipped'
GROUP BY YEAR(orderdate), status
ORDER BY Año_Pedido;
/*************************
********** 21 **********
Número de clientes por país para países con más de 5 clientes, de más cantidad a menos
**************************/
select count(*) as Clientes, country
from customers 
group by country
having Clientes >5
order by Clientes Desc
;

/*************************
********** 22 **********
Promedio de límite de crédito por país del cliente para los clientes que tienen límite > 0
- Tabla customers
- Hacer que el promedio sea un número entero
- Ordenar de menor a mayor crédito promedio
- Incluir el número de clientes que forman parte de ese promedio
**************************/
-- Forma con WHERE Y GROUP BY
SELECT count(*) AS Total_clientes , country , round(avg(creditLimit), 0) as Credito_Promedio
from customers
WHERE creditLimit > 0
group by country
order by Credito_Promedio 
;
/************************* JOIN ***************************/

/*************************
********** 23 **********
Lista cada empleado (nombre, apellido), con la ciudad y código postal de su oficina.
**************************/
SELECT concat(e.firstname, ' ', e.lastname) as CONCAT_NAME , o.city, o.postalCode
from employees e
LEFT join offices o
on o.officecode = e.officeCode
;

/*************************
********** 24 **********
De los anteriores, selecciona sólo los que están en la oficina de San Francisco.
**************************/
SELECT concat(e.firstname, ' ', e.lastname) as CONCAT_NAME , o.city, o.postalCode
from employees e
left join offices o
on o.officecode = e.officeCode
Where o.city = 'San Francisco'
;

/*************************
********** 25 **********
Lista los clientes y su país, que no han hecho ningún pedido
- Ahora con la unión correspondiente
- Ordena por país
**************************/
SELECT c.customerNumber,o.customerNumber,c.country
from customers c
left join orders o
on o.customernumber = c.customernumber
Where o.customerNumber is Null
order by c.country
;
/*************************
********** 26 **********
Ranking de productos más vendidos por año y por país
- Incluir el nombre de la familia de cada producto
**************************/
SELECT p.productCode,pl.productLine,
sum(od.quantityOrdered) as Total_Sales,
year(o.orderdate) as Año,
c.country
from products p
inner join productlines pl
ON pl.productLine = p.productLine
inner join orderdetails od
on p.productcode = od.productCode
inner join orders o
on o.ordernumber = od.orderNumber
inner join customers c
on o.customerNumber = c.customerNumber
group by p.productCode,pl.productLine,
year(o.orderdate),
c.country
order by Total_Sales DESC
LIMIT 5
; 

/*************************
                WITH
********** 27 **********
Calcula el -- número promedio de productos, --promedio de unidades--
y el --gasto medio-- --por pedido-- de los --clientes de USA--.
**************************/
With Tabla_productos AS (
Select count(p.productCode) as Suma_Productos
from products p
),
Tabla_Unidades AS (
Select count(quantityOrdered) as Suma_Unidades
from orderdetails
),
Tabla_Gasto_Medio_USA AS (
Select avg(od.quantityOrdered * od.Priceeach) as Gasto_total
from orderdetails od
Inner Join orders o on od.orderNumber = o.orderNumber
Inner Join customers c on o.customerNumber = c.customerNumber
Where c.country = 'USA'
)
Select
(Select avg(Suma_Productos) from Tabla_productos) as Promedio_Productos,
(Select avg(Suma_Unidades) from Tabla_Unidades) as Promedio_Unidades,
(Select Gasto_total  from Tabla_Gasto_Medio_USA) as Gasto_Promedio;

/*************************
********** 28 **********
Qué clientes nos deben dinero y cuánto
- Tenemos que saber cuánto hemos facturado a cada cliente
- Tenemos que saber cuánto ha pagado cada cliente
**************************/
-- - Tenemos que saber cuánto hemos facturado a cada cliente
SELECT c.customerNumber,
       ( 
           (SELECT SUM(od.quantityOrdered * p.buyPrice)
            FROM products p
            INNER JOIN orderdetails od ON p.productCode = od.productCode
            INNER JOIN orders o ON od.orderNumber = o.orderNumber
            WHERE o.customerNumber = c.customerNumber
           ) - 
           (SELECT SUM(py.amount)
            FROM payments py
            WHERE py.customerNumber = c.customerNumber
           )
       ) AS Deben_Dinero
FROM customers c;
/*************************
********** 29 **********
Y ahora con la cláusula WITH
**************************/
WITH Facturacion_Cliente AS (
Select c.customerNumber, sum(od.quantityOrdered * p.buyPrice) AS Facturacion
from products p 
Inner Join orderdetails od on p.productCode = od.productCode
Inner Join orders o on od.orderNumber = o.orderNumber
Inner Join customers c on o.customerNumber = c.customerNumber
group by c.customerNumber
),
Pago_por_Cliente AS (
Select c.customerNumber, sum(py.amount) as Pago_Total 
from customers c 
inner join payments py on c.customerNumber = py.customerNumber
group by c.customerNumber
),
Clientes_Deudores AS ( 
Select c.customerNumber,(Facturacion - Pago_Total) as Deben_Dinero
from customers c
Inner Join Facturacion_Cliente FC on c.customerNumber = FC.customerNumber
Inner Join Pago_por_Cliente PC on FC.customerNumber = PC.customerNumber
group by c.customerNumber
)
Select sum(Deben_Dinero) as DEUDA_TOTAL
from customers c 
Inner Join Clientes_Deudores CD on c.customerNumber = CD.customerNumber 
;
/*************************
********** 30 **********
				  Query Total
-- customernumber: que pedidos ha realizado, que productos ha comprado,
detalles de productos comprados, quien es su vendedor, y su ubicacion.
**************************/
Select O.customerNumber, O.orderNumber,E.employeeNumber, concat(E.firstName,', ',E.lastName) as Nombre_Empleado,
OD.productcode,P.productDescription,concat(C.city, ', ',OS.country) as Ubicacion_Empleado
from customers C
Inner Join payments PY ON C.customerNumber = PY.customerNumber
Inner Join orders O ON C.customerNumber = O.customerNumber
Inner Join orderdetails OD ON O.orderNumber = OD.ordernumber
Inner Join products P ON OD.productCode = P.productCode
Inner Join productlines PL ON P.productLine = PL.productLine
Inner Join employees E ON C.contactFirstName = E.firstName
Inner Join offices OS ON E.officeCode = OS.officeCode
group by O.customerNumber,O.orderNumber, OD.productcode,P.productDescription,E.employeeNumber
order by O.customerNumber,OD.productcode,O.orderNumber
;