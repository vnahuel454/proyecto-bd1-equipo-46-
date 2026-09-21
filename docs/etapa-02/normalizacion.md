# Refinamiento y Normalización del Modelo Relacional
### Bases de Datos I - FaCENA (UNNE)
**Proyecto:** Sistema de Gestión Comercial - Supermercado "El Sol"  
**Etapa:** 02 - Modelado Lógico y Normalización  

---

## 1. Introducción y Objetivos

El presente documento expone el proceso de refinamiento del esquema de base de datos para el **Supermercado "El Sol"**, aplicando los fundamentos de la teoría de normalización relacional introducida por Edgar F. Codd. 

El objetivo principal de este refinamiento es obtener un esquema lógico en **Tercera Forma Normal (3FN)** que minimice la redundancia de datos y evite la aparición de anomalías relacionales durante la operación del sistema:

- **Anomalías de Inserción:** Impedir que la carga de una entidad dependa artificialmente de la existencia de otra (por ejemplo, poder registrar un producto nuevo en el catálogo aun cuando todavía no ha tenido ventas, o registrar un proveedor sin exigir que ya suministre un producto).
- **Anomalías de Actualización:** Evitar que la modificación de un dato repetido en múltiples filas genere inconsistencias si alguna de ellas no se actualiza (por ejemplo, si cambia la razón social de un proveedor o el nombre de una categoría, se modifica en una única tupla).
- **Anomalías de Borrado:** Garantizar que la eliminación de un registro transaccional no provoque la pérdida involuntaria de información estructural independiente (por ejemplo, que al anular un ticket de venta no se elimine del catálogo el producto vendido ni se borre el registro del cliente o cajero).

---

## 2. Marco Teórico: Dependencias Funcionales

El proceso de normalización se fundamenta en el análisis riguroso de las **Dependencias Funcionales (DF)** que rigen entre los atributos del negocio.

Formalmente, una dependencia funcional se expresa como:

$$X \rightarrow Y$$

donde $X$ representa el conjunto de atributos determinante e $Y$ el dependiente, indicando que a cada valor de $X$ le corresponde un único valor de $Y$ en la relación.

Durante el análisis del supermercado se consideran tres tipos de dependencias:

1. **Dependencia Funcional Completa:** Un atributo $Y$ depende de forma completa de $X$ si $X \rightarrow Y$ y no depende de ningún subconjunto propio de $X$.
2. **Dependencia Parcial:** Ocurre cuando la clave primaria es compuesta y un atributo no clave depende únicamente de una parte de dicha clave.
3. **Dependencia Transitiva:** Se presenta cuando un atributo no clave depende de otro atributo no clave que, a su vez, depende de la clave primaria ($X \rightarrow Y$ e $Y \rightarrow Z$, siendo $Y$ no superclave).

---

## 3. Análisis Paso a Paso por Formas Normales

Partiendo de una concepción no normalizada del flujo comercial (donde un ticket de compra concentra datos del cliente, cajero, líneas de artículos, categorías, proveedores y formas de pago), se procedió a la descomposición progresiva del esquema.

### 3.1. Primera Forma Normal (1FN): Atomicidad y Claves Primarias

Una relación se encuentra en 1FN si:
- Todos sus atributos son atómicos (indivisibles en el contexto del negocio).
- Cada celda contiene un único valor.
- No existen grupos repetitivos ni atributos multivaluados.
- Se define una clave primaria única para cada relación.

#### Aplicación en el modelo:
- **Descomposición de atributos compuestos:** Los datos de localización y filiación identificados en el relevamiento conceptual se dividieron en atributos atómicos:
  - La dirección se descompuso en `calle`, `número`, `ciudad`, `codigo_postal` y `provincia`.
  - El nombre de las personas se dividió en `nombre` y `apellido`.
- **Eliminación de grupos repetitivos:** Un ticket de venta puede incluir múltiples productos y abonarse con varios medios de pago. Almacenar listas de productos o medios de pago dentro de la tabla `VENTA` violaría la 1FN. Por lo tanto, se descompuso en:
  - `VENTA`: Datos propios del comprobante.
  - `DETALLE_VENTA`: Cada línea de artículo vendida en una tupla independiente.
  - `SE_ABONA_CON`: Cada imputación de pago en una tupla independiente.

Todas las tablas resultantes poseen claves primarias unívocas (`DNI`, `numero_ticket`, `id_producto`, `cuit`, etc.).

---

### 3.2. Segunda Forma Normal (2FN): Eliminación de Dependencias Parciales

Una relación se encuentra en 2FN si:
- Se encuentra previamente en 1FN.
- Todos los atributos no clave tienen dependencia funcional completa respecto de la clave primaria (no existen dependencias parciales en tablas con claves compuestas).

