# Proceso de Normalización: Caso Práctico Supermercado "El Sol"

## 0FN

### Tabla: `VENTA_SIN_NORMALIZAR`

| Nro Ticket |   Fecha y Hora   | Cliente      | DNI Cliente | Productos Comprados (Lista)                                             | Medios de Pago (Lista)                      | Total |
| :--------: | :--------------: | :----------- | :---------: | :---------------------------------------------------------------------- | :------------------------------------------ | :---: |
|  **101**   | 20/09/2026 10:15 | Carlos Gómez |  35123456   | Leche Entera 1L (2 un. x $1200),<br>Fideos Guiseros 500g (3 un. x $900) | Efectivo ($3000),<br>Tarjeta Débito ($2100) | $5100 |
|  **102**   | 20/09/2026 10:30 | Ana Martínez |  28987654   | Arroz Blanco 1kg (1 un. x $1500)                                        | Billetera Virtual ($1500)                   | $1500 |

### Problemas en 0FN

Las columnas `Productos Comprados` y `Medios de Pago` violan la atomicidad al guardar múltiples valores en una misma celda. Además, los datos del cliente se repiten en cada compra y no es posible registrar productos o clientes nuevos sin una venta asociada.

---

## 1FN

### Tabla en 1FN: `VENTAS_ATOMICAS`

_(Clave Primaria Compuesta: `{Nro Ticket, ID Producto, ID Medio Pago}`)_

| Nro Ticket | Fecha | DNI Cliente | Nombre       | ID Prod | Descripción  | Marca         | Categoría | Cant | Precio Cobrado | ID Pago | Medio Pago        | Monto Pago |
| :--------: | :---: | :---------: | :----------- | :-----: | :----------- | :------------ | :-------- | :--: | :------------: | :-----: | :---------------- | :--------: |
|  **101**   | 20/09 |  35123456   | Carlos Gómez |    1    | Leche Entera | La Serenísima | Lácteos   |  2   |     $1200      |    1    | Efectivo          |   $3000    |
|  **101**   | 20/09 |  35123456   | Carlos Gómez |    2    | Fideos       | Matarazzo     | Almacén   |  3   |      $900      |    2    | Tarjeta Débito    |   $2100    |
|  **102**   | 20/09 |  28987654   | Ana Martínez |    3    | Arroz Blanco | Gallo         | Almacén   |  1   |     $1500      |    5    | Billetera Virtual |   $1500    |

Se logró atomicidad: ya no hay listas de valores dentro de una celda. Sin embargo, la clave primaria es compuesta `{Nro Ticket, ID Producto, ID Pago}`, y atributos como `Nombre`, `Marca` o `Categoría` no dependen de toda la clave, sino de una parte (dependencia parcial).

---

## 2FN

### A. Tabla: `VENTA`

_(Clave Primaria: `numero_ticket`)_

| numero_ticket (PK) |    fecha_hora    | dni_Cliente (FK) | nombre_cliente | total |
| :----------------: | :--------------: | :--------------: | :------------- | :---: |
|      **101**       | 20/09/2026 10:15 |     35123456     | Carlos Gómez   | $5100 |
|      **102**       | 20/09/2026 10:30 |     28987654     | Ana Martínez   | $1500 |

### B. Tabla: `PRODUCTO`

_(Clave Primaria: `id_producto`)_

| id_producto (PK) | descripcion      | Marca         | id_categoria | nombre_categoria | precio_actual |
| :--------------: | :--------------- | :------------ | :----------: | :--------------- | :-----------: |
|      **1**       | Leche Entera 1L  | La Serenísima |      10      | Lácteos          |     $1200     |
|      **2**       | Fideos Guiseros  | Matarazzo     |      20      | Almacén          |     $900      |
|      **3**       | Arroz Blanco 1kg | Gallo         |      20      | Almacén          |     $1500     |

### C. Tabla: `DETALLE_VENTA`

_(Clave Primaria Compuesta: `{numero_ticket, id_producto}`)_

| numero_ticket (PK, FK) | id_producto (PK, FK) | cantidad | precio_unitario_cobrado |
| :--------------------: | :------------------: | :------: | :---------------------: |
|        **101**         |          1           |    2     |          $1200          |
|        **101**         |          2           |    3     |          $900           |
|        **102**         |          3           |    1     |          $1500          |

