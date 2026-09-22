# Normalización

El proceso de normalización toma como punto de partida el comprobante comercial principal del sistema (el ticket de venta). A partir de él se modelan las ventas, los clientes, los empleados, los productos y los pagos. Los módulos complementarios de abastecimiento (`PROVEEDOR` y `SUMINISTRA`) se definen de forma directa en el esquema relacional global.

## 0FN

En el estado inicial, la información de la venta se encuentra sin normalizar, reuniendo en un único registro los datos de la operación, del cajero, del cliente, los artículos comprados y las formas de pago:

| Nro ticket | Fecha y hora | Cajero (Empleado) | Cliente | Productos comprados | Medios de pago | Total |
| :---: | :---: | :--- | :--- | :--- | :--- | :---: |
| 101 | 20/09/2026 10:15 | 30111222 - Juan Pérez (Legajo 104) | 35123456 - Carlos Gómez | Leche Entera 1L (2 un. x $1200),<br>Fideos Guiseros 500g (3 un. x $900) | Efectivo ($3000),<br>Tarjeta Débito ($2100) | $5100 |
| 102 | 20/09/2026 10:30 | 30111222 - Juan Pérez (Legajo 104) | 28987654 - Ana Martínez | Arroz Blanco 1kg (1 un. x $1500) | Billetera Virtual ($1500) | $1500 |

Problemas en 0FN: existen dos grupos repetitivos independientes (`Productos comprados` y `Medios de pago`) que contienen múltiples valores por fila, violando la atomicidad. Además, los datos personales de clientes y empleados se repiten en cada venta.

---

## 1FN

Para alcanzar 1FN se garantiza la atomicidad de los datos. Dado que los productos comprados y los pagos son dos grupos repetitivos independientes entre sí, no deben combinarse en una misma clave compuesta para no generar un producto cartesiano falso (lo que asociaría erróneamente un artículo con un pago determinado).

Por ello, la transacción se descompone en sus relaciones atómicas:

### VENTA (Cabecera)
Clave primaria: numero_ticket

| numero_ticket (PK) | fecha_hora | dni_empleado | nombre_empleado | legajo | dni_cliente | nombre_cliente | subtotal | iva | total |
| :---: | :---: | :---: | :--- | :---: | :---: | :--- | :---: | :---: | :---: |
| 101 | 20/09/2026 10:15 | 30111222 | Juan Pérez | 104 | 35123456 | Carlos Gómez | $4214.88 | $885.12 | $5100 |
| 102 | 20/09/2026 10:30 | 30111222 | Juan Pérez | 104 | 28987654 | Ana Martínez | $1239.67 | $260.33 | $1500 |

### LINEAS_VENTA (Artículos)
Clave primaria compuesta: {numero_ticket, id_producto}

| numero_ticket (PK) | id_producto (PK) | codigo_barra | marca | id_categoria | nombre_categoria | detalle | precio_actual | cantidad | precio_unitario_cobrado |
| :---: | :---: | :---: | :--- | :---: | :--- | :--- | :---: | :---: | :---: |
| 101 | 1 | 779123456001 | La Serenísima | 10 | Lácteos | Leche Entera 1L sachet | $1200 | 2 | $1200 |
| 101 | 2 | 779123456002 | Matarazzo | 20 | Almacén | Fideos Guiseros 500g | $900 | 3 | $900 |
| 102 | 3 | 779123456003 | Gallo | 20 | Almacén | Arroz Blanco 1kg | $1500 | 1 | $1500 |

### COBROS_VENTA (Pagos)
Clave primaria compuesta: {numero_ticket, id_medio_de_pago}

| numero_ticket (PK) | id_medio_de_pago (PK) | descripcion_medio | monto_imputado |
| :---: | :---: | :--- | :---: |
| 101 | 1 | Efectivo | $3000 |
| 101 | 2 | Tarjeta de Débito | $2100 |
| 102 | 5 | Billetera Virtual | $1500 |

---

## 2FN

La Segunda Forma Normal exige que los atributos no clave dependan de la totalidad de la clave primaria, aplicando exclusivamente a tablas con clave compuesta. La tabla `VENTA` ya cuenta con clave simple (`numero_ticket`), por lo que ya cumple 2FN.

Las dependencias parciales se detectan y corrigen en las dos tablas con clave compuesta:

1. En `LINEAS_VENTA`: los datos del artículo (`codigo_barra`, `marca`, `id_categoria`, `nombre_categoria`, `detalle`, `precio_actual`) dependen únicamente de `id_producto` y no del ticket. Solo `cantidad` y `precio_unitario_cobrado` dependen de la clave completa. Se extrae la entidad `PRODUCTO`.

2. En `COBROS_VENTA`: `descripcion_medio` depende solo de `id_medio_de_pago`. Únicamente `monto_imputado` depende de la combinación del ticket y el medio de pago. Se extrae la entidad `MEDIO_DE_PAGO`.

### DETALLE_VENTA
Clave primaria compuesta: {numero_ticket, id_producto}

