--1
select p.provincia_cod, p.provincia_desc,
    (select count(*) from clientes c where c.provincia_cod = p.provincia_cod)
    as cant_clientes
from provincias p;

--2
select p.producto_cod, p.producto_desc, cant_total.total_vendidas from productos p
inner join (
        select fd.producto_cod, sum(fd.cantidad) as total_vendidas
        from facturas_det fd group by fd.producto_cod
        having sum(fd.cantidad) > 150
        ) as cant_total
    on p.producto_cod = cant_total.producto_cod
;

--3
select p.provincia_cod, p.provincia_desc
from provincias p
where p.provincia_cod in (select f.provincia_cod from fabricantes f);

--4
select f.fabricante_cod, f.tiempo_entrega, f.provincia_cod
    from fabricantes f
where provincia_cod not in ('BA')
and f.tiempo_entrega <= all (select f2.tiempo_entrega from fabricantes f2);

--5
select f.fabricante_cod, sum(fd.cantidad * fd.precio_unit)
    from fabricantes f
    inner join productos p on f.fabricante_cod = p.fabricante_cod
    inner join facturas_det fd on fd.producto_cod = p.producto_cod
where provincia_cod not in ('BA')
group by f.fabricante_cod
having sum(fd.cantidad * fd.precio_unit) > any
       (select sum(fd.cantidad * fd.precio_unit)
            from fabricantes f
            inner join productos p on f.fabricante_cod = p.fabricante_cod
            inner join facturas_det fd on fd.producto_cod = p.producto_cod
            where provincia_cod in ('BA')
            group by f.fabricante_cod
       )

--6
select c.cliente_num, sum(fd.cantidad * fd.precio_unit)
    from clientes c
    inner join facturas f on f.cliente_num = c.cliente_num
    inner join facturas_det fd on fd.factura_num = f.factura_num
group by c.cliente_num
having sum(fd.cantidad * fd.precio_unit) > (
        select sum(facturas_det.cantidad * facturas_det.precio_unit) / count(distinct f.cliente_num)
            from facturas_det
            inner join facturas f on facturas_det.factura_num = f.factura_num
    )

--7
select p.producto_cod, p.producto_desc
    from productos p
where not exists(select fd.producto_cod  from facturas_det fd where fd.producto_cod = p.producto_cod );

select p.producto_cod, p.producto_desc from productos p
where p.producto_cod not in (select fd.producto_cod from facturas_det fd);

--8
select distinct f.cliente_num
    from facturas f
    inner join facturas_det fd on fd.factura_num = f.factura_num
    inner join productos p on p.producto_cod = fd.producto_cod
where p.fabricante_cod = 'DOTO';

--9
select c.cliente_num, c.nombre ,c.apellido
    from clientes c
where c.cliente_num not in (
    select f.cliente_num
        from facturas f
        inner join facturas_det fd on f.factura_num = fd.factura_num
        inner join productos p on p.producto_cod = fd.producto_cod
    where p.fabricante_cod = 'DOTO'
    )

--10
select c.cliente_num from clientes c
where not exists(
    select p.producto_cod from productos p where p.fabricante_cod = 'DOTO'
    except
    select p2.producto_cod from facturas f
            inner join facturas_det fd on f.factura_num = fd.factura_num
            inner join productos p2 on fd.producto_cod = p2.producto_cod
            where f.cliente_num = c.cliente_num
)

--12
