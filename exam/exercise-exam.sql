--1 query
-- Seleccionar provincia, nombre del fabricante, monto total vendido del fabricante y promedio del monto vendido de los fabricantes de su provincia
-- para todos aquellos fabricantes cuyas ventas sean mayores o iguales al promedio de venta de los fabricantes de sus respectivas provincias.
-- Mostrar la información ordenada por provincia de manera ascendente y monto total en forma descendente.
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




--1 query
-- Mostrar el código de provincia del cliente, código y descripción del producto y la cantidad de unidades vendidas del producto,
-- de aquellos productos más vendidos (por cantidad) en cada provincia.
-- Mostrar el resultado ordenado por código de provincia.

-- Primero creamos una subconsulta para obtener la cantidad total vendida por producto y provincia
WITH ProductosPorProvincia AS (
    SELECT
        c.provincia_cod,
        fd.producto_cod,
        p.producto_desc,
        SUM(fd.cantidad) as total_vendido
    FROM facturas_det fd
    INNER JOIN facturas f ON fd.factura_num = f.factura_num
    INNER JOIN clientes c ON f.cliente_num = c.cliente_num
    INNER JOIN productos p ON fd.producto_cod = p.producto_cod
    WHERE c.provincia_cod IS NOT NULL
    GROUP BY c.provincia_cod, fd.producto_cod, p.producto_desc
),
-- Ahora obtenemos el máximo vendido por provincia
MaxVendidoPorProvincia AS (
    SELECT
        provincia_cod,
        MAX(total_vendido) as max_vendido
    FROM ProductosPorProvincia
    GROUP BY provincia_cod
)
-- Finalmente combinamos para obtener los productos más vendidos
SELECT
    pp.provincia_cod,
    pp.producto_cod,
    pp.producto_desc,
    pp.total_vendido as cantidad_vendida
FROM ProductosPorProvincia pp
INNER JOIN MaxVendidoPorProvincia mp ON pp.provincia_cod = mp.provincia_cod
    AND pp.total_vendido = mp.max_vendido
ORDER BY pp.provincia_cod;


-- 2 trigger
Create view FabricantesV as (
    select fabricante_cod, fabricante_nom, tiempo_entrega, p.provincia_cod, p.provincia_desc
    from fabricantes f join provincias p on f.provincia_cod = p.provincia_cod
);

--Crear un trigger que permita realizar operaciones de DELETE sobre la vista, de manera tal que:
--
-- Si el fabricante tiene un tiempo de entrega menor a 10 días
-- Informar el error "Error: Cliente eficiente" y no realizar la operación
-- Sino
-- Borrar físicamente al fabricante

CREATE TRIGGER DeleteFabricantesTrigger
ON FabricantesV
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @fabricante_cod varchar(5), @tiempo_entrega smallint;

    -- Cursor para procesar múltiples eliminaciones
    DECLARE fabricante_cursor CURSOR FOR
    SELECT fabricante_cod, tiempo_entrega FROM deleted;

    OPEN fabricante_cursor;
    FETCH NEXT FROM fabricante_cursor INTO @fabricante_cod, @tiempo_entrega;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si el tiempo de entrega es menor a 10 días
        IF @tiempo_entrega < 10
        BEGIN
            THROW 50001, 'Error: Cliente eficiente', 1;
        END
        ELSE
        BEGIN
            -- Borrar físicamente el fabricante
            DELETE FROM fabricantes
            WHERE fabricante_cod = @fabricante_cod;
        END

        FETCH NEXT FROM fabricante_cursor INTO @fabricante_cod, @tiempo_entrega;
    END

    CLOSE fabricante_cursor;
    DEALLOCATE fabricante_cursor;
END;

-- Desarrollar un Procedure que realice la inserción o modificación de un producto determinado.
-- Parámetros de entrada: producto_cod, producto_desc, fabricante_cod, fabricante_nom, precio_unit
-- Previamente se realiza alguna operación sobre el fabricante:
-- Si el fabricante no existe, crearlo.
-- Hechas las validaciones, si el producto no existe, insertarlo. En caso que el producto ya exista, informarlo. En caso que el producto no exista, actualizarlo sin clave.
-- En caso de error abortar TODAS las operaciones que se pudieran haber realizado.


CREATE PROCEDURE GestionarProducto
    @producto_cod SMALLINT,
    @producto_desc VARCHAR(30),
    @fabricante_cod VARCHAR(5),
    @fabricante_nom VARCHAR(20),
    @precio_unit DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si el fabricante existe, si no existe, crearlo
        IF NOT EXISTS (SELECT 1 FROM fabricantes WHERE fabricante_cod = @fabricante_cod)
        BEGIN
            INSERT INTO fabricantes (fabricante_cod, fabricante_nom, tiempo_entrega, provincia_cod)
            VALUES (@fabricante_cod, @fabricante_nom, 1, NULL);

            PRINT 'Fabricante ' + @fabricante_cod + ' creado exitosamente.';
        END

        -- Verificar si el producto existe
        IF EXISTS (SELECT 1 FROM productos WHERE producto_cod = @producto_cod)
        BEGIN
            -- El producto existe, actualizarlo
            UPDATE productos
            SET producto_desc = @producto_desc,
                fabricante_cod = @fabricante_cod,
                precio_unit = @precio_unit
            WHERE producto_cod = @producto_cod;

            PRINT 'Producto ' + CAST(@producto_cod AS VARCHAR) + ' actualizado exitosamente.';
        END
        ELSE
        BEGIN
            -- El producto no existe, insertarlo
            INSERT INTO productos (producto_cod, producto_desc, fabricante_cod, precio_unit)
            VALUES (@producto_cod, @producto_desc, @fabricante_cod, @precio_unit);

            PRINT 'Producto ' + CAST(@producto_cod AS VARCHAR) + ' insertado exitosamente.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

EXEC GestionarProducto 2001, 'Nuevo Producto', 'DOTO', 'DOTO Corporation', 150.00;