> `cantidad` y `precio_unitario_cobrado` dependen de la clave completa (del comprobante y del artículo vendido). La marca y descripción se fueron a `PRODUCTO`, eliminando la dependencia parcial.

### D. Tabla: `SE_ABONA_CON`

_(Clave Primaria Compuesta: `{numero_ticket, id_medio_de_pago}`)_

| numero_ticket (PK, FK) | id_medio_de_pago (PK, FK) | monto_imputado |
| :--------------------: | :-----------------------: | :------------: |
|        **101**         |             1             |     $3000      |
|        **101**         |             2             |     $2100      |
|        **102**         |             5             |     $1500      |

### E. Tabla: `MEDIO_DE_PAGO`

_(Clave Primaria: `id_medio_de_pago`)_

| id_medio_de_pago (PK) | Descripción       |
| :-------------------: | :---------------- |
|         **1**         | Efectivo          |
|         **2**         | Tarjeta de Débito |
|         **5**         | Billetera Virtual |

---

## 3FN

En las tablas de 2FN persisten dependencias transitivas: en `PRODUCTO`, el nombre de la categoría depende de `id_categoria` y no directamente de `id_producto`. De forma similar, en `VENTA`, el nombre del cliente depende de `dni_Cliente` y no del ticket. Para alcanzar 3FN, estas dependencias se separan en tablas propias:

### A. Separación de `CATEGORIA`

Se saca el nombre de la categoría a su propia tabla y en `PRODUCTO` solo queda la clave foránea `id_categoria`:

**`PRODUCTO`**:
| id_producto (PK) | codigo_barra | Marca | precio_actual | stock_actual | stock_minimo | id_categoria (FK) |
| :---: | :---: | :--- | :---: | :---: | :---: | :---: |
| **1** | 779123456001 | La Serenísima | $1200 | 50 | 10 | 10 |
| **2** | 779123456002 | Matarazzo | $900 | 120 | 20 | 20 |
| **3** | 779123456003 | Gallo | $1500 | 80 | 15 | 20 |

**`CATEGORIA`**:
| id_categoria (PK) | nombre |
| :---: | :--- |
| **10** | Lácteos |
| **20** | Almacén |

### B. Separación de `PERSONA` y `CLIENTE`

Los datos personales del cliente se extraen de `VENTA` hacia la tabla `PERSONA`, vinculando la venta a través del DNI:

**`PERSONA`**:
| DNI (PK) | nombre | apellido | cuil | teléfono | calle | número | ciudad | codigo_postal | provincia |
| :---: | :--- | :--- | :---: | :---: | :--- | :---: | :--- | :---: | :--- |
| **35123456** | Carlos | Gómez | 20351234568 | 3794112233 | San Martín | 1050 | Corrientes | 3400 | Corrientes |
| **28987654** | Ana | Martínez | 27289876544 | 3794998877 | Av. Italia | 420 | Resistencia | 3500 | Chaco |

**`CLIENTE`**:
| dni_Cliente (PK, FK) |
| :---: |
| **35123456** |
| **28987654** |

**`VENTA`**:
| numero_ticket (PK) | fecha_hora | Subtotal | iva | total | dni_Empleado (FK) | dni_Cliente (FK) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **101** | 20/09/2026 10:15 | $4214.88 | $885.12 | $5100 | 30111222 | 35123456 |
| **102** | 20/09/2026 10:30 | $1239.67 | $260.33 | $1500 | 30111222 | 28987654 |

---

## Esquema Relacional Definitivo

