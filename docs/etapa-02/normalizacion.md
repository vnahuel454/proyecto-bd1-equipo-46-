# Proceso de Normalización: Caso Práctico Supermercado "El Sol"
### Bases de Datos I - FaCENA (UNNE)
**Caso de Estudio:** Supermercado "El Sol" | **Etapa:** 02 - Modelado Lógico

---

## 1. Estado Inicial: Base de Datos sin Normalizar (0FN)

Al inicio, la información de una venta se concibe como una planilla o comprobante único donde conviven los datos del ticket, del cliente, los productos comprados y los pagos realizados:

### Tabla: `VENTA_SIN_NORMALIZAR`

| Nro Ticket | Fecha y Hora | Cliente | DNI Cliente | Productos Comprados (Lista) | Medios de Pago (Lista) | Total |
| :---: | :---: | :--- | :---: | :--- | :--- | :---: |
| **101** | 20/09/2026 10:15 | Carlos Gómez | 35123456 | Leche Entera 1L (2 un. x $1200),<br>Fideos Guiseros 500g (3 un. x $900) | Efectivo ($3000),<br>Tarjeta Débito ($2100) | $5100 |
| **102** | 20/09/2026 10:30 | Ana Martínez | 28987654 | Arroz Blanco 1kg (1 un. x $1500) | Billetera Virtual ($1500) | $1500 |

### Problemas detectados en 0FN:
- **Violación de atomicidad:** Las columnas `Productos Comprados` y `Medios de Pago` contienen listas de valores dentro de una misma celda.
- **Redundancia:** Si un cliente compra varias veces, sus datos personales se repiten en cada fila.
- **Anomalías:** Si cambia el precio de un producto en el catálogo general, se generaría inconsistencia con las ventas pasadas. Si no hay ventas, no se puede registrar un producto ni un cliente nuevo.

---

## 2. Primera Forma Normal (1FN): Eliminación de Grupos Repetitivos y Atomicidad

**Regla:** Cada celda debe tener un único valor atómico (indivisible) y la tabla debe tener una clave primaria (PK).

Para resolver las listas repetitivas, se genera una fila por cada combinación de artículo y medio de pago:

### Tabla en 1FN: `VENTAS_ATOMICAS`
*(Clave Primaria Compuesta: `{Nro Ticket, ID Producto, ID Medio Pago}`)*

| Nro Ticket | Fecha | DNI Cliente | Nombre | ID Prod | Descripción | Marca | Categoría | Cant | Precio Cobrado | ID Pago | Medio Pago | Monto Pago |
| :---: | :---: | :---: | :--- | :---: | :--- | :--- | :--- | :---: | :---: | :---: | :--- | :---: |
| **101** | 20/09 | 35123456 | Carlos Gómez | 1 | Leche Entera | La Serenísima | Lácteos | 2 | $1200 | 1 | Efectivo | $3000 |
| **101** | 20/09 | 35123456 | Carlos Gómez | 2 | Fideos | Matarazzo | Almacén | 3 | $900 | 2 | Tarjeta Débito | $2100 |
| **102** | 20/09 | 28987654 | Ana Martínez | 3 | Arroz Blanco | Gallo | Almacén | 1 | $1500 | 5 | Billetera Virtual | $1500 |

### Diagnóstico de 1FN:
- Se logró atomicidad: ya no hay listas de valores dentro de una celda.
- **Problema que surge:** La clave primaria es compuesta `{Nro Ticket, ID Producto, ID Pago}`, pero atributos como `Nombre`, `Marca` o `Categoría` no dependen de toda la clave, sino de una parte (dependencia parcial).

---

## 3. Segunda Forma Normal (2FN): Eliminación de Dependencias Parciales

**Regla:** Debe estar en 1FN y todos los atributos no clave deben depender de la **clave primaria completa**, no de una parte de ella.

Se descompone la tabla en relaciones donde cada atributo dependa únicamente de su clave completa:

### A. Tabla: `VENTA`
*(Clave Primaria: `numero_ticket`)*

