--1
select nombre, apellido, f.cliente_num, factura_num from clientes inner join dbo.facturas f on clientes.cliente_num = f.cliente_num and clientes.cliente_num = f.cliente_num;

--2?
select nombre, apellido, f.cliente_num, factura_num from clientes inner join dbo.facturas f on clientes.cliente_num = f.cliente_num and clientes.cliente_num = f.cliente_num ;

--3
select nombre, apellido, f.cliente_num, factura_num from clientes inner join dbo.facturas f on clientes.cliente_num = f.cliente_num and clientes.cliente_num = f.cliente_num;

--4
select nombre, apellido, f.cliente_num, factura_num,
       case when f.cliente_num is null then 'no asociado'  else 'asociado'
           END as cliente_asociado
from clientes left join dbo.facturas f on clientes.cliente_num = f.cliente_num

--5
SELECT c.nombre, c.apellido, c.cliente_num, COUNT(f.factura_num) AS total_facturas
FROM clientes c
INNER JOIN facturas f ON c.cliente_num = f.cliente_num
GROUP BY c.nombre, c.apellido, c.cliente_num
HAVING COUNT(f.factura_num) > 2;

SELECT DISTINCT
    C.CLIENTE_NUM ,
    NOMBRE,
    APELLIDO, -- PRODUCTO_COD, producto_desc,
    SUM(FD.cantidad*FD.factura_num) AS TOTAL_FACTURAS
FROM clientes C LEFT JOIN facturas F ON C.cliente_num = F.cliente_num
LEFT JOIN facturas_det FD ON F.factura_num = FD.factura_num
GROUP BY C.CLIENTE_NUM,NOMBRE,APELLIDO, cantidad