En nuestro esquema, las tablas con claves primarias simples (`PERSONA`, `EMPLEADO`, `CLIENTE`, `VENTA`, `PRODUCTO`, `CATEGORIA`, `PROVEEDOR`, `MEDIO_DE_PAGO`, `DESCRIPCION_PRODUCTO`) cumplen 2FN por definición, ya que no pueden poseer subconjuntos propios de la clave primaria.

El análisis de 2FN se enfoca en las relaciones con **claves compuestas**:

#### A. Relación `DETALLE_VENTA`
- **Atributos:** `numero_ticket`, `id_producto`, `cantidad`, `precio_unitario_cobrado`.
- **Clave Primaria:** `{numero_ticket, id_producto}`.
- **Dependencias Funcionales:**
  - `{numero_ticket, id_producto}` $\rightarrow$ `cantidad`
  - `{numero_ticket, id_producto}` $\rightarrow$ `precio_unitario_cobrado`
- **Evaluación:** Ni la `cantidad` ni el `precio_unitario_cobrado` dependen únicamente del ticket ni únicamente del producto. Ambos datos requieren identificar la transacción y el artículo en conjunto. Atributos propios del producto como `Marca`, `codigo_barra` o `precio_actual` no se incluyeron en esta tabla, evitando dependencias parciales del tipo `{id_producto}` $\rightarrow$ `Marca`. Cumple 2FN.

#### B. Relación `SE_ABONA_CON`
- **Atributos:** `numero_ticket`, `id_medio_de_pago`, `monto_imputado`.
- **Clave Primaria:** `{numero_ticket, id_medio_de_pago}`.
- **Dependencias Funcionales:**
  - `{numero_ticket, id_medio_de_pago}` $\rightarrow$ `monto_imputado`
- **Evaluación:** El `monto_imputado` depende de la venta específica y del medio de pago utilizado para ese importe. La `Descripción` del medio de pago se mantuvo en su tabla independiente `MEDIO_DE_PAGO`, evitando dependencias parciales. Cumple 2FN.

#### C. Relación `SUMINISTRA`
- **Atributos:** `cuit`, `id_producto`.
- **Clave Primaria:** `{cuit, id_producto}`.
- **Evaluación:** Tabla de asociación muchos a muchos pura sin atributos no clave. Cumple 2FN por vacuidad.

---

### 3.3. Tercera Forma Normal (3FN): Eliminación de Dependencias Transitivas

Una relación se encuentra en 3FN si:
- Se encuentra previamente en 2FN.
- Ningún atributo no clave depende transitivamente de una clave primaria ($X \rightarrow Y \rightarrow Z$, donde $Y$ no es superclave ni clave candidata).

#### Análisis de relaciones clave:

#### A. `PRODUCTO`
- **Atributos:** `id_producto`, `codigo_barra`, `Marca`, `precio_actual`, `stock_actual`, `stock_minimo`, `id_categoria`.
- **Clave Primaria:** `id_producto` (con clave candidata `codigo_barra`).
- **Dependencias Funcionales:**
  - `id_producto` $\rightarrow$ `{codigo_barra, Marca, precio_actual, stock_actual, stock_minimo, id_categoria}`
- **Evaluación:** Si se hubiera incluido `nombre_categoria` dentro de `PRODUCTO`, existiría la dependencia transitiva:
  $$\text{id\_producto} \rightarrow \text{id\_categoria} \rightarrow \text{nombre\_categoria}$$
  Al aislar `CATEGORIA(id_categoria, nombre)` y conservar solo la clave foránea `id_categoria` en `PRODUCTO`, se eliminó dicha transitividad. Cumple 3FN.

#### B. `VENTA`
- **Atributos:** `numero_ticket`, `fecha_hora`, `Subtotal`, `iva`, `descuento`, `total`, `dni_Empleado`, `dni_Cliente`.
- **Clave Primaria:** `numero_ticket`.
- **Dependencias Funcionales:**
  - `numero_ticket` $\rightarrow$ `{fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente}`
- **Evaluación:** La tabla solo almacena las claves foráneas que identifican al cajero y al cliente. Datos como el nombre del cliente o el legajo del empleado no residen en `VENTA`, impidiendo transitividades como:
  $$\text{numero\_ticket} \rightarrow \text{dni\_Empleado} \rightarrow \text{numero\_legajo}$$
  Cumple 3FN.

#### C. Jerarquía `PERSONA`, `EMPLEADO` y `CLIENTE`
- **Estructura:**
  - `PERSONA(DNI, nombre, apellido, Cuil, Correo_electronico, telefono, fecha_nacimiento, Calle, número, Ciudad, codigo_postal, provincia)`
  - `EMPLEADO(dni_Empleado, numero_legajo, rol)` con `dni_Empleado` como PK y FK.
  - `CLIENTE(dni_Cliente)` con `dni_Cliente` como PK y FK.
