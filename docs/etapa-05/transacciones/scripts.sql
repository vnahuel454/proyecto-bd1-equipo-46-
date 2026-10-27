USE SupermercadoElSol;
GO

/* ============================================================
   Etapa V - Transacciones: venta con control de stock
   Alumna: Luz Espíndola - Equipo 46 - Supermercado El Sol
   Objetivo: demostrar atomicidad. La venta, el detalle y el
   descuento de stock se confirman juntos o no se guarda nada.
   RN.05: el detalle guarda el precio vigente al momento de la venta.
   RN.07: la venta la registra un empleado con rol Cajero.
   Contenido: bloque 0 (reseteo) + 4 pruebas + resumen final
              + demo de transacciones anidadas y pruebas 5 y 6.
   ============================================================ */
SET NOCOUNT ON;
GO


/* ---------------------------------------------------------------
   BLOQUE 0 - RESETEO (solo para la base de pruebas)
   Borra las ventas de prueba (tickets > 1010): primero su detalle y
   después la cabecera. Restaura el stock original de los productos 3 y 6.
   --------------------------------------------------------------- */
PRINT '===== BLOQUE 0: RESETEO =====';
DELETE FROM DETALLE_VENTA WHERE numero_ticket > 1010;
DELETE FROM VENTA WHERE numero_ticket > 1010;
UPDATE PRODUCTO SET stock_actual = 80 WHERE id_producto = 3;
UPDATE PRODUCTO SET stock_actual = 35 WHERE id_producto = 6;
SELECT MAX(numero_ticket) AS ultimo_ticket_original FROM VENTA;              -- debe dar 1010
SELECT id_producto, stock_actual FROM PRODUCTO WHERE id_producto IN (3, 6);   -- debe dar 80 y 35
GO


/* ------------------------------------------------------------
   PRUEBA 1 - VENTA CORRECTA
   Producto 3 (stock 80), cantidad 5. Resultado esperado: COMMIT,
   ticket 1011, stock 80 -> 75, total 9075.00
   ------------------------------------------------------------ */
PRINT '';
PRINT '===== PRUEBA 1: VENTA CORRECTA (producto 3, cantidad 5) =====';

-- Datos de la venta
DECLARE @id_producto   INT = 3;
DECLARE @cantidad      INT = 5;
DECLARE @validar_stock BIT = 1;                -- 0 = saltear la validación (solo prueba 3)
DECLARE @dni_cliente   INT = 29999000;
DECLARE @dni_empleado  INT = 38333444;         -- empleado con rol Cajero
DECLARE @tasa_iva      DECIMAL(4,2) = 0.21;    -- 21 %, tasa de los datos de la Etapa III

-- Variables que se calculan solas
DECLARE @numero_ticket INT;
DECLARE @precio        DECIMAL(10,2);
DECLARE @stock         INT;
DECLARE @subtotal      DECIMAL(10,2);
DECLARE @iva           DECIMAL(10,2);

-- Estado antes
SELECT id_producto, detalle, stock_actual AS stock_antes FROM PRODUCTO WHERE id_producto = @id_producto;

BEGIN TRY
    BEGIN TRANSACTION;                                    -- desde acá nada es definitivo

    IF @cantidad <= 0
        THROW 50002, 'La cantidad debe ser mayor a cero', 1;

    IF NOT EXISTS (SELECT 1 FROM EMPLEADO WHERE dni = @dni_empleado AND rol = 'Cajero')
        THROW 50003, 'La venta debe registrarla un empleado con rol Cajero (RN.07)', 1;

    SELECT @precio = precio_actual, @stock = stock_actual
    FROM PRODUCTO WHERE id_producto = @id_producto;

    IF @precio IS NULL
        THROW 50004, 'El producto no existe', 1;

    IF @validar_stock = 1 AND @stock < @cantidad
        THROW 50001, 'Stock insuficiente', 1;

    SELECT @numero_ticket = ISNULL(MAX(numero_ticket), 0) + 1     -- siguiente ticket, sin saltear
    FROM VENTA WITH (UPDLOCK, HOLDLOCK);

    SET @subtotal = @cantidad * @precio;                          -- RN.05: precio vigente
    SET @iva      = ROUND(@subtotal * @tasa_iva, 2);

    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, 0, @subtotal + @iva, @dni_empleado, @dni_cliente);

    INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
    VALUES (@numero_ticket, @id_producto, @cantidad, @precio);

    UPDATE PRODUCTO SET stock_actual = stock_actual - @cantidad WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;                                   -- todo OK: se guarda junto
    PRINT '>>> COMMIT: venta ' + CAST(@numero_ticket AS varchar(10)) + ' registrada';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;              -- algo falló: se deshace todo
    PRINT '>>> ROLLBACK. Motivo: ' + ERROR_MESSAGE();
