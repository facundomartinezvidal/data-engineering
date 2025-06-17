--1
select factura_num, fecha_emision, dbo.get_day(fecha_emision) as dia from facturas where fecha_pago is null;

create function get_day(@fecha date)
returns varchar(50)
as
begin
    declare @number_day int
    declare @day varchar(50)

    set @number_day = datepart(weekday, @fecha)

    set @day =
        case
            when @number_day = 1 then 'Domingo'
            when @number_day = 2 then 'Lunes'
            when @number_day = 3 then 'Martes'
            when @number_day = 4 then 'Miercoles'
            when @number_day = 5 then 'Jueves'
            when @number_day = 6 then 'Viernes'
            else 'Sabado' end
    return @day
end;

--2
select fabricante_cod, dbo.get_products(fabricante_cod),
        case when exists(
                  select 1 from fabricantes f
                      join productos p on f.fabricante_cod = p.fabricante_cod
                      join facturas_det fd on p.producto_cod = fd.producto_cod
                  where f.fabricante_cod = f2.fabricante_cod
                  )
        then 'posee_ventas' else 'no_posee_ventas' end as ventas

       from fabricantes f2

select 1
from productos p
    inner join facturas_det fd on fd.producto_cod = p.producto_cod
    inner join fabricantes f on p.fabricante_cod = f.fabricante_cod
where f.fabricante_cod = 'CASA'

create function get_products(@fabricante_cod varchar(50)) returns varchar(100)
as
    begin
        declare @producto_desc varchar(30)
        declare @productos_array varchar(100)
        set @productos_array = ''
        declare cursor_productos cursor for select producto_desc from productos where fabricante_cod = @fabricante_cod
        open cursor_productos
        fetch cursor_productos into @producto_desc
        while (@@fetch_status = 0)
            begin
                if @productos_array = ' '
                    set @productos_array = @producto_desc
                else
                    set @productos_array = @productos_array + ',' + @producto_desc
                fetch cursor_productos into @producto_desc
            end
        close cursor_productos
        deallocate cursor_productos
        if @productos_array = ''
            set @productos_array = '-'
        return @productos_array
    end


--3
create table compras_clientes (
    client_num int primary key,
    cant_facturas int,
    monto_total decimal(12,2)
)

select count(f.factura_num) as cant_facturas, f.cliente_num, sum(fd.precio_unit * fd.cantidad) as monto_total
from facturas f
join facturas_det fd on f.factura_num = fd.factura_num
where cliente_num is not null group by cliente_num


create procedure suma_compras
as begin
    declare @cant_facturas int
    declare @cliente_num int
    declare @monto_total int
    declare mi_cursor cursor
        for select count(f.factura_num) as cant_facturas, f.cliente_num, sum(fd.precio_unit * fd.cantidad) as monto_total
                from facturas f
                join facturas_det fd on f.factura_num = fd.factura_num
            where cliente_num is not null group by cliente_num
    open mi_cursor
    fetch mi_cursor into @cant_facturas, @cliente_num, @monto_total
    while (@@fetch_status = 0)
        begin
            if exists(select 1 from compras_clientes where client_num = @cliente_num)
                update compras_clientes set cant_facturas = @cant_facturas, monto_total = @monto_total where client_num = @cliente_num
            else
                insert into compras_clientes values (@cliente_num, @cant_facturas, @monto_total)

            fetch mi_cursor into @cant_facturas, @cliente_num, @monto_total
        end
    close mi_cursor
    deallocate mi_cursor
end

exec suma_compras


--4
select p.producto_cod,
       (case
           when
               exists(select 1 from facturas_det fd where p.producto_cod = fd.producto_cod)
           then 'tiene_ventas' else 'no_tiene_ventas' end ) as ventas
    from productos p

drop procedure  actualiza_precios
create procedure actualiza_precios
as begin
    drop table lista_precios
    create table lista_precios(
        producto_cod int,
        producto_desc varchar(100),
        precio_unit decimal(10,2)
    )
    declare @producto_cod int
    declare @precio_unit decimal(10,2)
    declare @producto_desc varchar(100)
    declare mi_cursor cursor for select producto_cod, precio_unit, producto_desc from productos
    open mi_cursor
    fetch mi_cursor into @producto_cod, @precio_unit, @producto_desc
    while (@@fetch_status = 0)
        begin
            if exists(select 1 from facturas_det where producto_cod = @producto_cod)
                if @precio_unit >= 150
                    set @precio_unit = (@precio_unit * 1.2)
                else
                    set @precio_unit = (@precio_unit * 1.1)
            insert into lista_precios values (@producto_cod, @producto_desc, @precio_unit )
            fetch mi_cursor into @producto_cod, @precio_unit, @producto_desc
        end
    close mi_cursor
    deallocate mi_cursor
end



execute actualiza_precios

select * into fabricantes_nuevo from fabricantes where 1=2;
insert into fabricantes_nuevo values
('RO', 'Xerox Co', null, 'TF'),
('PATO', 'Patogenos Sa', -2, 'TF'),
('GRUN', 'Grundig Srl', 6, 'ZZ'),
('LACO', 'Loco', 6, 'SC'),
('OSLO', 'Otorrino Sca', 2, 'RN')

drop procedure insert_fab_nuevos
create procedure insert_fab_nuevos
as begin
    declare @fabricante_cod varchar(5)
    declare @fabricante_nom varchar(20)
    declare @tiempo_entrega smallint
    declare @provincia_cod char(2)
    declare mi_cursor cursor for select fabricante_cod, fabricante_nom,  tiempo_entrega, provincia_cod from fabricantes_nuevo
    fetch mi_cursor into @fabricante_cod, @fabricante_nom, @tiempo_entrega, @provincia_cod
    begin try
    begin transaction
    while (@@fetch_status = 0)
        begin
            if not exists(select 1 from provincias where provincia_cod = @provincia_cod)
                throw 5000, 'Error, la provincia no existe', 1
            if exists(select 1 from fabricantes where fabricante_cod = @fabricante_cod)
                throw 5001, 'Error, el fabricante existe', 1
            if @tiempo_entrega < 0
                throw 5002, 'Error, el tiempo no puede ser negativo', 2
            insert into fabricantes values (@fabricante_cod, @fabricante_nom, @tiempo_entrega, @provincia_cod)
            fetch mi_cursor into @fabricante_cod, @fabricante_nom, @tiempo_entrega, @provincia_cod
        end
    close mi_cursor
    deallocate mi_cursor
    end try
    begin catch
        close mi_cursor
        deallocate mi_cursor
        rollback
        print 'Nro Error' + cast(error_number() as varchar)
        print 'Mensaje: ' + error_message()
        print 'Nro Estado' + cast(error_state() as varchar)
    end catch

end


--7
create procedure borrar_facturas (@factura_num int)
as
    begin


    end