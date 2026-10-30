

/*======================================
Equipo N° 46
Supermercado "El Sol"
Transacciones SQL - Manejo de Errores
Alumno: Jorge Alejandro Maciel
=======================================*/

/* Con la siguiente consulta se realizan dos pruebas:
1. Se simula la venta de un producto (3 unidades), El sistema confirma la venta y descuenta el stock.  
2. Se simula un error: utilizaremos el DNI de un empleado inexistente. 
De esta forma el bloque CATCH debería capturar el error:*/

USE SupermercadoElSol;
GO

-- Estado inicial del stock del producto 1
SELECT id_producto, marca, detalle, stock_actual 
FROM PRODUCTO 
WHERE id_producto = 1;

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Insertar Cabecera de Venta (Ticket 3015)
    INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
    VALUES (3015, GETDATE(), 3601.50, 756.32, 0.00, 4357.82, 91888999, 29999000); -- DNI de cliente válido corregido

    -- 2. Insertar Detalle de Venta
    INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
    VALUES (3015, 1, 3, 1200.50);

    -- 3. Actualizar Stock del Producto 1
    UPDATE PRODUCTO
    SET stock_actual = stock_actual - 3
    WHERE id_producto = 1;

    -- Confirmación de la transacción
    COMMIT TRANSACTION;
    PRINT '--- TRANSACCIÓN EXITOSA: Venta 2017 registrada correctamente. ---';
END TRY
BEGIN CATCH
    -- Si hay una transacción activa, se deshace
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    PRINT '--- ERROR: Ocurrió un fallo en la transacción. ---';
    
    -- Mostrar el detalle estructurado del error en formato de grilla
    SELECT 
        ERROR_NUMBER() AS NumeroError,
        ERROR_MESSAGE() AS Mensaje,
        ERROR_LINE() AS Linea;
        
END CATCH;
GO

-- Verificación de cambios aplicados
SELECT * FROM VENTA WHERE numero_ticket = 3015;
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = 3015;
SELECT id_producto, marca, detalle, stock_actual FROM PRODUCTO WHERE id_producto = 1;
GO

/*En este caso, vamos a utilizar RAISERROR para capturar el error.
Vamos a realizar dos consultas:
1. Una operación donde se fuerza el error comprando 100 unidades (superior al stock existente)
2. Haciendo una compra normal (dentro del stock existente)*/

/* Vamos a utilizar el siguiente código:*/

BEGIN TRANSACTION;

BEGIN TRY
    -- Declaramos una variable simulando la cantidad que se quiere llevar
    DECLARE @CantidadAComprar INT = 10; -- Una cantidad exagerada para forzar el error
    DECLARE @StockActual INT;

    -- Consultamos el stock actual del producto con ID 1
    SELECT @StockActual = stock_actual 
    FROM PRODUCTO 
    WHERE id_producto = 1;

    -- REGLA DE NEGOCIO: Validar stock insuficiente
    IF @StockActual < @CantidadAComprar
    BEGIN
        -- Lanzamos un error personalizado (Severidad 16 para que active el CATCH)
        RAISERROR('Stock insuficiente. Stock disponible: %d, cantidad solicitada: %d', 16, 1, @StockActual, @CantidadAComprar);
    END

    -- Si hubiera stock, aquí continuarían los INSERT de la venta...
    -- INSERT INTO VENTA ...

    COMMIT TRANSACTION;
    PRINT '--- TRANSACCIÓN EXITOSA ---';

END TRY
BEGIN CATCH
    -- Si ocurrió el RAISERROR u otro error, se revierte todo
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '--- ERROR CAPTURADO ---';
    
    -- Mostramos los datos del error estructurados
    SELECT 
        ERROR_NUMBER() AS NumeroError,
        ERROR_MESSAGE() AS Mensaje,
        ERROR_LINE() AS Linea;
END CATCH;
GO

/* Por último vamos a utilizat THROW para capturar el error
El código que vamos a utilizar es el siguiente:*/

BEGIN TRANSACTION;

BEGIN TRY
    -- Variables para simular una compra de 50 unidades del producto ID 1
    DECLARE @IdProducto INT = 1;
    DECLARE @CantidadComprada INT = 50;
    DECLARE @StockActual INT;

    -- 1. Consultar el stock actual del producto
    SELECT @StockActual = stock_actual 
    FROM PRODUCTO 
    WHERE id_producto = @IdProducto;

    -- 2. REGLA DE NEGOCIO: Validar si el stock es insuficiente
    IF @StockActual < @CantidadComprada
    BEGIN
        -- Lanzamos un error personalizado con THROW (Número entre 50000 y 2147483647)
        THROW 50001, 'El stock disponible es insuficiente para completar la venta.', 1;
    END

    -- 3. Si hubiera stock suficiente, continuarían los INSERT y UPDATE normales...
    -- INSERT INTO VENTA ...
    -- INSERT INTO DETALLE_VENTA ...
    -- UPDATE PRODUCTO SET stock_actual = stock_actual - @CantidadComprada WHERE id_producto = @IdProducto;

    -- Si todo sale bien, confirmamos
    COMMIT TRANSACTION;
    PRINT '--- TRANSACCIÓN EXITOSA ---';

END TRY
BEGIN CATCH
    -- Si el THROW o cualquier otro error interrumpe el TRY, se revierte la transacción
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '--- TRANSACCIÓN REVERTIDA (ROLLBACK) ---';

    -- Mostrar los detalles del error capturado
    SELECT 
        ERROR_NUMBER() AS NumeroError,
        ERROR_MESSAGE() AS Mensaje,
        ERROR_LINE() AS Linea;

END CATCH;
GO







