--1
select count(factura_num) as 'cantidad_facturas' from facturas;

--2
select * from facturas;

--3
select cliente_num,nombre, apellido, provincia_cod from clientes where provincia_cod='BA';

--4
select cliente_num, nombre, apellido, provincia_cod, cliente_ref from clientes where provincia_cod='BA' and cliente_ref is null;

--5

