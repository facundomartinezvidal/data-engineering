--1
create trigger delete_client on clientes
instead of delete
    as
    begin
        update clientes set estado = 'I' where cliente_num in (select cliente_num from deleted)
    end

--2
create trigger delete_facturas on facturas instead of delete as
    begin
            if (select count(d.factura_num) from deleted d) > 1
                throw 50001, 'No se pueden elminar mas de una factura a la vez', 1
            else
                delete facturas where factura_num in (select factura_num from deleted)
                delete facturas_det where factura_num in (select factura_num from deleted)
    end

--3
create view producto_fabricantes_v as
    select f.fabricante_cod, f.fabricante_nom, f.provincia_cod, p.producto_cod, p.producto_desc
           from fabricantes f inner join productos p on f.fabricante_cod = p.fabricante_cod

drop view producto_fabricantes_v

create trigger producto_fabricantes on producto_fabricantes_v instead of insert as
    begin
        declare @fabricante_cod varchar(50)
        declare @fabricante_nom varchar(50)
        declare @provincia_cod varchar(50)
        declare @producto_cod varchar(50)
        declare @producto_desc varchar(50)
        declare @tiempo_entrega smallint
        declare mi_cursor cursor

        for select fabricante_cod, fabricante_nom, provincia_cod, producto_cod, producto_desc from inserted
        open mi_cursor
        fetch mi_cursor into @fabricante_cod, @fabricante_nom, @provincia_cod, @producto_cod, @producto_desc
        while (@@fetch_status = 0)
            begin
                set @tiempo_entrega = 0
                if not exists(select p.provincia_cod from provincias p  where p.provincia_cod in(@producto_cod))
                    throw 5001, 'No existe la provincia' , 1
                if not exists(select f.fabricante_cod from fabricantes f where f.fabricante_cod in(@fabricante_cod))
                    set @tiempo_entrega = 1
                insert into productos values (@producto_cod, @producto_desc, @fabricante_cod)
                insert into fabricantes values (@fabricante_cod, @fabricante_nom, @tiempo_entrega, @provincia_cod)
                fetch mi_cursor into @fabricante_cod, @fabricante_nom, @provincia_cod, @producto_cod, @producto_desc
            end
        close mi_cursor
        deallocate mi_cursor
    end

--4
