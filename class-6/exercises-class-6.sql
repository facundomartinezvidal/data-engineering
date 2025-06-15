--1
select count(*) as cant_facturas from facturas;

--2
select * from facturas;

--3
select cliente_num, nombre, apellido, provincia_cod  from clientes where provincia_cod = 'BA';

--4
select cliente_num, nombre, apellido, cliente_ref  from clientes where cliente_ref is null;

--5
select * from fabricantes where tiempo_entrega > 1 and tiempo_entrega < 6;

--6
select * from facturas where fecha_pago between '2021-01-01' and '2021-02-28';

--7
select *, (precio_unit * 1.2) as precio_incrementado from productos where fabricante_cod = 'CASA';

--8
select top 3 * from facturas where fecha_pago is not null order by fecha_pago desc;

--9
select top 1 * from fabricantes order by tiempo_entrega;

--10
select top 1 * from fabricantes where tiempo_entrega is not null order by tiempo_entrega;

--11
select cliente_num, concat(nombre, ' ', apellido) as nombre_completo, empresa
from clientes order by cliente_num
offset 3 rows fetch next 5 rows only;

--12
select count(*) as clientes_no_telefono from clientes where telefono is null;

--13
select count(distinct provincia_cod) as provincias  from fabricantes;

--14
select distinct cliente_num from facturas;

--15
select * from clientes where provincia_cod = 'SA' or provincia_cod = 'JU';

--16
select * from clientes where provincia_cod in ('SA', 'JU') and  estado = 'I';

--17
select * from fabricantes where fabricante_cod like '%E%';

--18
select * from fabricantes where fabricante_nom like '_[e-j]%'

--19
select *, (cantidad * precio_unit) as precio_total from facturas_det;

--20
select count(factura_num) cant, min(fecha_emision) primera, max(fecha_emision) ultima from facturas

--21
select factura_num, sum( distinct precio_unit * cantidad) as precio_total from facturas_det group by factura_num;

--22
select provincia_cod, count(distinct cliente_num) as clientes from clientes group by provincia_cod;

--23
select sum(precio_unit * cantidad) / count(DISTINCT factura_num) promedio from facturas_det;

--24
select cliente_num, count(cliente_num)  from facturas  where cliente_num > 108 group by cliente_num;

--25
select cliente_num, count(cliente_num) as cant_facturas from facturas  where cliente_num > 108 group by cliente_num having count(cliente_num) > 2;

--26
select  nombre, apellido, coalesce(telefono, 'sin telefono') from clientes;

select  nombre, apellido, case when telefono is not null then telefono else 'sin telefono' end from clientes;

--27
select nombre, apellido, case when domicilio is not null then domicilio else coalesce(telefono, 'no datos') end from clientes

select nombre, apellido, coalesce(domicilio, telefono, 'no datos') AS domicilio from clientes;

--28
select fabricante_cod, fabricante_nom,
       case
           when tiempo_entrega = 5 then 'normal'
           when tiempo_entrega is null  then 'desconocido'
           when tiempo_entrega < 5 then 'rapida'
           when tiempo_entrega > 5 then 'lenta'
        end as tiempo_entrega  from fabricantes;


--29
select factura_num, avg(cantidad * precio_unit)  from facturas_det group by factura_num order by avg(cantidad * precio_unit) desc;
