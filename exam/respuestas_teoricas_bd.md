# Respuestas Teóricas - Base de Datos

## 4. Propiedades de las Transacciones (ACID)

**Respuesta correcta: c. Atomicidad, Consistencia, Aislamiento, Durabilidad**

Las propiedades ACID son:

- **A**tomicidad: Las transacciones son atómicas (todo o nada)
- **C**onsistencia: La BD pasa de un estado consistente a otro consistente
- **I**solation (Aislamiento): Las operaciones de una transacción están ocultas a las demás
- **D**urabilidad: Las actualizaciones perduran en la BD aunque haya una caída posterior

## 5. Concepto de DOMINIO

**Respuesta correcta: b. Al conjunto de valores posibles que puede tomar un atributo.**

El DOMINIO en bases de datos relacionales se refiere al conjunto de valores válidos que puede tomar un atributo. Incluye:

- Tipos de datos
- Restricciones de valor (NULL/NOT NULL)
- Chequeos de valores
- Convenciones de nombres

## 6. PRIMARY KEY

**Respuesta correcta: d. Una PRIMARY KEY puede ser referenciada desde una FOREIGN KEY**

Explicación de las opciones:

- a. **FALSO**: PRIMARY KEY y UNIQUE KEY no son lo mismo. PRIMARY KEY no puede tener NULLs, UNIQUE KEY sí.
- b. **FALSO**: Una PRIMARY KEY puede ser compuesta (formada por múltiples columnas).
- c. **FALSO**: Una PRIMARY KEY NO puede contener valores NULL.
- d. **VERDADERO**: Una PRIMARY KEY puede ser referenciada por FOREIGN KEYs de otras tablas.
- e. **FALSO**: porque la opción d es verdadera.

## 7. Almacenamiento de VISTAS

**Respuesta correcta: c. La vista no ocupará espacio físico de almacenamiento, solo el espacio en el Catálogo de la BD.**

Las vistas son objetos virtuales que no almacenan datos físicamente. Solo almacenan la definición de la consulta en el catálogo de la base de datos. Los datos se obtienen dinámicamente de las tablas subyacentes cuando se ejecuta la vista.