END CATCH;

-- Estado después
SELECT id_producto, stock_actual AS stock_despues FROM PRODUCTO WHERE id_producto = @id_producto;
SELECT * FROM VENTA         WHERE numero_ticket = @numero_ticket;   -- 1 fila si COMMIT, vacío si ROLLBACK
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = @numero_ticket;
GO


/* ------------------------------------------------------------
   PRUEBA 2 - STOCK INSUFICIENTE
   Producto 6 (stock 35), cantidad 40. Resultado esperado: ROLLBACK
   ("Stock insuficiente"), stock sigue en 35, no se crea ticket.
   ------------------------------------------------------------ */
PRINT '';
PRINT '===== PRUEBA 2: STOCK INSUFICIENTE (producto 6, cantidad 40) =====';

DECLARE @id_producto   INT = 6;
DECLARE @cantidad      INT = 40;
DECLARE @validar_stock BIT = 1;
DECLARE @dni_cliente   INT = 29999000;
DECLARE @dni_empleado  INT = 38333444;
DECLARE @tasa_iva      DECIMAL(4,2) = 0.21;

DECLARE @numero_ticket INT;
DECLARE @precio        DECIMAL(10,2);
DECLARE @stock         INT;
DECLARE @subtotal      DECIMAL(10,2);
DECLARE @iva           DECIMAL(10,2);

SELECT id_producto, detalle, stock_actual AS stock_antes FROM PRODUCTO WHERE id_producto = @id_producto;

BEGIN TRY
    BEGIN TRANSACTION;

    IF @cantidad <= 0
        THROW 50002, 'La cantidad debe ser mayor a cero', 1;

    IF NOT EXISTS (SELECT 1 FROM EMPLEADO WHERE dni = @dni_empleado AND rol = 'Cajero')
        THROW 50003, 'La venta debe registrarla un empleado con rol Cajero (RN.07)', 1;

    SELECT @precio = precio_actual, @stock = stock_actual
    FROM PRODUCTO WHERE id_producto = @id_producto;

    IF @precio IS NULL
        THROW 50004, 'El producto no existe', 1;

    IF @validar_stock = 1 AND @stock < @cantidad
        THROW 50001, 'Stock insuficiente', 1;

    SELECT @numero_ticket = ISNULL(MAX(numero_ticket), 0) + 1
    FROM VENTA WITH (UPDLOCK, HOLDLOCK);

    SET @subtotal = @cantidad * @precio;
    SET @iva      = ROUND(@subtotal * @tasa_iva, 2);

    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, 0, @subtotal + @iva, @dni_empleado, @dni_cliente);

    INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
    VALUES (@numero_ticket, @id_producto, @cantidad, @precio);

    UPDATE PRODUCTO SET stock_actual = stock_actual - @cantidad WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;
    PRINT '>>> COMMIT: venta ' + CAST(@numero_ticket AS varchar(10)) + ' registrada';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>>> ROLLBACK. Motivo: ' + ERROR_MESSAGE();
END CATCH;

SELECT id_producto, stock_actual AS stock_despues FROM PRODUCTO WHERE id_producto = @id_producto;
SELECT * FROM VENTA         WHERE numero_ticket = @numero_ticket;
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = @numero_ticket;
GO


/* ------------------------------------------------------------
   PRUEBA 3 - ATOMICIDAD REAL
   Producto 6, cantidad 40, SIN validar el stock. Se insertan VENTA y
   DETALLE_VENTA y recién el UPDATE falla (CHECK stock_actual >= 0).
   Resultado esperado: ROLLBACK que deshace también los dos INSERT:
   stock sigue en 35 y no queda ninguna fila del ticket.
   ------------------------------------------------------------ */