| N°  | Nombre de Tabla            | Clave Primaria (PK)                 | Claves Foráneas (FK)                                                                                                       | Atributos No Clave                                                                                                                            |
| :-: | :------------------------- | :---------------------------------- | :------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------- |
|  1  | **`PERSONA`**              | `DNI`                               | _(Ninguna)_                                                                                                                | `nombre`, `apellido`, `cuil`, `correo_electronico`, `telefono`, `fecha_nacimiento`, `calle`, `número`, `ciudad`, `codigo_postal`, `provincia` |
|  2  | **`EMPLEADO`**             | `dni_Empleado`                      | `dni_Empleado` $\rightarrow$ `PERSONA(DNI)`                                                                                | `numero_legajo`, `rol`                                                                                                                        |
|  3  | **`CLIENTE`**              | `dni_Cliente`                       | `dni_Cliente` $\rightarrow$ `PERSONA(DNI)`                                                                                 | _(Ninguno - hereda de Persona)_                                                                                                               |
|  4  | **`CATEGORIA`**            | `id_categoria`                      | _(Ninguna)_                                                                                                                | `nombre`                                                                                                                                      |
|  5  | **`PRODUCTO`**             | `id_producto`                       | `id_categoria` $\rightarrow$ `CATEGORIA(id_categoria)`                                                                     | `codigo_barra`, `Marca`, `precio_actual`, `stock_actual`, `stock_minimo`                                                                      |
|  6  | **`DESCRIPCION_PRODUCTO`** | `id_descripcion`                    | `id_producto` $\rightarrow$ `PRODUCTO(id_producto)`                                                                        | `detalle`                                                                                                                                     |
|  7  | **`PROVEEDOR`**            | `cuit`                              | _(Ninguna)_                                                                                                                | `razon_social`, `teléfono`, `calle`, `número`, `ciudad`, `codigo_postal`, `provincia`                                                         |
|  8  | **`SUMINISTRA`**           | `{cuit, id_producto}`               | `cuit` $\rightarrow$ `PROVEEDOR(cuit)`<br>`id_producto` $\rightarrow$ `PRODUCTO(id_producto)`                              | _(Ninguno)_                                                                                                                                   |
|  9  | **`MEDIO_DE_PAGO`**        | `id_medio_de_pago`                  | _(Ninguna)_                                                                                                                | `Descripción`                                                                                                                                 |
| 10  | **`VENTA`**                | `numero_ticket`                     | `dni_Empleado` $\rightarrow$ `EMPLEADO(dni_Empleado)`<br>`dni_Cliente` $\rightarrow$ `CLIENTE(dni_Cliente)`                | `fecha_hora`, `Subtotal`, `iva`, `descuento`, `total`                                                                                         |
| 11  | **`DETALLE_VENTA`**        | `{numero_ticket, id_producto}`      | `numero_ticket` $\rightarrow$ `VENTA(numero_ticket)`<br>`id_producto` $\rightarrow$ `PRODUCTO(id_producto)`                | `cantidad`, `precio_unitario_cobrado`                                                                                                         |
| 12  | **`SE_ABONA_CON`**         | `{numero_ticket, id_medio_de_pago}` | `numero_ticket` $\rightarrow$ `VENTA(numero_ticket)`<br>`id_medio_de_pago` $\rightarrow$ `MEDIO_DE_PAGO(id_medio_de_pago)` | `monto_imputado`                                                                                                                              |

---

## Justificaciones y decisiones de diseño

### 1. Domicilios en `PERSONA` y `PROVEEDOR`
Se mantuvieron los atributos de domicilio (`calle`, `número`, `ciudad`, `codigo_postal`, `provincia`) directamente dentro de `PERSONA` y `PROVEEDOR` para evitar uniones (`JOIN`) adicionales durante la facturación y consulta de contactos, priorizando la agilidad en las operaciones de caja y despacho.

### 2. Importes calculados en `VENTA`
Se conservan `Subtotal`, `iva`, `descuento` y `total` en la tabla `VENTA` por requerimiento fiscal y rendimiento operativo. El ticket emitido es un comprobante cerrado e inmutable que debe resguardar los importes históricos exactos ante auditorías (RN.05 y RN.08), evitando que modificaciones posteriores alteren ventas pasadas. A su vez, evita ejecutar sumatorias sobre los renglones de `DETALLE_VENTA` en cada arqueo de caja o reporte diario.

### 3. Particionamiento vertical en `DESCRIPCION_PRODUCTO`
La descripción del producto se separó en una tabla independiente con relación 1 a 1 para aplicar particionamiento vertical. Al aislar textos extensos en una tabla propia, la tabla principal `PRODUCTO` mantiene registros compactos y uniformes, lo que optimiza el almacenamiento en páginas de memoria de Microsoft SQL Server y acelera las lecturas durante el escaneo de códigos de barra en línea de caja.

---
