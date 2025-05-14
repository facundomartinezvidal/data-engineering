--1
select p.provincia_cod, p.provincia_desc,
       (select count(cliente_num) from clientes c where c.provincia_cod = p.provincia_cod ) as cant_clientes
       from provincias p;

--2
--con with
with cant_total as
         (select producto_cod, sum(cantidad) as cant_total from facturas_det group by producto_cod having sum(cantidad)>150)
select p.producto_cod, p.producto_desc, cant_total.cant_total
    from productos p inner join cant_total on p.producto_cod = cant_total.producto_cod;
--sin with
select p.producto_cod, p.producto_desc, cant_total.cant_total from productos p
    inner join
    (select producto_cod, sum(cantidad) as cant_total from facturas_det  group by producto_cod having sum(cantidad)>150) as cant_total
    on cant_total.producto_cod = p.producto_cod;

--3
select provincia_cod, provincia_desc from provincias p
    where provincia_cod not in (select provincia_cod from fabricantes);
--with exists
select p.provincia_cod, p.provincia_desc
from provincias p
where not exists ( select f.provincia_cod from fabricantes f  where f.provincia_cod = p.provincia_cod);

--4
select f.provincia_cod, f.tiempo_entrega  from fabricantes f
where f.provincia_cod != 'BA'
and f.tiempo_entrega <=  all(
    select tiempo_entrega from fabricantes where provincia_cod='BA'
);

--5#Mostrar el código y suma vendida de todos los fabricantes que no sean de BA que hayan
-- vendido productos por un monto mayor al de algún fabricante de ‘BA’.
WITH mayor as (SELECT f.fabricante_cod,
                      provincia_cod,
                      p.precio_unit,
                      SUM(p.precio_unit*cantidad) SUMATORIA
               FROM facturas_det d
                join   productos p
                   on d.producto_cod = p.producto_cod
                       inner JOIN fabricantes f ON p.fabricante_cod = f.fabricante_cod
               group by f.fabricante_cod, provincia_cod,
                        p.precio_unit
               ),
B AS (
    SELECT
SUMATORIA
    FROM mayor
    WHERE provincia_cod = 'BA'
    GROUP BY FABRICANTE_COD,provincia_cod
    )
SELECT b.* FROM MAYOR JOIN B ON mayor.fabricante_cod = b.fabricante_cod
where suma_2 > SUMATORIA
and b.provincia_cod != 'BA':



WITH ventas_por_fabricante AS (
    -- Calculamos la suma vendida por cada fabricante
    SELECT
        p.fabricante_cod,
        f.provincia_cod,
        SUM(fd.cantidad * fd.precio_unit) AS total_vendido
    FROM facturas_det fd
    JOIN productos p ON fd.producto_cod = p.producto_cod
    JOIN fabricantes f ON p.fabricante_cod = f.fabricante_cod
    GROUP BY p.fabricante_cod, f.provincia_cod
),
ventas_fabricantes_ba AS (
    -- Obtenemos las ventas de los fabricantes de BA
    SELECT total_vendido
    FROM ventas_por_fabricante
    WHERE provincia_cod = 'BA'
)
-- Seleccionamos fabricantes no-BA con ventas mayores a ALGÚN fabricante de BA
SELECT
    vpf.fabricante_cod,
    vpf.total_vendido
FROM ventas_por_fabricante vpf
WHERE vpf.provincia_cod != 'BA'
AND vpf.total_vendido > ANY (
    SELECT total_vendido
    FROM ventas_fabricantes_ba
);

WITH ventas_por_fabricante AS (
    -- Calculamos la suma vendida por cada fabricante
    SELECT
        p.fabricante_cod,
        f.provincia_cod,
        SUM(fd.cantidad * fd.precio_unit) AS total_vendido
    FROM facturas_det fd
    JOIN productos p ON fd.producto_cod = p.producto_cod
    JOIN fabricantes f ON p.fabricante_cod = f.fabricante_cod
    GROUP BY p.fabricante_cod, f.provincia_cod
)
SELECT DISTINCT
    vpf.fabricante_cod,
    vpf.total_vendido
FROM ventas_por_fabricante vpf
JOIN ventas_por_fabricante ba ON vpf.total_vendido > ba.total_vendido
WHERE vpf.provincia_cod != 'BA'
AND ba.provincia_cod = 'BA';


-- Seleccionar aquellos clientes cuya facturación supere el promedio facturado de todos los
-- clientes que realizaron compras.
WITH FACTURACION AS (
    SELECT AVG(fd.CANTIDAD*fd.precio_unit) AS promedio_facturado
    FROM facturas_det fd
    JOIN facturas f
        ON fd.factura_num = f.factura_num
    JOIN clientes c ON f.cliente_num = c.cliente_num
    group by fd.factura_num, c.cliente_num
)
SELECT
    DISTINCT
    cliente_num
