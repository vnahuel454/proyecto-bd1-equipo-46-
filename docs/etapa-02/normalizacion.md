# Normalización

## 0FN

| Nro ticket |   Fecha y hora   | Cliente      | DNI cliente | Productos comprados                                                     | Medios de pago                              | Total |
| :--------: | :--------------: | :----------- | :---------: | :---------------------------------------------------------------------- | :------------------------------------------ | :---: |
|    101     | 20/09/2026 10:15 | Carlos Gómez |  35123456   | Leche Entera 1L (2 un. x $1200),<br>Fideos Guiseros 500g (3 un. x $900) | Efectivo ($3000),<br>Tarjeta Débito ($2100) | $5100 |
|    102     | 20/09/2026 10:30 | Ana Martínez |  28987654   | Arroz Blanco 1kg (1 un. x $1500)                                        | Billetera Virtual ($1500)                   | $1500 |

Productos comprados y medios de pago tienen varios valores repetidos por fila.

---

## 1FN

Clave primaria compuesta: {nro ticket, id producto, id medio pago}

| Nro ticket | Fecha | DNI cliente | Nombre       | ID prod | Descripción  | Marca         | Categoría | Cant | Precio cobrado | ID pago | Medio pago        | Monto pago |
| :--------: | :---: | :---------: | :----------- | :-----: | :----------- | :------------ | :-------- | :--: | :------------: | :-----: | :---------------- | :--------: |
|    101     | 20/09 |  35123456   | Carlos Gómez |    1    | Leche Entera | La Serenísima | Lácteos   |  2   |     $1200      |    1    | Efectivo          |   $3000    |
|    101     | 20/09 |  35123456   | Carlos Gómez |    2    | Fideos       | Matarazzo     | Almacén   |  3   |      $900      |    2    | Tarjeta Débito    |   $2100    |
|    102     | 20/09 |  28987654   | Ana Martínez |    3    | Arroz Blanco | Gallo         | Almacén   |  1   |     $1500      |    5    | Billetera Virtual |   $1500    |

Quedan dependencias parciales: la descripción y la marca dependen solo del producto, no de toda la clave.

---

## 2FN

Se separan las tablas para eliminar esas dependencias parciales.

### A. Tabla: VENTA

Clave primaria: numero_ticket

| numero_ticket (PK) |    fecha_hora    | dni_Cliente (FK) | nombre_cliente | total |
| :----------------: | :--------------: | :--------------: | :------------- | :---: |
|        101         | 20/09/2026 10:15 |     35123456     | Carlos Gómez   | $5100 |
|        102         | 20/09/2026 10:30 |     28987654     | Ana Martínez   | $1500 |

### B. Tabla: PRODUCTO

Clave primaria: id_producto

| id_producto (PK) | descripcion      | Marca         | id_categoria | nombre_categoria | precio_actual |
| :--------------: | :--------------- | :------------ | :----------: | :--------------- | :-----------: |
|        1         | Leche Entera 1L  | La Serenísima |      10      | Lácteos          |     $1200     |
|        2         | Fideos Guiseros  | Matarazzo     |      20      | Almacén          |     $900      |
|        3         | Arroz Blanco 1kg | Gallo         |      20      | Almacén          |     $1500     |

### C. Tabla: DETALLE_VENTA

Clave primaria compuesta: {numero_ticket, id_producto}

| numero_ticket (PK, FK) | id_producto (PK, FK) | cantidad | precio_unitario_cobrado |
| :--------------------: | :------------------: | :------: | :---------------------: |
|          101           |          1           |    2     |          $1200          |
|          101           |          2           |    3     |          $900           |
|          102           |          3           |    1     |          $1500          |

Resuelve la relación muchos a muchos entre ventas y productos.

### D. Tabla: SE_ABONA_CON

Clave primaria compuesta: {numero_ticket, id_medio_de_pago}

| numero_ticket (PK, FK) | id_medio_de_pago (PK, FK) | monto_imputado |
| :--------------------: | :-----------------------: | :------------: |
|          101           |             1             |     $3000      |
|          101           |             2             |     $2100      |
|          102           |             5             |     $1500      |

Permite pagos combinados en una misma venta.

### E. Tabla: MEDIO_DE_PAGO

Clave primaria: id_medio_de_pago

| id_medio_de_pago (PK) | descripción       |
| :-------------------: | :---------------- |
|           1           | Efectivo          |
|           2           | Tarjeta de Débito |
|           5           | Billetera Virtual |

---

## 3FN

Quedan dependencias transitivas: nombre_categoria depende de id_categoria, y el nombre del cliente depende del DNI, no de la clave primaria de sus tablas.

### Separación de CATEGORIA

PRODUCTO:

| id_producto (PK) | codigo_barra | Marca         | precio_actual | stock_actual | stock_minimo | id_categoria (FK) |
| :--------------: | :----------: | :------------ | :-----------: | :----------: | :----------: | :---------------: |
|        1         | 779123456001 | La Serenísima |     $1200     |      50      |      10      |        10         |
|        2         | 779123456002 | Matarazzo     |     $900      |     120      |      20      |        20         |
|        3         | 779123456003 | Gallo         |     $1500     |      80      |      15      |        20         |

CATEGORIA:

| id_categoria (PK) | nombre  |
| :---------------: | :------ |
|        10         | Lácteos |
|        20         | Almacén |

### Separación de PERSONA y CLIENTE

PERSONA:

| DNI (PK) | nombre | apellido |    cuil     | teléfono   | calle      | número | ciudad      | codigo_postal | provincia  |
| :------: | :----- | :------- | :---------: | :--------- | :--------- | :----: | :---------- | :-----------: | :--------- |
| 35123456 | Carlos | Gómez    | 20351234568 | 3794112233 | San Martín |  1050  | Corrientes  |     3400      | Corrientes |
| 28987654 | Ana    | Martínez | 27289876544 | 3794998877 | Av. Italia |  420   | Resistencia |     3500      | Chaco      |

CLIENTE:

| dni_Cliente (PK, FK) |
| :------------------: |
|       35123456       |
|       28987654       |

VENTA:

| numero_ticket (PK) |    fecha_hora    | subtotal |   iva   | total | dni_Empleado (FK) | dni_Cliente (FK) |
| :----------------: | :--------------: | :------: | :-----: | :---: | :---------------: | :--------------: |
|        101         | 20/09/2026 10:15 | $4214.88 | $885.12 | $5100 |     30111222      |     35123456     |
|        102         | 20/09/2026 10:30 | $1239.67 | $260.33 | $1500 |     30111222      |     28987654     |

subtotal, iva, descuento y total quedan en VENTA porque son valores propios de esa operación, aunque después cambien los precios de los productos.

