# Etapa V – Manejo de transacciones

**Equipo 46 – Supermercado "El Sol"** · Alumna: Luz Espíndola

## 1. Definición y objetivo

Una **transacción** es un conjunto de operaciones SQL que se ejecutan como una única unidad lógica de trabajo: o se confirman todas juntas (`COMMIT`) o, si alguna falla, se deshacen todas (`ROLLBACK`) y la base vuelve al estado anterior.

**Objetivo en el sistema de ventas:** que registrar una venta nunca deje información incompleta. Una venta toca tres tablas (VENTA, DETALLE_VENTA y PRODUCTO) y las tres deben cambiar juntas.

## 2. Ventajas y aplicaciones

Las transacciones garantizan las propiedades **ACID**:

| Propiedad | Qué asegura | Cómo se ve en nuestra venta |
|---|---|---|
| Atomicidad | Se hace todo o no se hace nada | Si falla el descuento de stock, no queda ni la venta ni el detalle |
| Consistencia | Se respetan las reglas de la base | El stock no puede quedar negativo (`CHECK stock_actual >= 0`) |
| Aislamiento | Dos operaciones simultáneas no se interfieren | Con el bloqueo UPDLOCK, HOLDLOCK, dos ventas simultáneas no deberían tomar el mismo número de ticket (diseño; no se probó con ventas concurrentes) |
| Durabilidad | Lo confirmado no se pierde | Después del `COMMIT`, la venta queda guardada |

**Aplicaciones:** registro de ventas, ajustes de stock, cobros con varios medios de pago y cualquier operación que modifique varias tablas a la vez.

## 3. Implementación en SQL Server Express

| Instrucción | Función |
|---|---|
| `BEGIN TRANSACTION` | Abre la transacción: lo que sigue todavía no es definitivo |
| `COMMIT TRANSACTION` | Confirma todos los cambios |
| `ROLLBACK TRANSACTION` | Deshace todos los cambios desde el `BEGIN` |
| `BEGIN TRY … BEGIN CATCH` | Captura cualquier error y salta al bloque de manejo |
| `THROW` | Lanza un error a propósito (se usa para las validaciones) |
| `@@TRANCOUNT` | Indica cuántas transacciones hay abiertas; se consulta antes de hacer `ROLLBACK` |
| `WITH (UPDLOCK, HOLDLOCK)` | Mantiene un bloqueo hasta el final de la transacción (aislamiento) |

Estructura usada:

```sql
BEGIN TRY
    BEGIN TRANSACTION;
    -- validaciones, INSERT en VENTA, INSERT en DETALLE_VENTA, UPDATE de stock
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;
```

## 4. Caso aplicado al sistema de ventas

**Venta con control de stock.** Un cliente compra una cantidad de un producto. La operación debe:

1. Validar los datos (cantidad mayor a cero, empleado con rol Cajero, producto existente y stock suficiente).
2. Crear la venta (`VENTA`).
3. Crear el detalle (`DETALLE_VENTA`).
4. Descontar el stock (`PRODUCTO.stock_actual`).

Si no hay stock suficiente, no se registra la venta, ni el detalle, ni se modifica el stock.

**Reglas de negocio vinculadas**

- **RN.05:** el detalle guarda el precio vigente al momento de la venta (`precio_unitario_cobrado`), para que el comprobante no cambie si el precio se modifica después.
- **RN.07:** cada venta la registra un empleado con rol Cajero; el script lo valida.

**Decisiones de implementación**

- **Número de ticket:** no se escribe a mano. Se calcula como `MAX(numero_ticket) + 1` dentro de la transacción y con bloqueo (`UPDLOCK, HOLDLOCK`). Así sigue la numeración sin huecos y, si la venta se revierte, el número no se consume.
- **IVA y total:** se calculan a partir del subtotal (cantidad × precio). La tasa del 21 % se guarda en una variable (`@tasa_iva`), tomada de los datos de la Etapa III.
- **Cantidad:** el script exige `Cantidad > 0`. El `CHECK` actual de `DETALLE_VENTA` permite 0 (`Cantidad >= 0`); se sugiere al equipo cambiarlo a `> 0`.
- **Descuento:** se registra en 0. Su cálculo corresponde a la función de descuento por cliente (Tema 1).

## 5. Script de demostración y resultados

Script: `scripts.sql`. Evidencias: carpeta `evidencias/`. Las pruebas se ejecutaron en una copia local de la base, en este orden (el script incluye al inicio un bloque de reseteo para repetirlas):

| Prueba | Datos | Resultado obtenido | Qué demuestra |
|---|---|---|---|
| 1. Venta correcta | Producto 3 (stock 80), cantidad 5 | `COMMIT`. Ticket 1011, total 9075,00. Stock 80 → 75 | Las tres operaciones se confirman juntas |
| 2. Stock insuficiente | Producto 6 (stock 35), cantidad 40 | `ROLLBACK` ("Stock insuficiente"). Stock sigue en 35. No se crea ticket | La validación frena la venta antes de operar |
| 3. Atomicidad real | Producto 6, cantidad 40, sin validar stock | `ROLLBACK`: el `UPDATE` viola `CK_Producto_StockActualPositivo` después de los dos `INSERT`. No queda ninguna fila del ticket. Stock sigue en 35 | El `ROLLBACK` deshace operaciones ya ejecutadas |
| 4. Caso límite | Producto 6, cantidad 35 (todo el stock) | `COMMIT`. Ticket 1012, stock 35 → 0 | Se puede vender exactamente el stock disponible |

**Observación sobre la numeración:** la prueba 4 recibe el ticket **1012**, el siguiente al 1011, aunque entre ambas hubo dos operaciones revertidas. No quedaron huecos.

**Capturas:** `evidencias/prueba1_correcta.png`, `prueba2_stock_insuficiente.png`, `prueba3_atomicidad.png`, `prueba4_caso_limite.png`.
