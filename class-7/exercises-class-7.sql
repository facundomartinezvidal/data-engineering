--1
select c.cliente_num, c.nombre, c.apellido, f.factura_num from clientes c
    inner join dbo.facturas f on c.cliente_num = f.cliente_num;

--2
select c.cliente_num, c.nombre, c.apellido, f.factura_num from clientes c
    left join dbo.facturas f on c.cliente_num = f.cliente_num;

--3
select c.cliente_num, c.nombre, c.apellido, f.factura_num from clientes c
    full outer join dbo.facturas f on c.cliente_num = f.cliente_num;

--4
select
    c.cliente_num,
    concat(c.nombre, ',', c.apellido) as nombre_completo,
    c.provincia_cod,
    sum((fd.cantidad * fd.precio_unit)) as monto_total
    from clientes c
    inner join facturas f on c.cliente_num = f.cliente_num
    inner join facturas_det fd on f.factura_num = fd.factura_num
where c.provincia_cod = 'BA'
group by c.nombre, c.apellido, c.provincia_cod, c.cliente_num
having sum((fd.cantidad * fd.precio_unit)) > 15000;

--5
select
    c.cliente_num,
    sum(fd.precio_unit * fd.cantidad) as monto_total,
    avg(fd.precio_unit * fd.cantidad) as monto_promedio,
    count(distinct f.factura_num)
    from clientes c
    inner join facturas f on c.cliente_num = f.cliente_num
    inner join facturas_det fd on f.factura_num = fd.factura_num
    group by c.cliente_num
    having count(distinct f.factura_num) > 2
    order by sum(fd.precio_unit * fd.precio_unit) desc;

--6
select
    c.cliente_num,
    c.nombre,
    c.apellido,
    p.producto_cod,
    p.producto_desc,
    sum(fd.cantidad * fd.precio_unit)
    from clientes c
    inner join facturas f on c.cliente_num = f.cliente_num
    inner join facturas_det fd on f.factura_num = fd.factura_num
    inner join productos p on fd.producto_cod = p.producto_cod
    group by c.cliente_num, c.nombre, c.apellido, p.producto_desc, p.producto_cod
    order by c.cliente_num, p.producto_cod, sum(fd.cantidad * fd.precio_unit) desc;

--7
select
    c.cliente_num,
    c.nombre,
    c.apellido,
    c.cliente_ref,
    c2.cliente_num as cliente_num_ref,
    c2.nombre as nombre_ref,
    c2.apellido as apellido_ref
    from clientes c
    inner join clientes c2 on c2.cliente_num = c.cliente_ref;

--8
select distinct p.producto_cod, p.producto_desc,
    case when fd.producto_cod is not null then 'comprado' else 'no_comprado' end as 'leyenda'
    from productos p
    left join facturas_det fd on p.producto_cod = fd.producto_cod
;

--9
select distinct p.producto_cod, p.producto_desc, f.fabricante_cod
    from productos p
    inner join facturas_det fd on p.producto_cod = fd.producto_cod
    inner join fabricantes f on p.fabricante_cod = f.fabricante_cod
where f.fabricante_cod = 'CASA';

--10
select distinct p.producto_cod, p.producto_desc, f.fabricante_cod
    from productos p
    left join facturas_det fd on p.producto_cod = fd.producto_cod
    inner join fabricantes f on p.fabricante_cod = f.fabricante_cod
where f.fabricante_cod = 'EXPO' and fd.producto_cod is null;

--12
select fd.producto_cod
    from facturas_det fd
    inner join facturas f on fd.factura_num = f.factura_num
where f.cliente_num = 103
intersect
select fd.producto_cod
    from facturas_det fd
    inner join facturas f on fd.factura_num = f.factura_num
where f.cliente_num = 114
intersect
select fd.producto_cod
    from facturas_det fd
    inner join facturas f on fd.factura_num = f.factura_num
where f.cliente_num = 106;






