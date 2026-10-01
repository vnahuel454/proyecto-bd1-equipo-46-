# Documentación de Restricciones de Integridad

## 1. Integridad de Entidad (`PRIMARY KEY`)

Garantiza la univalidez de cada fila dentro de las tablas del sistema, evitando registros duplicados o valores nulos en los atributos identificadores.

### A. Claves Primarias Simples
* **`PERSONA` → `PRIMARY KEY (dni)`**: Identificador natural e invariable de las personas físicas.
* **`EMPLEADO` → `PRIMARY KEY (dni)`**: Clave compartida con `PERSONA` que implementa la herencia (1:1) de la subclase.
* **`CLIENTE` → `PRIMARY KEY (dni)`**: Clave compartida con `PERSONA` que implementa la herencia (1:1) de la subclase.
* **`PROVEEDOR` → `PRIMARY KEY (cuit)`**: Identificador fiscal unívoco de las empresas/proveedores.
* **`MEDIO_DE_PAGO` → `PRIMARY KEY (id_medio_de_pago)`**: Código numérico único para cada modalidad de pago (Efectivo, Tarjeta, etc.).
* **`CATEGORIA` → `PRIMARY KEY (id_categoria)`**: Identificador de las familias o rubros de productos.
* **`PRODUCTO` → `PRIMARY KEY (id_producto)`**: Código interno correlativo para el control de inventario de cada artículo.
* **`VENTA` → `PRIMARY KEY (numero_ticket)`**: Identificador del comprobante / ticket emitido en caja.

### B. Claves Primarias Compuestas (Tablas de Relación M:N)
* **`SE_ABONA_CON` → `PRIMARY KEY (numero_ticket, id_medio_de_pago)`**: Permite que un mismo ticket de venta sea pagado con múltiples medios de pago (pago mixto).
* **`SUMINISTRA` → `PRIMARY KEY (cuit, id_producto)`**: Modela la relación M:N entre proveedores y productos (un proveedor abastece varios productos y un producto puede ser provisto por varios proveedores).
* **`DETALLE_VENTA` → `PRIMARY KEY (numero_ticket, id_producto)`**: Modela las líneas de items asociadas a cada ticket comercial.

---

## 2. Integridad Referencial (`FOREIGN KEY`)

Garantiza la consistencia lógica entre tablas relacionadas, regulando el comportamiento ante operaciones de actualización (`UPDATE`) o eliminación (`DELETE`).

| Tabla Origen | Columna FK | Tabla Destino | Columna PK | `ON UPDATE` | `ON DELETE` | Justificación |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`EMPLEADO`** | `dni` | `PERSONA` | `dni` | `CASCADE` | `CASCADE` | Un empleado no existe sin su registro en `PERSONA`. Al borrar la persona se elimina la subclase. |
| **`CLIENTE`** | `dni` | `PERSONA` | `dni` | `CASCADE` | `CASCADE` | Misma regla de herencia (1:1) aplicada a los clientes. |
| **`PRODUCTO`** | `id_categoria` | `CATEGORIA` | `id_categoria` | `CASCADE` | `NO ACTION` | Evita borrar categorías que tengan productos asociados comercialmente. |
| **`VENTA`** | `dni_Empleado` | `EMPLEADO` | `dni` | `NO ACTION` | `NO ACTION` | Preserva el historial de ventas realizadas aunque el empleado cambie o sea dado de baja. |
| **`VENTA`** | `dni_Cliente` | `CLIENTE` | `dni` | `NO ACTION` | `NO ACTION` | Mantiene el registro histórico de comprobantes asociados al cliente. |
| **`SE_ABONA_CON`** | `numero_ticket` | `VENTA` | `numero_ticket` | `CASCADE` | `CASCADE` | Si se elimina el ticket de venta, se eliminan sus pagos asociados. |
| **`SE_ABONA_CON`** | `id_medio_de_pago` | `MEDIO_DE_PAGO` | `id_medio_de_pago` | `CASCADE` | `NO ACTION` | Protege los medios de pago en uso evitando eliminaciones accidentales si existen transacciones registradas. |
| **`SUMINISTRA`** | `cuit` | `PROVEEDOR` | `cuit` | `CASCADE` | `CASCADE` | Si un proveedor se elimina del sistema, se limpian sus vínculos de suministro. |
| **`SUMINISTRA`** | `id_producto` | `PRODUCTO` | `id_producto` | `CASCADE` | `CASCADE` | Si se elimina un producto, se remueven sus relaciones con proveedores. |
| **`DETALLE_VENTA`** | `numero_ticket` | `VENTA` | `numero_ticket` | `CASCADE` | `CASCADE` | Eliminar una venta borra automáticamente sus líneas de detalle. |
| **`DETALLE_VENTA`** | `id_producto` | `PRODUCTO` | `id_producto` | `CASCADE` | `NO ACTION` | Impide eliminar productos del catálogo si ya fueron vendidos en algún ticket histórico. |

