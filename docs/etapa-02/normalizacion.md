# Normalización

## 0FN

Comprobante de venta sin normalizar. Los productos comprados y los medios de pago son grupos repetitivos en el comprobante. Para abarcar el circuito transaccional completo (RN.01 a RN.08), el análisis toma la estructura de la venta junto con el catálogo de artículos, clientes y formas de pago:

| Nro ticket |   Fecha y hora   | Cajero                          | Cliente                     | Productos comprados                                                     | Medios de pago                              | Total |
| :--------: | :--------------: | :------------------------------ | :-------------------------- | :---------------------------------------------------------------------- | :------------------------------------------ | :---: |
|    101     | 20/09/2026 10:15 | Juan Pérez (Legajo 104, Cajero) | Carlos Gómez (DNI 35123456) | Leche Entera 1L (2 un. x $1200),<br>Fideos Guiseros 500g (3 un. x $900) | Efectivo ($3000),<br>Tarjeta Débito ($2100) | $5100 |
|    102     | 20/09/2026 10:30 | Juan Pérez (Legajo 104, Cajero) | Ana Martínez (DNI 28987654) | Arroz Blanco 1kg (1 un. x $1500)                                        | Billetera Virtual ($1500)                   | $1500 |

---

## 1FN

Una relación está en 1FN si todos sus atributos son atómicos y no existen grupos repetitivos. Se descompone la venta en tres relaciones para eliminar los dos grupos repetitivos independientes (productos y cobros) y atomizar los datos de cajero y cliente (evitando además un producto cartesiano espurio entre líneas de venta y medios de pago):

### VENTA

Clave primaria: numero_ticket

| numero_ticket (PK) |    fecha_hora    | dni_empleado | nombre_empleado | legajo | rol_empleado | dni_cliente | nombre_cliente | subtotal |   iva   | descuento | total |
| :----------------: | :--------------: | :----------: | :-------------- | :----: | :----------: | :---------: | :------------- | :------: | :-----: | :-------: | :---: |
|        101         | 20/09/2026 10:15 |   30111222   | Juan Pérez      |  104   |    Cajero    |  35123456   | Carlos Gómez   | $4214.88 | $885.12 |   $0.00   | $5100 |
|        102         | 20/09/2026 10:30 |   30111222   | Juan Pérez      |  104   |    Cajero    |  28987654   | Ana Martínez   | $1239.67 | $260.33 |   $0.00   | $1500 |

### LINEAS_VENTA

Clave primaria compuesta: {numero_ticket, id_producto}

| numero_ticket (PK) | id_producto (PK) | codigo_barra | marca         | id_categoria | nombre_categoria | detalle                | precio_actual | cantidad | precio_unitario_cobrado |
| :----------------: | :--------------: | :----------: | :------------ | :----------: | :--------------- | :--------------------- | :-----------: | :------: | :---------------------: |
|        101         |        1         | 779123456001 | La Serenísima |      10      | Lácteos          | Leche Entera 1L sachet |     $1200     |    2     |          $1200          |
|        101         |        2         | 779123456002 | Matarazzo     |      20      | Almacén          | Fideos Guiseros 500g   |     $900      |    3     |          $900           |
|        102         |        3         | 779123456003 | Gallo         |      20      | Almacén          | Arroz Blanco 1kg       |     $1500     |    1     |          $1500          |

### COBROS_VENTA

Clave primaria compuesta: {numero_ticket, id_medio_de_pago}

| numero_ticket (PK) | id_medio_de_pago (PK) | descripcion_medio | monto_imputado |
| :----------------: | :-------------------: | :---------------- | :------------: |
|        101         |           1           | Efectivo          |     $3000      |
|        101         |           2           | Tarjeta de Débito |     $2100      |
|        102         |           5           | Billetera Virtual |     $1500      |

---

## 2FN

Una relación está en 2FN si está en 1FN y ningún atributo no primo depende parcialmente de una clave primaria compuesta (es decir, todo atributo no primo depende funcionalmente de la clave primaria completa).

