# Normalización

## 0FN

Comprobante de venta sin normalizar. Los productos comprados y los medios de pago son grupos repetitivos en una misma celda:

| Nro ticket |   Fecha y hora   | Cajero                          | Cliente                     | Productos comprados                                                     | Medios de pago                              | Total |
| :--------: | :--------------: | :------------------------------ | :-------------------------- | :---------------------------------------------------------------------- | :------------------------------------------ | :---: |
|    101     | 20/09/2026 10:15 | Juan Pérez (Legajo 104, Cajero) | Carlos Gómez (DNI 35123456) | Leche Entera 1L (2 un. x $1200),<br>Fideos Guiseros 500g (3 un. x $900) | Efectivo ($3000),<br>Tarjeta Débito ($2100) | $5100 |
|    102     | 20/09/2026 10:30 | Juan Pérez (Legajo 104, Cajero) | Ana Martínez (DNI 28987654) | Arroz Blanco 1kg (1 un. x $1500)                                        | Billetera Virtual ($1500)                   | $1500 |

---

## 1FN

Se separa la venta en tres tablas atómicas para evitar mezclar productos con medios de pago:

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

En LINEAS_VENTA los datos del artículo dependen solo de id_producto y no de todo el ticket: id_producto -> {codigo_barra, marca, id_categoria, nombre_categoria, detalle, precio_actual}. Solo la cantidad y el precio cobrado dependen de la clave completa: {numero_ticket, id_producto} -> {cantidad, precio_unitario_cobrado}. Por eso separamos los datos del producto en PRODUCTO.

En COBROS_VENTA pasa lo mismo: id_medio_de_pago -> descripcion_medio depende solo del medio de pago. Únicamente el monto imputado depende de toda la clave: {numero_ticket, id_medio_de_pago} -> monto_imputado. Por eso separamos MEDIO_DE_PAGO.

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

En PRODUCTO, nombre_categoria depende de id_categoria y no del producto directamente: id_producto -> id_categoria -> nombre_categoria. Se separa en CATEGORIA. El detalle del producto se mueve a DESCRIPCION_PRODUCTO para no repetirlo en DETALLE_VENTA.

En VENTA, nombre_empleado, legajo y rol dependen de dni_empleado, y nombre_cliente depende de dni_cliente: numero_ticket -> dni_empleado -> {nombre, legajo, rol} y numero_ticket -> dni_cliente -> nombre_cliente. Los datos personales se trasladan a PERSONA, con EMPLEADO y CLIENTE como subtipos.

### Separación de CATEGORIA y DESCRIPCION_PRODUCTO

PRODUCTO:

| id_producto (PK) | codigo_barra | marca         | precio_actual | stock_actual | stock_minimo | id_categoria (FK) |
| :--------------: | :----------: | :------------ | :-----------: | :----------: | :----------: | :---------------: |
|        1         | 779123456001 | La Serenísima |     $1200     |      50      |      10      |        10         |
|        2         | 779123456002 | Matarazzo     |     $900      |     120      |      20      |        20         |
|        3         | 779123456003 | Gallo         |     $1500     |      80      |      15      |        20         |

CATEGORIA:

| id_categoria (PK) | nombre  |
| :---------------: | :------ |
|        10         | Lácteos |
|        20         | Almacén |

DESCRIPCION_PRODUCTO:

| id_descripcion (PK) | detalle                | id_producto (FK) |
| :-----------------: | :--------------------- | :--------------: |
|          1          | Leche Entera 1L sachet |        1         |
|          2          | Fideos Guiseros 500g   |        2         |
|          3          | Arroz Blanco 1kg       |        3         |

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

subtotal, iva, descuento y total quedan en VENTA porque son valores propios de esa operación, aunque después cambien los precios de los productos.

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

PRODUCTO (id_producto, codigo_barra, marca, precio_actual, stock_actual, stock_minimo, id_categoria)  
PK: id_producto  
FK: id_categoria -> CATEGORIA(id_categoria)

DESCRIPCION_PRODUCTO (id_descripcion, detalle, id_producto)  
PK: id_descripcion  
FK: id_producto -> PRODUCTO(id_producto)

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