---

## 3. Restricciones de Unicidad (`UNIQUE`)

Evitan la duplicación de datos en atributos que no son clave primaria pero funcionan como claves candidatas:

* **`PERSONA(cuil)` → `uq_persona_cuil`**: No pueden existir dos personas con el mismo número de CUIL.
* **`PERSONA(correo_electronico)` → `uq_persona_email`**: No se permiten dos personas registradas con el mismo email.
* **`EMPLEADO(numero_legajo)` → `uq_empleado_legajo`**: Cada empleado debe poseer un legajo único en la empresa.
* **`PROVEEDOR(razon_social)` → `UQ_Proveedor_RazonSocial`**: Evita dar de alta dos veces a la misma Razón Social.
* **`PRODUCTO(codigo_barra)` → `UQ_Producto_CodigoBarra`**: Garantiza que el código EAN/UPC sea único por artículo para la lectura en caja.

---

## 4. Restricciones de Verificación (`CHECK`)

Aplican reglas de dominio y de negocio específicas sobre los valores permitidos en las columnas:

* **`PERSONA` → `CONSTRAINT ck_persona_dni_positivo CHECK (dni >= 0)`**:
  * Permite registrar ventas anónimas / cliente genérico mediante el **DNI `0` (Consumidor Final)** y rechaza valores negativos.
* **`EMPLEADO` → `CONSTRAINT ck_empleado_rol CHECK (rol IN ('Cajero', 'Repositor', 'Gerente', 'Encargado de Depósito', 'Administrativo'))`**:
  * Limita los cargos laborales exclusivamente a los roles operativos autorizados por el supermercado.
* **`PROVEEDOR` → `CONSTRAINT CK_Proveedor_CUIT CHECK (LEN(cuit) = 11 AND cuit NOT LIKE '%[^0-9]%')`**:
  * Exige que el CUIT contenga exactamente 11 caracteres numéricos continuos, bloqueando letras o símbolos.
* **`PRODUCTO`**:
  * `CK_Producto_PrecioPositivo`: `precio_actual > 0` (el precio de venta debe ser estrictamente positivo).
  * `CK_Producto_StockActualPositivo`: `stock_actual >= 0` (evita stocks negativos).
  * `CK_Producto_StockMinimoPositivo`: `stock_minimo >= 0` (el umbral de reposición no puede ser negativo).
* **`SE_ABONA_CON` → `CONSTRAINT CK_SE_ABONA_CON_Monto CHECK (monto_imputado > 0)`**:
  * Garantiza que los pagos registrados tengan un importe monetario real mayor a cero.
* **`DETALLE_VENTA` → `CONSTRAINT CK_DETALLE_VENTA_Cantidad CHECK (Cantidad >= 0)`**:
  * Valida que las unidades vendidas por renglón sean de cantidad válida.

---

## 5. Nulabilidad y Valores por Defecto (`NOT NULL` / `DEFAULT`)

### A. Opcionalidad de Atributos (`NULL` vs `NOT NULL`)
* **`telefono` en `PERSONA` (`NULL`)**: Se define opcional debido a que no todos los clientes o consumidores finales proporcionan teléfono de contacto.
* **Resto de atributos principales (`NOT NULL`)**: Datos fundamentales como nombres, precios, direcciones, fechas y montos se exigen obligatoriamente para prevenir inconsistencias.

### B. Valores por Defecto (`DEFAULT`)
* **`VENTA(descuento)` → `DEFAULT 0.00`**: Si no se especifica una bonificación, la venta inicia con descuento cero.
* **`SE_ABONA_CON` y `DETALLE_VENTA` (Auditoría de Registro)**:
  * `fecha_registro DATETIME DEFAULT GETDATE() NOT NULL`: Captura la marca temporal exacta del servidor al registrar la transacción.
  * `usuario_registro VARCHAR(100) DEFAULT SYSTEM_USER NOT NULL`: Asigna automáticamente el usuario de SQL Server que realizó la operación.