PRINT '';
PRINT '===== PRUEBA 3: ATOMICIDAD REAL (producto 6, cantidad 40, sin validar) =====';

DECLARE @id_producto   INT = 6;
DECLARE @cantidad      INT = 40;
DECLARE @validar_stock BIT = 0;                -- se saltea la validación a propósito
DECLARE @dni_cliente   INT = 29999000;
DECLARE @dni_empleado  INT = 38333444;
DECLARE @tasa_iva      DECIMAL(4,2) = 0.21;

DECLARE @numero_ticket INT;
DECLARE @precio        DECIMAL(10,2);
DECLARE @stock         INT;
DECLARE @subtotal      DECIMAL(10,2);
DECLARE @iva           DECIMAL(10,2);

SELECT id_producto, detalle, stock_actual AS stock_antes FROM PRODUCTO WHERE id_producto = @id_producto;

BEGIN TRY
    BEGIN TRANSACTION;

    IF @cantidad <= 0
        THROW 50002, 'La cantidad debe ser mayor a cero', 1;

    IF NOT EXISTS (SELECT 1 FROM EMPLEADO WHERE dni = @dni_empleado AND rol = 'Cajero')
        THROW 50003, 'La venta debe registrarla un empleado con rol Cajero (RN.07)', 1;

    SELECT @precio = precio_actual, @stock = stock_actual
    FROM PRODUCTO WHERE id_producto = @id_producto;

    IF @precio IS NULL
        THROW 50004, 'El producto no existe', 1;

    IF @validar_stock = 1 AND @stock < @cantidad
        THROW 50001, 'Stock insuficiente', 1;

    SELECT @numero_ticket = ISNULL(MAX(numero_ticket), 0) + 1
    FROM VENTA WITH (UPDLOCK, HOLDLOCK);

    SET @subtotal = @cantidad * @precio;
    SET @iva      = ROUND(@subtotal * @tasa_iva, 2);

    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, 0, @subtotal + @iva, @dni_empleado, @dni_cliente);

    INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
    VALUES (@numero_ticket, @id_producto, @cantidad, @precio);

    UPDATE PRODUCTO SET stock_actual = stock_actual - @cantidad WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;
    PRINT '>>> COMMIT: venta ' + CAST(@numero_ticket AS varchar(10)) + ' registrada';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>>> ROLLBACK. Motivo: ' + ERROR_MESSAGE();
END CATCH;

SELECT id_producto, stock_actual AS stock_despues FROM PRODUCTO WHERE id_producto = @id_producto;
SELECT * FROM VENTA         WHERE numero_ticket = @numero_ticket;   -- vacío: el INSERT se deshizo
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = @numero_ticket;   -- vacío: el INSERT se deshizo
GO


/* ------------------------------------------------------------
   PRUEBA 4 - CASO LÍMITE
   Producto 6, cantidad 35 (justo el stock). Resultado esperado:
   COMMIT, ticket 1012 (el siguiente al 1011, sin huecos), stock en 0.
   ------------------------------------------------------------ */
PRINT '';
PRINT '===== PRUEBA 4: CASO LÍMITE (producto 6, cantidad 35 = todo el stock) =====';

DECLARE @id_producto   INT = 6;
DECLARE @cantidad      INT = 35;
DECLARE @validar_stock BIT = 1;
DECLARE @dni_cliente   INT = 29999000;
DECLARE @dni_empleado  INT = 38333444;
DECLARE @tasa_iva      DECIMAL(4,2) = 0.21;

DECLARE @numero_ticket INT;
DECLARE @precio        DECIMAL(10,2);
DECLARE @stock         INT;
DECLARE @subtotal      DECIMAL(10,2);
DECLARE @iva           DECIMAL(10,2);

SELECT id_producto, detalle, stock_actual AS stock_antes FROM PRODUCTO WHERE id_producto = @id_producto;

