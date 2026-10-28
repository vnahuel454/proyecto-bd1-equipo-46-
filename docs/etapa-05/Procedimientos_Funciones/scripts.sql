use SupermercadoElSol;
go

 IF OBJECT_ID('dbo.fn_CalcularDescuentoCliente', 'FN') IS NOT NULL 
 DROP FUNCTION dbo.fn_CalcularDescuentoCliente; 
  GO 
  
CREATE FUNCTION dbo.fn_CalcularDescuentoCliente
   (@id_cliente INT) 
   RETURNS DECIMAL(4,2) 
   AS
    BEGIN
     DECLARE @total_acumulado DECIMAL(12,2); 
     DECLARE @descuento DECIMAL(4,2);
     
-- 1. Sumar todas las compras históricas del cliente (retorna 0 si no tiene compras) 
SELECT @total_acumulado = ISNULL(SUM(total), 0)
FROM venta 
WHERE dni_Cliente = @id_cliente; 
    
-- 2. Evaluar la escala de beneficios según el monto acumulado 
IF @total_acumulado > 500000.00 
	SET @descuento = 0.10; -- 10%
ELSE IF @total_acumulado > 200000.00 
	SET @descuento = 0.05; -- 5%
ELSE 
	SET @descuento = 0.00; -- 0% 

RETURN @descuento; END; 
GO

-- Demostración: Consultar clientes y calcular su descuento en tiempo real 

-- 1. Insertar una compra de $250.000 para Carlos Gómez (DNI 35111222); Supera los $200.000 (Descuento del 5%) 
INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente) 
VALUES (901, '2026-02-15T10:00:00', 206611.57, 43388.43, 0.00, 250000.00, 38333444, 35111222);

-- 2. Insertar una compra de $550.000 para Juan Pérez (DNI 29999000); Supera los $500.000 (Descuento del 10%) 
INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente) 
VALUES (902, '2026-02-20T11:30:00', 454545.45, 95454.55, 0.00, 550000.00, 38333444, 29999000); 
GO

SELECT 
	c.dni AS DNI_Cliente, 
	p.nombre,
	p.apellido, 
	dbo.fn_CalcularDescuentoCliente(c.dni) AS DescuentoDecimal,
	CAST(dbo.fn_CalcularDescuentoCliente(c.dni) * 100 AS INT) AS [Porcentaje Descuento %] 
  FROM cliente c
  INNER JOIN PERSONA p ON c.dni = p.dni;
  GO
 
--Procedimiento Almacenado: dbo.sp_RegistrarVentaCompleta 
use SupermercadoElSol;
 GO 

 IF OBJECT_ID('dbo.sp_RegistrarVentaCompleta', 'P') IS NOT NULL 
 DROP PROCEDURE dbo.sp_RegistrarVentaCompleta; 
 GO 
 
 CREATE PROCEDURE dbo.sp_RegistrarVentaCompleta 
 @numero_ticket INT,
 @dni_Cliente INT, 
 @dni_Empleado INT, 
 @id_producto INT,
 @cantidad INT
 AS 
 BEGIN 
 SET NOCOUNT ON; 
 DECLARE @precio_actual DECIMAL(10,2);
  DECLARE @porc_descuento DECIMAL(4,2); 
  DECLARE @subtotal DECIMAL(10,2); 
  DECLARE @monto_descuento DECIMAL(10,2); 
  DECLARE @iva DECIMAL(10,2); 
  DECLARE @total_final DECIMAL(10,2); 
  
-- 1. Obtener precio actual y calcular descuento del cliente 
SELECT @precio_actual = precio_actual 
FROM PRODUCTO 
WHERE id_producto = @id_producto; 
SET @porc_descuento = dbo.fn_CalcularDescuentoCliente(@dni_Cliente);
  
-- 2. Calcular montos conforme al esquema de la tabla VENTA 
SET @subtotal = @precio_actual * @cantidad; 
SET @monto_descuento = @subtotal * @porc_descuento; 
SET @iva = (@subtotal - @monto_descuento) * 0.21; -- Cálculo de IVA 21% 
SET @total_final = (@subtotal - @monto_descuento) + @iva; 
   
-- 3. Registrar en la tabla VENTA 
INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente) 
VALUES (@numero_ticket, GETDATE(), @subtotal, @iva, @monto_descuento, @total_final, @dni_Empleado, @dni_Cliente);
   
-- 4. Registrar en DETALLE_VENTA 
INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado, fecha_registro, usuario_registro) 
VALUES (@numero_ticket, @id_producto, @cantidad, @precio_actual, GETDATE(), SYSTEM_USER);
    
-- 5. Actualizar stock en PRODUCTO 
UPDATE PRODUCTO 
SET stock_actual = stock_actual - @cantidad 
WHERE id_producto = @id_producto; 
PRINT 'Venta N° ' + CAST(@numero_ticket AS VARCHAR) + ' registrada con éxito en SupermercadoElSol.';
END; 
GO
   
--Script de Demostración
use SupermercadoElSol;
GO 
   
-- 1. Estado inicial del producto 
SELECT id_producto, marca, detalle, precio_actual, stock_actual 
FROM PRODUCTO 
WHERE id_producto = 1; 
  
-- 2. Ejecución del procedimiento de venta
EXEC dbo.sp_RegistrarVentaCompleta
    @numero_ticket = 1012, 
    @dni_Cliente = 29999000, 
    @dni_Empleado = 38333444,
    @id_producto = 1,
    @cantidad = 2; 
    
-- 3. Verificar actualización de stock 
SELECT id_producto, marca, detalle, precio_actual, stock_actual 
FROM PRODUCTO 
WHERE id_producto = 1; 
    
-- 4. Verificar inserción en VENTA y DETALLE_VENTA 
SELECT * FROM VENTA WHERE numero_ticket = 1012; 
SELECT * FROM DETALLE_VENTA WHERE numero_ticket = 1012; 
GO
    
    