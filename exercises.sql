-- 1
select count(*) as 'total' from facturas;

--2
select  * from facturas;

--3
select telefono, nombre, apellido  from clientes where provincia_cod='BA';

--4
select telefono, nombre, apellido  from clientes where provincia_cod='BA' and cliente_ref is null;

--5
select * from fabricantes where tiempo_entrega between 1 and 5;

--6
select factura_num, cliente_num, fecha_pago from facturas where fecha_pago < '2021-02-28' and fecha_pago > '2021-01-01';

--7
select *, (precio_unit + precio_unit*0.2) as 'precio_20%' from productos where fabricante_cod='CASA';

--8
select top 3 * from facturas order by fecha_pago desc;

--9
select top 1 * from fabricantes order by tiempo_entrega;

--10
select top 1 * from fabricantes where tiempo_entrega is not null order by tiempo_entrega;

--11
select concat(cliente_num, nombre, apellido) as 'formated_column' from clientes order by cliente_num offset 3 rows fetch first 5 rows  only;

--12
select count(*) as 'clients_no_phone' from clientes where telefono is null;

--13
select count(distinct provincia_cod) as 'cant_provincias' from fabricantes;

--14
select  cliente_num from facturas where cliente_num is not null group by cliente_num;
select distinct cliente_num from facturas where cliente_num is not null group by cliente_num;

--15
select * from clientes where provincia_cod='SA' or provincia_cod='JU';

--16
select * from clientes where (provincia_cod='SA' or provincia_cod='JU') and estado='I';

--17
select * from fabricantes where fabricante_cod like '%E%' and tiempo_entrega >5;

--18
select * from fabricantes where fabricante_cod like ''