BEGIN TRY
    BEGIN TRANSACTION;

    IF @cantidad <= 0
        THROW 50002, 'La cantidad debe ser mayor a cero', 1;

    IF NOT EXISTS (SELECT 1 FROM EMPLEADO WHERE dni = @dni_empleado AND rol = 'Cajero')
        THROW 50003, 'La venta debe registrarla un empleado con rol Cajero (RN.07)', 1;

    SELECT @precio = precio_actual, @stock = stock_actual
    FROM PRODUCTO WHERE id_producto = @id_producto;

    IF @precio IS NULL
        THROW 50004, 'El producto no existe', 1;

    IF @validar_stock = 1 AND @stock < @cantidad
        THROW 50001, 'Stock insuficiente', 1;

    SELECT @numero_ticket = ISNULL(MAX(numero_ticket), 0) + 1
    FROM VENTA WITH (UPDLOCK, HOLDLOCK);

    SET @subtotal = @cantidad * @precio;
    SET @iva      = ROUND(@subtotal * @tasa_iva, 2);

    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, 0, @subtotal + @iva, @dni_empleado, @dni_cliente);

    INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
    VALUES (@numero_ticket, @id_producto, @cantidad, @precio);

    UPDATE PRODUCTO SET stock_actual = stock_actual - @cantidad WHERE id_producto = @id_producto;

    COMMIT TRANSACTION;
    PRINT '>>> COMMIT: venta ' + CAST(@numero_ticket AS varchar(10)) + ' registrada';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>>> ROLLBACK. Motivo: ' + ERROR_MESSAGE();
END CATCH;

SELECT id_producto, stock_actual AS stock_despues FROM PRODUCTO WHERE id_producto = @id_producto;
SELECT * FROM VENTA         WHERE numero_ticket = @numero_ticket;
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = @numero_ticket;
GO


/* ------------------------------------------------------------
   RESUMEN FINAL
   Esperado: dos ventas nuevas (1011 y 1012), sin huecos, y stock
   final de 75 (producto 3) y 0 (producto 6).
   ------------------------------------------------------------ */
PRINT '';
PRINT '===== RESUMEN FINAL =====';
SELECT numero_ticket, fecha_hora, Subtotal, iva, total FROM VENTA WHERE numero_ticket > 1010 ORDER BY numero_ticket;
SELECT numero_ticket, id_producto, Cantidad, precio_unitario_cobrado FROM DETALLE_VENTA WHERE numero_ticket > 1010 ORDER BY numero_ticket;
SELECT id_producto, stock_actual FROM PRODUCTO WHERE id_producto IN (3, 6);
GO


/* =====================================================================
   Etapa V - Tema 2: Transacciones anidadas
   Equipo 46 - Supermercado "El Sol"
   Caso: venta de DOS productos.
     - Transacción EXTERNA = la venta completa.
     - Transacción INTERNA = cada línea de detalle (una por producto).
   Regla de SQL Server que se demuestra:
     - COMMIT interno  -> solo baja @@TRANCOUNT, NO confirma nada definitivo.
     - ROLLBACK        -> deshace TODO (también lo "confirmado" por las internas).
   ===================================================================== */

/* ---------------------------------------------------------------------
   DEMOSTRACIÓN BÁSICA DE TRANSACCIONES ANIDADAS (no modifica datos)
   Muestra cómo cambia @@TRANCOUNT: 0 -> 1 -> 2 -> 1 -> 0
   --------------------------------------------------------------------- */
SELECT @@TRANCOUNT AS trancount_inicial;

BEGIN TRANSACTION;          -- externa
SELECT @@TRANCOUNT AS trancount_externa;

    BEGIN TRANSACTION;      -- interna
    SELECT @@TRANCOUNT AS trancount_interna;

    COMMIT TRANSACTION;     -- confirma la interna
    SELECT @@TRANCOUNT AS trancount_tras_commit_interno;

ROLLBACK TRANSACTION;       -- deshace la externa
SELECT @@TRANCOUNT AS trancount_final;
GO

/* ---------------------------------------------------------------------
   BLOQUE 0: RESETEO
   Deja los datos como al inicio para poder repetir las pruebas.
   Se borra primero DETALLE_VENTA y después VENTA (por la clave foránea).
   --------------------------------------------------------------------- */