- **VENTA:** Ya se encuentra en 2FN debido a que su clave primaria es simple (`numero_ticket`), imposibilitando por definición formal la existencia de dependencias parciales.
- **LINEAS_VENTA (PK compuesta `{numero_ticket, id_producto}`):** Los atributos del producto dependen únicamente de `id_producto` y no del ticket completo: `id_producto -> {codigo_barra, marca, id_categoria, nombre_categoria, detalle, precio_actual}`. Solo `cantidad` y `precio_unitario_cobrado` dependen de la clave compuesta completa: `{numero_ticket, id_producto} -> {cantidad, precio_unitario_cobrado}`. Por ende, para eliminar esta dependencia parcial separamos los datos del artículo en **PRODUCTO**.
- **COBROS_VENTA (PK compuesta `{numero_ticket, id_medio_de_pago}`):** `descripcion_medio` depende exclusivamente de `id_medio_de_pago`: `id_medio_de_pago -> descripcion_medio`. Únicamente `monto_imputado` depende de la clave compuesta completa: `{numero_ticket, id_medio_de_pago} -> monto_imputado`. Por ende, separamos **MEDIO_DE_PAGO**.

### DETALLE_VENTA

Clave primaria compuesta: {numero_ticket, id_producto}

| numero_ticket (PK, FK) | id_producto (PK, FK) | cantidad | precio_unitario_cobrado |
| :--------------------: | :------------------: | :------: | :---------------------: |
|          101           |          1           |    2     |          $1200          |
|          101           |          2           |    3     |          $900           |
|          102           |          3           |    1     |          $1500          |

### PRODUCTO

Clave primaria: id_producto

| id_producto (PK) | codigo_barra | marca         | id_categoria | nombre_categoria | detalle                | precio_actual | stock_actual | stock_minimo |
| :--------------: | :----------: | :------------ | :----------: | :--------------- | :--------------------- | :-----------: | :----------: | :----------: |
|        1         | 779123456001 | La Serenísima |      10      | Lácteos          | Leche Entera 1L sachet |     $1200     |      50      |      10      |
|        2         | 779123456002 | Matarazzo     |      20      | Almacén          | Fideos Guiseros 500g   |     $900      |     120      |      20      |
|        3         | 779123456003 | Gallo         |      20      | Almacén          | Arroz Blanco 1kg       |     $1500     |      80      |      15      |

Se incluyen stock_actual y stock_minimo porque forman parte del diseño general del sistema.

### SE_ABONA_CON

Clave primaria compuesta: {numero_ticket, id_medio_de_pago}

| numero_ticket (PK, FK) | id_medio_de_pago (PK, FK) | monto_imputado |
| :--------------------: | :-----------------------: | :------------: |
|          101           |             1             |     $3000      |
|          101           |             2             |     $2100      |
|          102           |             5             |     $1500      |

### MEDIO_DE_PAGO

Clave primaria: id_medio_de_pago

| id_medio_de_pago (PK) | descripcion       |
| :-------------------: | :---------------- |
|           1           | Efectivo          |
|           2           | Tarjeta de Débito |
|           5           | Billetera Virtual |

---

## 3FN

Una relación está en 3FN si está en 2FN y no existen dependencias funcionales transitivas de atributos no primos respecto a la clave primaria (ningún atributo no primo depende funcionalmente de otro atributo no primo).

- En **PRODUCTO**: existe la dependencia transitiva `id_producto -> id_categoria -> nombre_categoria`. El nombre de la categoría depende de `id_categoria` (que no es superclave de PRODUCTO). Para eliminarla, se separa en **CATEGORIA (id_categoria, nombre)**. El atributo `detalle` permanece directamente en **PRODUCTO**, ya que depende de forma directa de la clave (`id_producto -> detalle`), cumpliendo 3FN sin necesidad de crear una tabla 1:1 separada.
- En **VENTA**: existen dependencias transitivas hacia los datos de personas: `numero_ticket -> dni_empleado -> {nombre, legajo, rol}` y `numero_ticket -> dni_cliente -> nombre_cliente`. Se eliminan separando las entidades de personal y compradores. Para evitar duplicar atributos comunes (nombre, apellido, contacto, domicilio) y asegurar una única fuente de identidad sin redundancia, se estructuran bajo la superclase **PERSONA** con sus subtipos **EMPLEADO** y **CLIENTE** (jerarquía solapada y parcial, acorde al DER).

Los campos `subtotal`, `iva`, `descuento` y `total` se conservan en `VENTA` para asegurar la inmutabilidad de la facturación emitida (RN.08), evitando que cambios posteriores en precios o alícuotas alteren los registros históricos.

Los atributos de dirección (`ciudad`, `codigo_postal`, `provincia`) se mantienen como datos directos en `PERSONA` y `PROVEEDOR` para evitar tablas accesorias de localidades, conservando el diseño dentro de las 11 tablas acordadas.

### Separación de CATEGORIA

PRODUCTO:

