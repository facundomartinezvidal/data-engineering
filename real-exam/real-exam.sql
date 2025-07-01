select
    fa.fabricante_cod,
    fa.fabricante_nom,
    c.cliente_num,
    c.nombre,
    count(distinct f.factura_num),
    sum(fd.cantidad * fd.precio_unit)
from facturas f
join clientes c on c.cliente_num = f.cliente_num
join facturas_det fd on f.factura_num = fd.factura_num
join productos p on p.producto_cod = fd.producto_cod
join fabricantes fa on fa.fabricante_cod = p.fabricante_cod
where fa.tiempo_entrega < 5
group by fa.fabricante_cod, fa.fabricante_nom, c.cliente_num, c.nombre
having sum(fd.cantidad * fd.precio_unit) > 3000
order by fa.fabricante_cod, sum(fd.cantidad * fd.precio_unit) desc


create table NovedadesClientes (
    Cliente_num int,
    apellido varchar(50),
    nombre varchar(50),
    empresa varchar(50),
    provincia_cod char(2),
)

create procedure procesarClientesPR as
    begin
        declare @cliente_num int
        declare @apellido varchar(50)
        declare @nombre varchar(50)
        declare @empresa varchar(50)
        declare @provincia_cod char(2)
        declare mi_cursor cursor for select Cliente_num, apellido, nombre, empresa, provincia_cod from NovedadesClientes
        open mi_cursor
        fetch next from mi_cursor into @cliente_num, @apellido, @nombre, @empresa, @provincia_cod
        while (@@fetch_status = 0)
            begin
                begin transaction
                begin try
                    if (exists(select 1 from clientes where cliente_num = @cliente_num))
                    begin
                        update clientes
                        set apellido = @apellido, nombre = @nombre, empresa = @empresa, provincia_cod = @provincia_cod
                        where cliente_num = @cliente_num
                    end
                    else
                        begin
                        insert into clientes(cliente_num, apellido, nombre, empresa, provincia_cod)
                        values (@cliente_num, @apellido, @nombre, @empresa, @provincia_cod)
                        end
                    commit
                end try
                begin catch
                    rollback
                    print 'Error:' + error_message()
                end catch
                fetch next from mi_cursor into @cliente_num, @apellido, @nombre, @empresa, @provincia_cod
            end
            close mi_cursor
            deallocate mi_cursor
    end






create table ListaPrecios(
    producto_cod int,
    Fecha_modif datetime,
    precioViejo decimal(12,2),
    PrecioNuevo decimal(10,2)
)

create trigger precios on productos after update as
    begin
        insert into ListaPrecios(producto_cod, Fecha_modif, precioViejo, PrecioNuevo)
        (select
             i.producto_cod,
             getdate(),
             d.precio_unit,
             i.precio_unit
             from inserted i
             join deleted d on i.producto_cod = d.producto_cod
             where i.precio_unit != d.precio_unit
        )
    end