DELETE FROM DETALLE_VENTA WHERE numero_ticket > 1010;
DELETE FROM VENTA WHERE numero_ticket > 1010;
UPDATE PRODUCTO SET stock_actual = 80 WHERE id_producto = 3;
UPDATE PRODUCTO SET stock_actual = 35 WHERE id_producto = 6;
GO

/* ---------------------------------------------------------------------
   PRUEBA 5: venta de 2 productos, todo sale bien
   Producto 3: 5 unidades (stock 80 -> 75)
   Producto 6: 10 unidades (stock 35 -> 25)
   Se espera: COMMIT, ticket 1011 con 2 líneas de detalle.
   --------------------------------------------------------------------- */
-- Datos de la venta (cantidades de cada producto)
DECLARE @cant1 INT = 5, @cant2 INT = 10;
-- Variables de trabajo: precios, número de ticket y totales
DECLARE @p1 DECIMAL(10,2), @p2 DECIMAL(10,2), @numero_ticket INT;
DECLARE @subtotal DECIMAL(10,2), @iva DECIMAL(10,2);

BEGIN TRY
    -- TRANSACCIÓN EXTERNA: representa la venta completa. @@TRANCOUNT pasa a 1
    BEGIN TRANSACTION;
    PRINT 'Externa abierta. @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));

    -- Se toma el precio vigente de cada producto (RN.05)
    SELECT @p1 = precio_actual FROM PRODUCTO WHERE id_producto = 3;
    SELECT @p2 = precio_actual FROM PRODUCTO WHERE id_producto = 6;

    -- Número de ticket automático (sin huecos), con bloqueo para evitar repetidos
    SELECT @numero_ticket = ISNULL(MAX(numero_ticket),0) + 1
    FROM VENTA WITH (UPDLOCK, HOLDLOCK);

    -- Subtotal de las dos líneas e IVA del 21 %
    SET @subtotal = @cant1*@p1 + @cant2*@p2;
    SET @iva = ROUND(@subtotal*0.21, 2);

    -- Cabecera de la venta
    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, 0, @subtotal+@iva, 38333444, 29999000);

        -- TRANSACCIÓN INTERNA 1: línea del producto 3. @@TRANCOUNT pasa a 2
        BEGIN TRANSACTION;
        PRINT 'Línea 1 abierta. @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));
        INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
        VALUES (@numero_ticket, 3, @cant1, @p1);
        UPDATE PRODUCTO SET stock_actual = stock_actual - @cant1 WHERE id_producto = 3;
        -- COMMIT interno: solo baja @@TRANCOUNT a 1, no guarda nada todavía
        COMMIT TRANSACTION;
        PRINT 'Línea 1 "confirmada". @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));

        -- TRANSACCIÓN INTERNA 2: línea del producto 6. @@TRANCOUNT pasa a 2
        BEGIN TRANSACTION;
        PRINT 'Línea 2 abierta. @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));
        INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
        VALUES (@numero_ticket, 6, @cant2, @p2);
        UPDATE PRODUCTO SET stock_actual = stock_actual - @cant2 WHERE id_producto = 6;
        -- COMMIT interno: vuelve a bajar @@TRANCOUNT a 1
        COMMIT TRANSACTION;
        PRINT 'Línea 2 "confirmada". @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));

    -- COMMIT de la EXTERNA: recién acá los cambios quedan definitivos (@@TRANCOUNT = 0)
    COMMIT TRANSACTION;
    PRINT '>>> COMMIT: venta ' + CAST(@numero_ticket AS varchar(10)) + ' registrada. @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));
END TRY
BEGIN CATCH
    -- Si algo falla: se informa el contador y se deshace TODO
    PRINT 'Error. @@TRANCOUNT antes del ROLLBACK = ' + CAST(@@TRANCOUNT AS varchar(3));
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>>> ROLLBACK. Motivo: ' + ERROR_MESSAGE() + ' | @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));
END CATCH;

-- Verificación del estado final
SELECT id_producto, stock_actual FROM PRODUCTO WHERE id_producto IN (3, 6);  -- esperado: 3 -> 75, 6 -> 25
SELECT * FROM VENTA WHERE numero_ticket > 1010;                              -- esperado: ticket 1011
SELECT * FROM DETALLE_VENTA WHERE numero_ticket > 1010;                      -- esperado: 2 líneas
GO