| numero_ticket (PK) | fecha_hora | dni_Cliente (FK) | nombre_cliente | total |
| :---: | :---: | :---: | :--- | :---: |
| **101** | 20/09/2026 10:15 | 35123456 | Carlos Gómez | $5100 |
| **102** | 20/09/2026 10:30 | 28987654 | Ana Martínez | $1500 |

### B. Tabla: `PRODUCTO`
*(Clave Primaria: `id_producto`)*

| id_producto (PK) | descripcion | Marca | id_categoria | nombre_categoria | precio_actual |
| :---: | :--- | :--- | :---: | :--- | :---: |
| **1** | Leche Entera 1L | La Serenísima | 10 | Lácteos | $1200 |
| **2** | Fideos Guiseros | Matarazzo | 20 | Almacén | $900 |
| **3** | Arroz Blanco 1kg | Gallo | 20 | Almacén | $1500 |

### C. Tabla: `DETALLE_VENTA`
*(Clave Primaria Compuesta: `{numero_ticket, id_producto}`)*

| numero_ticket (PK, FK) | id_producto (PK, FK) | cantidad | precio_unitario_cobrado |
| :---: | :---: | :---: | :---: |
| **101** | 1 | 2 | $1200 |
| **101** | 2 | 3 | $900 |
| **102** | 3 | 1 | $1500 |

> **Justificación 2FN:** `cantidad` y `precio_unitario_cobrado` dependen de la clave completa (del comprobante y del artículo vendido). La marca y descripción se fueron a `PRODUCTO`, eliminando la dependencia parcial.

### D. Tabla: `SE_ABONA_CON`
*(Clave Primaria Compuesta: `{numero_ticket, id_medio_de_pago}`)*

| numero_ticket (PK, FK) | id_medio_de_pago (PK, FK) | monto_imputado |
| :---: | :---: | :---: |
| **101** | 1 | $3000 |
| **101** | 2 | $2100 |
| **102** | 5 | $1500 |

### E. Tabla: `MEDIO_DE_PAGO`
*(Clave Primaria: `id_medio_de_pago`)*

| id_medio_de_pago (PK) | Descripción |
| :---: | :--- |
| **1** | Efectivo |
| **2** | Tarjeta de Débito |
| **5** | Billetera Virtual |

---

## 4. Tercera Forma Normal (3FN): Eliminación de Dependencias Transitivas

**Regla:** Debe estar en 2FN y **ningún atributo no clave debe depender de otro atributo no clave** ($X \rightarrow Y \rightarrow Z$).

### Dependencias transitivas detectadas en 2FN:
1. En `PRODUCTO`: `id_producto` $\rightarrow$ `id_categoria` $\rightarrow$ `nombre_categoria`. El nombre de la categoría depende del código de categoría, no del producto.
2. En `VENTA`: `numero_ticket` $\rightarrow$ `dni_Cliente` $\rightarrow$ `nombre_cliente`. El nombre del cliente depende de su DNI, no del ticket.

### Solución aplicada para 3FN:

#### A. Aislamiento de `CATEGORIA`
Se extrae el nombre de la categoría a su propia tabla:

**`PRODUCTO`** *(en 3FN)*:
| id_producto (PK) | codigo_barra | Marca | precio_actual | stock_actual | stock_minimo | id_categoria (FK) |
| :---: | :---: | :--- | :---: | :---: | :---: | :---: |
| **1** | 779123456001 | La Serenísima | $1200 | 50 | 10 | 10 |
| **2** | 779123456002 | Matarazzo | $900 | 120 | 20 | 20 |
| **3** | 779123456003 | Gallo | $1500 | 80 | 15 | 20 |

**`CATEGORIA`** *(nueva tabla)*:
| id_categoria (PK) | nombre |
| :---: | :--- |
| **10** | Lácteos |
| **20** | Almacén |

#### B. Aislamiento de `PERSONA` y `CLIENTE`
Se extraen los datos personales del ticket hacia la tabla de personas:

