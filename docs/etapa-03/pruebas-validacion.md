# Pruebas de Validación — Proyecto completo (11 tablas)

## 1. Verificación de carga completa

Tras ejecutar el DDL y el DML consolidado, se verifica que cada tabla 
contenga el número esperado de registros:

```sql
SELECT 'PERSONA' AS Tabla, COUNT(*) AS Registros FROM PERSONA
UNION ALL SELECT 'EMPLEADO', COUNT(*) FROM EMPLEADO
UNION ALL SELECT 'CLIENTE', COUNT(*) FROM CLIENTE
UNION ALL SELECT 'CATEGORIA', COUNT(*) FROM CATEGORIA
UNION ALL SELECT 'PRODUCTO', COUNT(*) FROM PRODUCTO
UNION ALL SELECT 'PROVEEDOR', COUNT(*) FROM PROVEEDOR
UNION ALL SELECT 'SUMINISTRA', COUNT(*) FROM SUMINISTRA
UNION ALL SELECT 'MEDIO_DE_PAGO', COUNT(*) FROM MEDIO_DE_PAGO
UNION ALL SELECT 'VENTA', COUNT(*) FROM VENTA
UNION ALL SELECT 'DETALLE_VENTA', COUNT(*) FROM DETALLE_VENTA
UNION ALL SELECT 'SE_ABONA_CON', COUNT(*) FROM SE_ABONA_CON;
```

**Resultado esperado:** 13 Personas, 8 Empleados, 8 Clientes, 4 Categorías, 
8 Productos, 10 Proveedores, 11 Suministra, 10 Medios de Pago, 10 Ventas, 
14 Detalle_Venta, 14 Se_Abona_Con. Ninguna tabla en 0, confirmando que el 
DML completo se ejecutó sin errores de orden ni de FK.

## 2. Integridad referencial entre bloques

### Prueba 2.1 — Venta con cliente inexistente

```sql
INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
VALUES (9999, '2026-04-01 10:00:00', 1000, 210, 0, 1210, 38333444, 99999999);
```

**Resultado esperado:** rechazado. `99999999` no existe en `CLIENTE`, 
viola la FK `fk_venta_cliente`.

### Prueba 2.2 — Detalle_Venta con producto inexistente

```sql
INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
VALUES (1001, 999, 1, 500);
```

**Resultado esperado:** rechazado. `id_producto = 999` no existe en 
`PRODUCTO`, viola `FK_DETALLE_VENTA_PRODUCTO`.

---

**Nota metodológica — pruebas destructivas (2.3 a 2.5):** las siguientes 
tres pruebas ejecutan sentencias `DELETE` reales sobre los datos. Para no 
perder la carga original de prueba, estas pruebas se ejecutaron sobre una 
base de datos de prueba independiente (`SupermercadoElSol_Pruebas`), 
creada ejecutando el mismo script DDL y DML sobre una base nueva y vacía, 
en lugar de modificar la base de trabajo habitual del equipo.

```sql
CREATE DATABASE SupermercadoElSol_Pruebas;
GO
USE SupermercadoElSol_Pruebas;
GO
```

---

### Prueba 2.3 — Borrado de un Producto con ventas asociadas (ON DELETE NO ACTION)
*(ejecutada sobre la copia de la base)*

```sql
DELETE FROM PRODUCTO WHERE id_producto = 1;
```

**Resultado esperado:** rechazado. `id_producto = 1` está referenciado en 
`DETALLE_VENTA`, y esa FK tiene `ON DELETE NO ACTION` — el motor protege 
el historial de ventas aunque el producto deje de comercializarse.

### Prueba 2.4 — Borrado en cascada de una Venta (ON DELETE CASCADE)
*(ejecutada sobre la copia de la base)*

```sql
DELETE FROM VENTA WHERE numero_ticket = 1006;
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = 1006;
SELECT * FROM SE_ABONA_CON WHERE numero_ticket = 1006;
```

**Resultado esperado:** la venta se borra, y las líneas de 
`DETALLE_VENTA` y `SE_ABONA_CON` con ese ticket se eliminan 
automáticamente (ambas FK tienen `ON DELETE CASCADE` hacia `VENTA`), sin 
dejar registros huérfanos. Las dos consultas `SELECT` deben devolver 0 
filas después del `DELETE`.

### Prueba 2.5 — Borrado en cascada de Persona hacia Empleado/Cliente
*(ejecutada sobre la copia de la base)*

```sql
DELETE FROM PERSONA WHERE dni = 39222111;
SELECT * FROM EMPLEADO WHERE dni = 39222111;
```

**Resultado esperado:** al borrar la Persona, el registro correspondiente 
en `EMPLEADO` se borra automáticamente (`fk_empleado_persona` tiene 
`ON DELETE CASCADE`). Esto confirma por qué esta prueba se reserva para 
la copia: en la base real, borrar una Persona empleada eliminaría en 
cascada información de un empleado con historial de ventas asociado.

## 3. Restricciones propias de cada bloque

### Prueba 3.1 — Precio no positivo (CHECK)
```sql
INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (99, '779999999999', 'Marca Test', 'Producto de prueba', 0, 10, 5, 10);
```
**Resultado esperado:** rechazado por `CK_Producto_PrecioPositivo`, que 
exige `precio_actual > 0` (estrictamente mayor, no admite cero).

### Prueba 3.2 — Código de barra duplicado (UNIQUE)
```sql
INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (99, '779123456001', 'Marca Test', 'Producto de prueba', 500, 10, 5, 10);
```
**Resultado esperado:** rechazado, código ya usado por el producto id=1 
(`UQ_Producto_CodigoBarra`).

### Prueba 3.3 — Rol de empleado no permitido (CHECK)
```sql
INSERT INTO EMPLEADO (dni, numero_legajo, rol) VALUES (29999000, 2001, 'Pasante');
```
**Resultado esperado:** rechazado por `ck_empleado_rol`, que solo admite 
'Cajero', 'Repositor', 'Gerente', 'Encargado de Depósito' o 
'Administrativo'.

### Prueba 3.4 — CUIT de proveedor con formato inválido (CHECK)
```sql
INSERT INTO PROVEEDOR (cuit, razon_social, telefono, calle, numero, ciudad, codigo_postal, provincia)
VALUES ('ABC12345678', 'Proveedor Test', '123456', 'Calle Falsa', '123', 'Corrientes', '3400', 'Corrientes');
```
**Resultado esperado:** rechazado por `CK_Proveedor_CUIT`, que exige 
exactamente 11 caracteres numéricos.

## 4. Validación de reglas de negocio no forzable por constraint

### Prueba 4.1 — Toda venta debe estar registrada por un Cajero (RN.07)

El `CHECK` de rol admite 'Gerente', 'Repositor', etc. como roles válidos 
de Empleado en general, pero no puede exigir que *específicamente en 
Venta* el empleado sea Cajero. Se valida con una subconsulta de control:

```sql
SELECT numero_ticket, dni_Empleado
FROM VENTA
WHERE dni_Empleado NOT IN (
    SELECT dni FROM EMPLEADO WHERE rol = 'Cajero'
);
```

**Resultado esperado:** 0 filas, una vez corregidos los tickets 1005 y 
1009 (que originalmente usaban al Gerente en lugar de un Cajero).