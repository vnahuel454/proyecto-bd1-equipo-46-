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
| `ROLLBACK TRANSACTION` | Deshace todos los cambios desde el `BEGIN`(con transacciones anidadas, deshace hasta la más externa) |
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

**Capturas:** en `evidencias/`, una de Resultados y otra de Mensajes por prueba: `prueba1_correcta.png` y `prueba1_mensajes.png`, `prueba2_stock_insuficiente.png` y `prueba2_mensajes.png`, `prueba3_atomicidad.png` y `prueba3_mensajes.png`, `prueba4_caso_limite.png` y `prueba4_mensajes.png`, y `resumen_final.png`.

Aclaracion: Las pruebas 5 y 6 se ejecutaron después de volver a correr el bloque de reseteo, por eso la venta de la prueba 5 también recibe el ticket 1011.

## 6. Transacciones anidadas

En SQL Server se pueden abrir transacciones dentro de otras. La función `@@TRANCOUNT` cuenta cuántas hay abiertas. Dos reglas:

- Cada `BEGIN TRANSACTION` suma 1 al contador y cada `COMMIT` interno resta 1, **sin confirmar nada definitivo**. Los cambios se confirman recién con el `COMMIT` de la transacción más externa.
- Un `ROLLBACK` deshace **todo** hasta la transacción más externa y deja el contador en 0, aunque las transacciones internas ya hubieran hecho `COMMIT`.

**Caso aplicado:** venta de dos productos. La venta es la transacción externa y cada línea de detalle (insertar el detalle y descontar el stock) es una transacción interna.

**Demostración básica del contador** (sin modificar datos): al abrir la externa el contador vale 1, al abrir la interna 2, tras el `COMMIT` interno vuelve a 1 y tras el `ROLLBACK` queda en 0.

| Prueba | Datos | Resultado obtenido | Qué demuestra |
|---|---|---|---|
| 5. Venta de 2 productos | Producto 3 × 5 y producto 6 × 10 | `@@TRANCOUNT`: 1, 2, 1, 2, 1 y `COMMIT` final con 0. Ticket 1011 (subtotal 22000,00, IVA 4620,00, total 26620,00) con 2 líneas de detalle. Stock: producto 3 de 80 a 75 y producto 6 de 35 a 25 | Los `COMMIT` internos solo bajan el contador. Todo se confirma con el `COMMIT` externo |
| 6. Falla en la segunda línea | Producto 3 × 5 y producto 6 × 40 (stock 35) | La línea 1 hace su `COMMIT` interno (contador 1). La línea 2 viola `CK_Producto_StockActualPositivo` (contador 2 antes del `ROLLBACK`, 0 después). No queda ticket ni detalle. Stock del producto 3 de nuevo en 80 y del 6 en 35 | Un `ROLLBACK` deshace también lo que las transacciones internas ya habían "confirmado" |

**Capturas:** `evidencias/anidadas_trancount.png`, `anidadas_prueba5_resultados.png`, `anidadas_prueba5_mensajes.png`, `anidadas_prueba6_resultados.png`, `anidadas_prueba6_mensajes.png`.

## 7. Conclusiones

- Registrar una venta modifica tres tablas (VENTA, DETALLE_VENTA y PRODUCTO). Con una transacción, todas cambian juntas o ninguna cambia. En las pruebas 2, 3 y 6 el `ROLLBACK` dejó la base exactamente como estaba.
- Las validaciones previas (por ejemplo, stock insuficiente) frenan la venta antes de operar. El `CHECK` de la tabla actúa como segunda defensa y la prueba 3 mostró que el `ROLLBACK` también deshace operaciones que ya se habían ejecutado.
- Calcular el número de ticket dentro de la transacción evitó huecos en la numeración: tras dos operaciones revertidas, la siguiente venta tomó el número consecutivo.
- En transacciones anidadas, el `COMMIT` interno no es definitivo. Solo importa el `COMMIT` de la transacción más externa, y un `ROLLBACK` en cualquier nivel deshace todo. Por eso, en una venta de varios productos, una línea que falla anula la venta completa.
- **Limitaciones:** las pruebas se hicieron en una sola sesión, por lo que no se comprobó el comportamiento con ventas simultáneas. Para deshacer solo una parte de una transacción habría que usar puntos de control (`SAVE TRANSACTION`), que no se implementaron.