- **Evaluación:** El supertipo `PERSONA` concentra los atributos generales compartidos, evitando duplicar nombres y contactos en tablas separadas. `EMPLEADO` solo almacena los atributos exclusivos de su condición laboral (`numero_legajo`, `rol`), cuyos valores dependen funcionalmente de la clave `dni_Empleado`. Cumple 3FN.

---

## 4. Esquema Lógico Relacional Resultante (en 3FN)

A continuación se detalla la estructura formal de las relaciones obtenidas tras el proceso de refinamiento. Se indican las claves primarias (PK) y foráneas (FK):

1. **PERSONA** (<u>DNI</u>, nombre, apellido, Cuil, Correo_electronico, telefono, fecha_nacimiento, Calle, número, Ciudad, codigo_postal, provincia)
   - *Claves Candidatas:* `DNI`, `Cuil`, `Correo_electronico`.

2. **EMPLEADO** (<u>dni_Empleado</u>, numero_legajo, rol)
   - *PK:* `dni_Empleado` (FK referencia a `PERSONA.DNI`).
   - *Clave Alternativa:* `numero_legajo`.

3. **CLIENTE** (<u>dni_Cliente</u>)
   - *PK:* `dni_Cliente` (FK referencia a `PERSONA.DNI`).

4. **CATEGORIA** (<u>id_categoria</u>, nombre)

5. **PRODUCTO** (<u>id_producto</u>, codigo_barra, Marca, precio_actual, stock_actual, stock_minimo, id_categoria)
   - *Clave Candidata:* `codigo_barra`.
   - *FK:* `id_categoria` referencia a `CATEGORIA.id_categoria`.

6. **DESCRIPCION_PRODUCTO** (<u>id_descripcion</u>, detalle, id_producto)
   - *FK:* `id_producto` referencia a `PRODUCTO.id_producto`.

7. **PROVEEDOR** (<u>cuit</u>, razon_social, teléfono, Calle, número, Ciudad, codigo_postal, provincia)

8. **SUMINISTRA** (<u>cuit</u>, <u>id_producto</u>)
   - *PK Compuesta:* `{cuit, id_producto}`.
   - *FK:* `cuit` referencia a `PROVEEDOR.cuit`.
   - *FK:* `id_producto` referencia a `PRODUCTO.id_producto`.

9. **MEDIO_DE_PAGO** (<u>id_medio_de_pago</u>, Descripción)

10. **VENTA** (<u>numero_ticket</u>, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    - *FK:* `dni_Empleado` referencia a `EMPLEADO.dni_Empleado`.
    - *FK:* `dni_Cliente` referencia a `CLIENTE.dni_Cliente`.

11. **DETALLE_VENTA** (<u>numero_ticket</u>, <u>id_producto</u>, cantidad, precio_unitario_cobrado)
    - *PK Compuesta:* `{numero_ticket, id_producto}`.
    - *FK:* `numero_ticket` referencia a `VENTA.numero_ticket`.
    - *FK:* `id_producto` referencia a `PRODUCTO.id_producto`.

12. **SE_ABONA_CON** (<u>numero_ticket</u>, <u>id_medio_de_pago</u>, monto_imputado)
    - *PK Compuesta:* `{numero_ticket, id_medio_de_pago}`.
    - *FK:* `numero_ticket` referencia a `VENTA.numero_ticket`.
    - *FK:* `id_medio_de_pago` referencia a `MEDIO_DE_PAGO.id_medio_de_pago`.

---

## 5. Propiedades de la Descomposición

El esquema refinado verifica las dos propiedades fundamentales exigidas por la teoría relacional:

1. **Unión sin pérdida de información (Lossless-Join):** Toda descomposición realizada utiliza como nexo una clave primaria o superclave de alguna de las relaciones resultantes, garantizando que la reconstrucción de la información mediante operaciones de reunión natural (`NATURAL JOIN`) no genere tuplas espurias.
2. **Preservación de Dependencias:** El conjunto de dependencias funcionales inherentes a las reglas de negocio del supermercado puede ser verificado íntegramente dentro de cada una de las tablas individuales a través de sus restricciones de clave primaria y claves foráneas, sin requerir la ejecución de uniones costosas.

---

## 6. Conclusión

El esquema obtenido para el **Supermercado "El Sol"** se encuentra rigurosamente normalizado en **Tercera Forma Normal (3FN)**. Esta estructura proporciona una base sólida para su posterior implementación física en Microsoft SQL Server, eliminando redundancias operativas, asegurando la integridad referencial histórica en la facturación y optimizando el desempeño para transacciones comerciales de tipo OLTP.