**`PERSONA`** *(datos biográficos)*:
| DNI (PK) | nombre | apellido | cuil | teléfono | calle | número | ciudad | codigo_postal | provincia |
| :---: | :--- | :--- | :---: | :---: | :--- | :---: | :--- | :---: | :--- |
| **35123456** | Carlos | Gómez | 20351234568 | 3794112233 | San Martín | 1050 | Corrientes | 3400 | Corrientes |
| **28987654** | Ana | Martínez | 27289876544 | 3794998877 | Av. Italia | 420 | Resistencia | 3500 | Chaco |

**`CLIENTE`**:
| dni_Cliente (PK, FK) |
| :---: |
| **35123456** |
| **28987654** |

**`VENTA`** *(en 3FN, con claves foráneas e importes de comprobante)*:
| numero_ticket (PK) | fecha_hora | Subtotal | iva | total | dni_Empleado (FK) | dni_Cliente (FK) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **101** | 20/09/2026 10:15 | $4214.88 | $885.12 | $5100 | 30111222 | 35123456 |
| **102** | 20/09/2026 10:30 | $1239.67 | $260.33 | $1500 | 30111222 | 28987654 |

---

## 5. Esquema Relacional Definitivo (12 Tablas)

| N° | Nombre de Tabla | Clave Primaria (PK) | Claves Foráneas (FK) | Atributos No Clave |
| :---: | :--- | :--- | :--- | :--- |
| 1 | **`PERSONA`** | `DNI` | *(Ninguna)* | `nombre`, `apellido`, `cuil`, `correo_electronico`, `telefono`, `fecha_nacimiento`, `calle`, `número`, `ciudad`, `codigo_postal`, `provincia` |
| 2 | **`EMPLEADO`** | `dni_Empleado` | `dni_Empleado` $\rightarrow$ `PERSONA(DNI)` | `numero_legajo`, `rol` |
| 3 | **`CLIENTE`** | `dni_Cliente` | `dni_Cliente` $\rightarrow$ `PERSONA(DNI)` | *(Ninguno - hereda de Persona)* |
| 4 | **`CATEGORIA`** | `id_categoria` | *(Ninguna)* | `nombre` |
| 5 | **`PRODUCTO`** | `id_producto` | `id_categoria` $\rightarrow$ `CATEGORIA(id_categoria)` | `codigo_barra`, `Marca`, `precio_actual`, `stock_actual`, `stock_minimo` |
| 6 | **`DESCRIPCION_PRODUCTO`** | `id_descripcion` | `id_producto` $\rightarrow$ `PRODUCTO(id_producto)` | `detalle` |
| 7 | **`PROVEEDOR`** | `cuit` | *(Ninguna)* | `razon_social`, `teléfono`, `calle`, `número`, `ciudad`, `codigo_postal`, `provincia` |
| 8 | **`SUMINISTRA`** | `{cuit, id_producto}` | `cuit` $\rightarrow$ `PROVEEDOR(cuit)`<br>`id_producto` $\rightarrow$ `PRODUCTO(id_producto)` | *(Ninguno)* |
| 9 | **`MEDIO_DE_PAGO`** | `id_medio_de_pago` | *(Ninguna)* | `Descripción` |
| 10 | **`VENTA`** | `numero_ticket` | `dni_Empleado` $\rightarrow$ `EMPLEADO(dni_Empleado)`<br>`dni_Cliente` $\rightarrow$ `CLIENTE(dni_Cliente)` | `fecha_hora`, `Subtotal`, `iva`, `descuento`, `total` |
| 11 | **`DETALLE_VENTA`** | `{numero_ticket, id_producto}` | `numero_ticket` $\rightarrow$ `VENTA(numero_ticket)`<br>`id_producto` $\rightarrow$ `PRODUCTO(id_producto)` | `cantidad`, `precio_unitario_cobrado` |
| 12 | **`SE_ABONA_CON`** | `{numero_ticket, id_medio_de_pago}` | `numero_ticket` $\rightarrow$ `VENTA(numero_ticket)`<br>`id_medio_de_pago` $\rightarrow$ `MEDIO_DE_PAGO(id_medio_de_pago)` | `monto_imputado` |

---

## 6. Justificaciones Técnicas Avanzadas y Decisiones de Refinamiento

En respuesta al análisis formal y exhaustivo de la teoría relacional (Unidad 04 FaCENA), se documentan las siguientes tres decisiones de diseño:

### 6.1. Dependencia Funcional en Direcciones (Localidad y Código Postal)
- **Análisis Teórico:** En una normalización académica pura, existe la dependencia funcional:
  $$\text{codigo\_postal} \rightarrow \{\text{ciudad}, \text{provincia}\}$$
  Bajo este criterio estricto, mantener juntos `codigo_postal`, `ciudad` y `provincia` en `PERSONA` y `PROVEEDOR` introduce una dependencia transitiva formal:
  $$\text{DNI} \rightarrow \text{codigo\_postal} \rightarrow \{\text{ciudad}, \text{provincia}\}$$
- **Corrección teórica formal:** Podría extraerse la tabla:
  $$\text{LOCALIDAD}(\underline{\text{codigo\_postal}}, \text{ciudad}, \text{provincia})$$
  dejando únicamente `codigo_postal` como clave foránea en `PERSONA` y `PROVEEDOR`.
- **Decisión en el diseño implementado:** Se optó por mantener los campos de dirección descompuestos de forma atómica dentro de `PERSONA` y `PROVEEDOR` para evitar uniones (`JOINs`) adicionales en operaciones cotidianas de facturación y despacho, asumiendo este compromiso clásico de diseño en sistemas transaccionales comerciales.

### 6.2. Atributos Derivados en `VENTA` (Desnormalización Controlada por Requerimiento Fiscal)
- **Análisis Teórico:** Las columnas `Subtotal`, `iva`, `descuento` y `total` en la tabla `VENTA` son atributos derivados calculables a partir de los renglones de `DETALLE_VENTA` ($\text{Total} = \sum \text{cantidad} \times \text{precio\_unitario\_cobrado}$). En 3FN pura no deberían persistirse físicamente, sino resolverse mediante vistas o consultas calculadas.
- **Justificación según la Unidad 04 (Sección 6: Desnormalización):**
  Su inclusión en la tabla física responde a una **desnormalización controlada fundamentada** por dos razones de peso:
  1. **Requerimiento Legal y Fiscal (RN.05 y RN.08):** El ticket fiscal emitido es un documento tributario cerrado e inmutable. Persistir los totales congelados garantiza la integridad contable ante auditorías, previniendo que un eventual recálculo dinámico altere el valor histórico facturado.
  2. **Rendimiento OLTP:** Evita ejecutar agregaciones masivas (`SUM`) sobre miles de tuplas de detalle en cada consulta de arqueo de caja o informe de ventas diarias.

### 6.3. Análisis de la Relación 1:1 en `DESCRIPCION_PRODUCTO` (Particionamiento Vertical)
- **Análisis Teórico:** La tabla `DESCRIPCION_PRODUCTO` se vincula de manera 1:1 con `PRODUCTO` y contiene un único atributo funcional (`detalle`). En teoría estricta de normalización, si `id_producto` determina a `detalle`, este campo puede integrarse directamente como una columna más en `PRODUCTO`.
- **Justificación de Diseño:** La separación en una entidad independiente se fundamenta en la técnica de **particionamiento vertical de almacenamiento**:
  - Al aislar textos extensos de descripción o especificaciones técnicas en una tabla satélite, la tabla principal `PRODUCTO` conserva un tamaño de fila (*row size*) reducido y compacto.
  - Esto optimiza la lectura en el motor de base de datos (Microsoft SQL Server), permitiendo que quepan más tuplas por página de memoria en las consultas ultrarrápidas de cobro por escáner de código de barras en las líneas de caja.

---

## 7. Verificación de Propiedades de Descomposición

1. **Unión sin pérdida de información (Lossless-Join):** Toda descomposición utiliza como atributo común una superclave de las relaciones resultantes, garantizando que al unir las tablas mediante `JOIN` no se generen tuplas espurias ni se pierda fidelidad transaccional.
2. **Preservación de Dependencias:** El conjunto de restricciones funcionales del negocio se valida localmente mediante las claves primarias (`PK`) y de integridad referencial (`FK`), sin requerir validaciones cruzadas complejas entre tablas no vinculadas.