| id_producto (PK) | codigo_barra | detalle                | marca         | precio_actual | stock_actual | stock_minimo | id_categoria (FK) |
| :--------------: | :----------: | :--------------------- | :------------ | :-----------: | :----------: | :----------: | :---------------: |
|        1         | 779123456001 | Leche Entera 1L sachet | La Serenísima |     $1200     |      50      |      10      |        10         |
|        2         | 779123456002 | Fideos Guiseros 500g   | Matarazzo     |     $900      |     120      |      20      |        20         |
|        3         | 779123456003 | Arroz Blanco 1kg       | Gallo         |     $1500     |      80      |      15      |        20         |

CATEGORIA:

| id_categoria (PK) | nombre  |
| :---------------: | :------ |
|        10         | Lácteos |
|        20         | Almacén |

### Separación de PERSONA, EMPLEADO y CLIENTE

PERSONA:

| DNI (PK) | nombre | apellido |    cuil     | teléfono   | calle      | número | ciudad      | codigo_postal | provincia  |
| :------: | :----- | :------- | :---------: | :--------- | :--------- | :----: | :---------- | :-----------: | :--------- |
| 30111222 | Juan   | Pérez    | 20301112228 | 3794001122 | Junín      |  850   | Corrientes  |     3400      | Corrientes |
| 35123456 | Carlos | Gómez    | 20351234568 | 3794112233 | San Martín |  1050  | Corrientes  |     3400      | Corrientes |
| 28987654 | Ana    | Martínez | 27289876544 | 3794998877 | Av. Italia |  420   | Resistencia |     3500      | Chaco      |

EMPLEADO:

| dni_Empleado (PK, FK) | numero_legajo | rol    |
| :-------------------: | :-----------: | :----- |
|       30111222        |      104      | Cajero |

CLIENTE:

| dni_Cliente (PK, FK) |
| :------------------: |
|       35123456       |
|       28987654       |

VENTA:

| numero_ticket (PK) |    fecha_hora    | subtotal |   iva   | descuento | total | dni_Empleado (FK) | dni_Cliente (FK) |
| :----------------: | :--------------: | :------: | :-----: | :-------: | :---: | :---------------: | :--------------: |
|        101         | 20/09/2026 10:15 | $4214.88 | $885.12 |   $0.00   | $5100 |     30111222      |     35123456     |
|        102         | 20/09/2026 10:30 | $1239.67 | $260.33 |   $0.00   | $1500 |     30111222      |     28987654     |

---

El esquema relacional final quedaria de la siguiente forma:

PERSONA (DNI, nombre, apellido, cuil, correo_electronico, telefono, fecha_nacimiento, calle, número, ciudad, codigo_postal, provincia)  
PK: DNI

EMPLEADO (dni_Empleado, numero_legajo, rol)  
PK: dni_Empleado  
FK: dni_Empleado -> PERSONA(DNI)

CLIENTE (dni_Cliente)  
PK: dni_Cliente  
FK: dni_Cliente -> PERSONA(DNI)

CATEGORIA (id_categoria, nombre)  
PK: id_categoria

PRODUCTO (id_producto, codigo_barra, detalle, marca, precio_actual, stock_actual, stock_minimo, id_categoria)  
PK: id_producto  
FK: id_categoria -> CATEGORIA(id_categoria)

MEDIO_DE_PAGO (id_medio_de_pago, descripcion)  
PK: id_medio_de_pago

VENTA (numero_ticket, fecha_hora, subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)  
PK: numero_ticket  
FK: dni_Empleado -> EMPLEADO(dni_Empleado)  
FK: dni_Cliente -> CLIENTE(dni_Cliente)

DETALLE_VENTA (numero_ticket, id_producto, cantidad, precio_unitario_cobrado)  
PK: {numero_ticket, id_producto}  
FK: numero_ticket -> VENTA(numero_ticket)  
FK: id_producto -> PRODUCTO(id_producto)

SE_ABONA_CON (numero_ticket, id_medio_de_pago, monto_imputado)  
PK: {numero_ticket, id_medio_de_pago}  
FK: numero_ticket -> VENTA(numero_ticket)  
FK: id_medio_de_pago -> MEDIO_DE_PAGO(id_medio_de_pago)

Tablas de proveedores (del modelo general):

PROVEEDOR (cuit, razon_social, teléfono, calle, número, ciudad, codigo_postal, provincia)  
PK: cuit

SUMINISTRA (cuit, id_producto)  
PK: {cuit, id_producto}  
FK: cuit -> PROVEEDOR(cuit)  
FK: id_producto -> PRODUCTO(id_producto)