/* ---------------------------------------------------------------------
   BLOQUE 0 (de nuevo): reseteo antes de la prueba 6
   --------------------------------------------------------------------- */
DELETE FROM DETALLE_VENTA WHERE numero_ticket > 1010;
DELETE FROM VENTA WHERE numero_ticket > 1010;
UPDATE PRODUCTO SET stock_actual = 80 WHERE id_producto = 3;
UPDATE PRODUCTO SET stock_actual = 35 WHERE id_producto = 6;
GO

/* ---------------------------------------------------------------------
   PRUEBA 6: la segunda línea falla
   Producto 3: 5 unidades (la línea 1 sale bien y hace su COMMIT interno)
   Producto 6: 40 unidades, pero el stock es 35 -> el UPDATE viola
               CK_Producto_StockActualPositivo.
   Se espera: ROLLBACK total. Aunque la línea 1 había hecho COMMIT,
   el stock del producto 3 vuelve a 80 y no queda ticket ni detalle.
   --------------------------------------------------------------------- */
DECLARE @cant1 INT = 5, @cant2 INT = 40;      -- 40 es mayor al stock disponible (35)
DECLARE @p1 DECIMAL(10,2), @p2 DECIMAL(10,2), @numero_ticket INT;
DECLARE @subtotal DECIMAL(10,2), @iva DECIMAL(10,2);

BEGIN TRY
    BEGIN TRANSACTION;                         -- EXTERNA (@@TRANCOUNT = 1)
    PRINT 'Externa abierta. @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));

    SELECT @p1 = precio_actual FROM PRODUCTO WHERE id_producto = 3;
    SELECT @p2 = precio_actual FROM PRODUCTO WHERE id_producto = 6;
    SELECT @numero_ticket = ISNULL(MAX(numero_ticket),0) + 1
    FROM VENTA WITH (UPDLOCK, HOLDLOCK);
    SET @subtotal = @cant1*@p1 + @cant2*@p2;
    SET @iva = ROUND(@subtotal*0.21, 2);

    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, 0, @subtotal+@iva, 38333444, 29999000);

        -- INTERNA 1: sale bien
        BEGIN TRANSACTION;                     -- @@TRANCOUNT = 2
        INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
        VALUES (@numero_ticket, 3, @cant1, @p1);
        UPDATE PRODUCTO SET stock_actual = stock_actual - @cant1 WHERE id_producto = 3;
        COMMIT TRANSACTION;                    -- baja a 1, pero NO es definitivo
        PRINT 'Línea 1 "confirmada". @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));

        -- INTERNA 2: falla
        BEGIN TRANSACTION;                     -- @@TRANCOUNT = 2
        PRINT 'Línea 2 abierta. @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));
        INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
        VALUES (@numero_ticket, 6, @cant2, @p2);
        -- Este UPDATE deja el stock en -5 y viola el CHECK: salta al CATCH
        UPDATE PRODUCTO SET stock_actual = stock_actual - @cant2 WHERE id_producto = 6;
        COMMIT TRANSACTION;                    -- no se llega a ejecutar

    COMMIT TRANSACTION;                        -- no se llega a ejecutar
    PRINT '>>> COMMIT: venta ' + CAST(@numero_ticket AS varchar(10)) + ' registrada';
END TRY
BEGIN CATCH
    -- Acá @@TRANCOUNT sigue en 2: las dos transacciones están abiertas
    PRINT 'Error. @@TRANCOUNT antes del ROLLBACK = ' + CAST(@@TRANCOUNT AS varchar(3));
    -- El ROLLBACK deshace TODO, incluida la línea 1 y la cabecera de la venta
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>>> ROLLBACK. Motivo: ' + ERROR_MESSAGE() + ' | @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS varchar(3));
END CATCH;

-- Verificación del estado final
SELECT id_producto, stock_actual FROM PRODUCTO WHERE id_producto IN (3, 6);  -- esperado: 3 -> 80, 6 -> 35
SELECT * FROM VENTA WHERE numero_ticket > 1010;                              -- esperado: vacío
SELECT * FROM DETALLE_VENTA WHERE numero_ticket > 1010;                      -- esperado: vacío
GO