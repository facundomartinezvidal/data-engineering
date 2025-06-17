

## **4. Enumeración de tipos de índices**

**Enumere los tipos de índices según su estructura física que conoce y diga qué ventajas y desventajas tiene el uso de índices en general.**

### **Tipos de Índices por Estructura Física:**

1. **Índices Agrupados (Clustered Index)**
   - Solo puede haber uno por tabla
   - Los datos se almacenan físicamente ordenados según la clave del índice
   - La clave primaria por defecto crea un índice agrupado

2. **Índices No Agrupados (Non-Clustered Index)**
   - Puede haber múltiples por tabla (hasta 999 en SQL Server)
   - Mantienen punteros a las filas de datos
   - No alteran el orden físico de los datos

3. **Índices Únicos (Unique Index)**
   - Garantizan la unicidad de los valores
   - Pueden ser agrupados o no agrupados

4. **Índices Compuestos (Composite Index)**
   - Incluyen múltiples columnas
   - El orden de las columnas es importante

### **Ventajas de los Índices:**

- **Mejora en la velocidad de consultas SELECT**
- **Aceleración de operaciones WHERE, ORDER BY, GROUP BY**
- **Optimización de JOIN entre tablas**
- **Mejora en la velocidad de búsquedas**

### **Desventajas de los Índices:**

- **Espacio adicional de almacenamiento**
- **Ralentización de operaciones INSERT, UPDATE, DELETE**
- **Mantenimiento automático del sistema**
- **Posible fragmentación**

---

## **5. Concepto de Dominio en Base de Datos**

**¿Qué es y cómo implementa el concepto de dominio en una Base de Datos?**

### **Definición:**

Un **dominio** es el conjunto de valores válidos que puede tomar un atributo (columna) en una base de datos. Define las restricciones sobre los tipos de datos y valores permitidos.

### **Implementación:**

1. **Tipos de Datos Básicos:**
   ```sql
   edad INT CHECK (edad >= 0 AND edad <= 120)
   ```

2. **Restricciones CHECK:**
   ```sql
   estado CHAR(1) CHECK (estado IN ('A', 'I', 'P'))
   ```

3. **Dominios Personalizados:**
   ```sql
   CREATE RULE rango_edad AS @edad >= 0 AND @edad <= 120
   CREATE DOMAIN tipo_edad AS INT
   ```

4. **Claves Foráneas:**
   ```sql
   provincia_cod CHAR(2) REFERENCES provincias(provincia_cod)
   ```

---

## **6. Vista EMP_VIEW**

**Create view EMP_VIEW as Select e.legajo, e.nombre, e.depto, d.descripcion, depto from empleados e JOIN Departamentos d on e.depto = d.depto**

**¿Cómo insertaría nuevos registros en dicha vista?**

### **Respuesta:**

**b) Mediante un trigger del tipo ON INSTEAD INSERT. ✓**

### **Explicación:**

Las vistas que contienen JOIN no permiten operaciones DML directas (INSERT, UPDATE, DELETE). Para poder insertar en una vista con JOIN, es necesario crear un trigger `INSTEAD OF INSERT` que maneje la lógica de inserción en las tablas subyacentes.

```sql
CREATE TRIGGER InsertarEmpleado 
ON EMP_VIEW
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO empleados (legajo, nombre, depto)
    SELECT legajo, nombre, depto 
    FROM inserted;
END;
```

---

## **7. Diferencias entre Query, Trigger, Procedure y Function**

| Característica | Query | Trigger | Procedure | Function |
|----------------|-------|---------|-----------|----------|
| **Ejecución** | Manual/Directa | Automática (eventos) | Manual (EXEC) | Manual (SELECT) |
| **Parámetros** | No aplica | No | Sí (IN/OUT) | Sí (solo IN) |
| **Valor de retorno** | Conjunto resultado | No | No (solo status) | Sí (obligatorio) |
| **DML permitido** | Sí | Sí | Sí | No |
| **Uso en SELECT** | Es un SELECT | No | No | Sí |
| **Transacciones** | Implícitas | Heredadas | Explícitas | No |
| **Almacenamiento** | No | Sí (en BD) | Sí (en BD) | Sí (en BD) |

### **Ejemplos:**

**Query:**
```sql
SELECT cliente_num, nombre FROM clientes WHERE estado = 'A';
```

**Trigger:**
```sql
CREATE TRIGGER AuditClientes ON clientes AFTER INSERT AS...
```

**Procedure:**
```sql
CREATE PROCEDURE ObtenerCliente @id INT AS...
EXEC ObtenerCliente 101;
```

**Function:**
```sql
CREATE FUNCTION CalcularDescuento(@precio DECIMAL) RETURNS DECIMAL AS...
SELECT precio, dbo.CalcularDescuento(precio) FROM productos;
```

---

## **Tabla de Calificaciones**

| Ejercicio | Query | Trigger | Procedure | 4 | 5 | 6 | 7 |
|-----------|-------|---------|-----------|---|---|---|---|
| **Nota** | 0.5 | 0.5 | 0 | 0.25 | 0.25 | 1 | 0 |

### **Comentarios:**
- **Procedure:** Necesita manejo de transacciones y validaciones más robustas
- **Pregunta 7:** Requiere mayor detalle en las diferencias técnicas
- **Puntos fuertes:** Vista con JOIN y conceptos teóricos bien fundamentados