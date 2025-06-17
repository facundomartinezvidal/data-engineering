--1 query

select f.provincia_cod, f.fabricante_nom, sum(fd.cantidad * fd.precio_unit) as monto_total,
       (select avg(total_fabricante_prov.monto_total) from (
                        select sum(fd2.cantidad * fd2.precio_unit) as monto_total from fabricantes f2
                            inner join productos p2 on f2.fabricante_cod = p2.fabricante_cod
                            inner join facturas_det fd2 on p2.producto_cod = fd2.producto_cod
                        where f.provincia_cod = f2.provincia_cod
                        group by f2.fabricante_cod
                    ) as total_fabricante_prov
       ) as promedio_provincias
    from fabricantes f
    inner join productos p on f.fabricante_cod = p.fabricante_cod
    inner join facturas_det fd on p.producto_cod = fd.producto_cod
group by f.provincia_cod, f.fabricante_nom
having sum(fd.cantidad * fd.precio_unit) >=
       (select avg(total_fabricante_prov.monto_total) from (
                        select sum(fd2.cantidad * fd2.precio_unit) as monto_total from fabricantes f2
                            inner join productos p2 on f2.fabricante_cod = p2.fabricante_cod
                            inner join facturas_det fd2 on p2.producto_cod = fd2.producto_cod
                        where f.provincia_cod = f2.provincia_cod
                        group by f2.fabricante_cod
                    ) as total_fabricante_prov)
order by f.provincia_cod, monto_total desc;




-- 2 trigger
-- cliente_num int, nombre varchar(15), apellido varchar(15),
-- domicilioAnterior varchar (20), domicilioNuevo    varchar (20),
-- fechaOperacion datetime, otrosCambios char(1) check (otrosCambios in ('S', 'N') )
--
-- Crear un trigger que registre las modificaciones del domicilio de los clientes en la tabla de anterior.
-- Además de los datos del cliente, registrar el instante en que se produjo la operación, si hubieron otros cambios
-- y los valores correspondientes al domicilio anterior y actual.
-- Si hubieron modificaciones en el apellido del cliente registrar en el campo otrosCambios el valor ‘S’ (‘N’ en caso contrario).
-- Las modificaciones pueden ser masivas.
CREATE TABLE LogOperaciones (
    cliente_num int,
    nombre varchar(15),
    apellido varchar(15),
    domicilioAnterior varchar(20),
    domicilioNuevo varchar(20),
    fechaOperacion datetime,
    otrosCambios char(1) CHECK (otrosCambios IN ('S', 'N'))
);

-- Crear el trigger
CREATE TRIGGER trg_auditoria_domicilio
ON clientes
AFTER UPDATE
AS
BEGIN
    -- Solo procesar si hubo cambios en el domicilio
    IF UPDATE(domicilio)
    BEGIN
        INSERT INTO LogOperaciones (
            cliente_num,
            nombre,
            apellido,
            domicilioAnterior,
            domicilioNuevo,
            fechaOperacion,
            otrosCambios
        )
        SELECT
            i.cliente_num,
            i.nombre,
            i.apellido,
            d.domicilio,  -- domicilio anterior (deleted)
            i.domicilio,  -- domicilio nuevo (inserted)
            GETDATE(),
            CASE
                WHEN d.apellido <> i.apellido THEN 'S'
                ELSE 'N'
            END
        FROM inserted i
        INNER JOIN deleted d ON i.cliente_num = d.cliente_num
        WHERE d.domicilio <> i.domicilio  -- Solo cuando realmente cambió el domicilio
    END
END;



--3 store_procedures
-- Crear un procedimiento historicoVtasPr que reciba como parámetro una fecha
-- y que registre en la tabla nivelDeVentas la cantidad total de unidades vendidas de cada producto hasta la fecha pasada como parámetro y un valor Nivel.
-- Para aquellos productos que tengan 10 o mas unidades vendidas asignarles el valor "Alto", a los productos que se hayan vendido menos de 10 unidades o no hayan tenido ventas, insertar el valor de nivel “Bajo”.
-- Si la fecha ya ha sido procesada mostrar el mensaje “Periodo ya procesado” y no realizar ninguna operación.

-- Crear la tabla nivelDeVentas
CREATE TABLE nivelDeVentas (
    FechaHta date NOT NULL,
    Producto_cod smallint NOT NULL,
    fabricante_cod varchar(10) NOT NULL,
    cantidadTotal bigint NOT NULL,
    Nivel varchar(5) NOT NULL,
    PRIMARY KEY (fechaHta, producto_Cod)
);

-- Crear el procedimiento
CREATE PROCEDURE historicoVtasPr
    @fecha DATE
AS
BEGIN
    -- Verificar si la fecha ya fue procesada
    IF EXISTS (SELECT 1 FROM nivelDeVentas WHERE FechaHta = @fecha)
    BEGIN
        PRINT 'Periodo ya procesado'
        RETURN
    END

    -- Insertar datos en nivelDeVentas
    INSERT INTO nivelDeVentas (FechaHta, Producto_cod, fabricante_cod, cantidadTotal, Nivel)
    SELECT
        @fecha,
        p.producto_cod,
        p.fabricante_cod,
        ISNULL(ventas.cantidadTotal, 0) as cantidadTotal,
        CASE
            WHEN ISNULL(ventas.cantidadTotal, 0) >= 10 THEN 'Alto'
            ELSE 'Bajo'
        END as Nivel
    FROM productos p
    LEFT JOIN (
        SELECT
            fd.producto_cod,
            SUM(fd.cantidad) as cantidadTotal
        FROM facturas_det fd
        INNER JOIN facturas f ON fd.factura_num = f.factura_num
        WHERE f.fecha_emision <= @fecha
        GROUP BY fd.producto_cod
    ) ventas ON p.producto_cod = ventas.producto_cod
END;