| numero_ticket (PK, FK) | id_producto (PK, FK) | cantidad | precio_unitario_cobrado |
| :---: | :---: | :---: | :---: |
| 101 | 1 | 2 | $1200 |
| 101 | 2 | 3 | $900 |
| 102 | 3 | 1 | $1500 |

### PRODUCTO
Clave primaria: id_producto

| id_producto (PK) | codigo_barra | marca | id_categoria | nombre_categoria | detalle | precio_actual | stock_actual | stock_minimo |
| :---: | :---: | :--- | :---: | :--- | :--- | :---: | :---: | :---: |
| 1 | 779123456001 | La Serenísima | 10 | Lácteos | Leche Entera 1L sachet | $1200 | 50 | 10 |
| 2 | 779123456002 | Matarazzo | 20 | Almacén | Fideos Guiseros 500g | $900 | 120 | 20 |
| 3 | 779123456003 | Gallo | 20 | Almacén | Arroz Blanco 1kg | $1500 | 80 | 15 |

### SE_ABONA_CON
Clave primaria compuesta: {numero_ticket, id_medio_de_pago}

| numero_ticket (PK, FK) | id_medio_de_pago (PK, FK) | monto_imputado |
| :---: | :---: | :---: |
| 101 | 1 | $3000 |
| 101 | 2 | $2100 |
| 102 | 5 | $1500 |

### MEDIO_DE_PAGO
Clave primaria: id_medio_de_pago

| id_medio_de_pago (PK) | descripcion |
| :---: | :--- |
| 1 | Efectivo |
| 2 | Tarjeta de Débito |
| 5 | Billetera Virtual |

*(La tabla `VENTA` se conserva sin cambios respecto a 1FN, manteniendo su clave simple `numero_ticket`).*

---

## 3FN

Para alcanzar 3FN se eliminan las dependencias transitivas (atributos no clave que dependen de otros atributos no clave):

1. En `PRODUCTO`: `id_producto` determina a `id_categoria`, y este determina a `nombre_categoria`. Se aísla `CATEGORIA`.
2. En `PRODUCTO`: para optimizar el rendimiento en consultas masivas de caja, el atributo extenso `detalle` se separa en la entidad 1 a 1 `DESCRIPCION_PRODUCTO` (particionamiento vertical).
3. En `VENTA`: `numero_ticket` determina tanto a `dni_empleado` como a `dni_cliente`, y a partir de ellos se determinan sus datos personales. Para resolver la transitividad y modelar la jerarquía del diagrama relacional, los datos personales se extraen a la tabla supertipo `PERSONA`, de la cual se derivan las tablas hijas `CLIENTE` y `EMPLEADO`.

### PRODUCTO
| id_producto (PK) | codigo_barra | marca | precio_actual | stock_actual | stock_minimo | id_categoria (FK) |
| :---: | :---: | :--- | :---: | :---: | :---: | :---: |
| 1 | 779123456001 | La Serenísima | $1200 | 50 | 10 | 10 |
| 2 | 779123456002 | Matarazzo | $900 | 120 | 20 | 20 |
| 3 | 779123456003 | Gallo | $1500 | 80 | 15 | 20 |

### CATEGORIA
| id_categoria (PK) | nombre |
| :---: | :--- |
| 10 | Lácteos |
| 20 | Almacén |

### DESCRIPCION_PRODUCTO
| id_descripcion (PK) | detalle | id_producto (FK) |
| :---: | :--- | :---: |
| 1 | Leche Entera 1L sachet | 1 |
| 2 | Fideos Guiseros 500g | 2 |
| 3 | Arroz Blanco 1kg | 3 |

### PERSONA
| DNI (PK) | nombre | apellido | cuil | teléfono | calle | número | ciudad | codigo_postal | provincia |
| :---: | :--- | :--- | :---: | :---: | :--- | :---: | :--- | :---: | :--- |
| 30111222 | Juan | Pérez | 20301112228 | 3794001122 | Junín | 850 | Corrientes | 3400 | Corrientes |
| 35123456 | Carlos | Gómez | 20351234568 | 3794112233 | San Martín | 1050 | Corrientes | 3400 | Corrientes |
| 28987654 | Ana | Martínez | 27289876544 | 3794998877 | Av. Italia | 420 | Resistencia | 3500 | Chaco |

### EMPLEADO
| dni_Empleado (PK, FK) | numero_legajo | rol |
| :---: | :---: | :--- |
| 30111222 | 104 | Cajero |

### CLIENTE
| dni_Cliente (PK, FK) |
| :---: |
| 35123456 |
| 28987654 |

### VENTA
| numero_ticket (PK) | fecha_hora | subtotal | iva | total | dni_Empleado (FK) | dni_Cliente (FK) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 101 | 20/09/2026 10:15 | $4214.88 | $885.12 | $5100 | 30111222 | 35123456 |
| 102 | 20/09/2026 10:30 | $1239.67 | $260.33 | $1500 | 30111222 | 28987654 |

subtotal, iva, descuento y total quedan en VENTA porque son valores propios de esa operación, aunque después cambien los precios de los productos.
