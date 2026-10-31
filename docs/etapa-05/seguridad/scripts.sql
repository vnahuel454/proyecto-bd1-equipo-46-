USE SupermercadoElSol;
GO

-- Limpieza previa
WHILE USER_NAME() <> 'dbo'
BEGIN
    REVERT;
END
GO

IF USER_ID('usr_cajero') IS NOT NULL DROP USER usr_cajero;
IF USER_ID('usr_deposito') IS NOT NULL DROP USER usr_deposito;
IF USER_ID('usr_auditor') IS NOT NULL DROP USER usr_auditor;
GO

IF DATABASE_PRINCIPAL_ID('rol_cajero') IS NOT NULL DROP ROLE rol_cajero;
IF DATABASE_PRINCIPAL_ID('rol_deposito') IS NOT NULL DROP ROLE rol_deposito;
IF DATABASE_PRINCIPAL_ID('rol_auditor') IS NOT NULL DROP ROLE rol_auditor;
GO

USE master;
GO

IF SUSER_ID('login_cajero_pos') IS NOT NULL DROP LOGIN login_cajero_pos;
IF SUSER_ID('login_encargado_deposito') IS NOT NULL DROP LOGIN login_encargado_deposito;
IF SUSER_ID('login_auditor_fiscal') IS NOT NULL DROP LOGIN login_auditor_fiscal;
GO

USE SupermercadoElSol;
GO

-- Logins
CREATE LOGIN login_cajero_pos WITH PASSWORD = 'CajeroPassword#2026', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
CREATE LOGIN login_encargado_deposito WITH PASSWORD = 'DepositoPassword#2026', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
CREATE LOGIN login_auditor_fiscal WITH PASSWORD = 'AuditorPassword#2026', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

-- Usuarios
CREATE USER usr_cajero FOR LOGIN login_cajero_pos;
CREATE USER usr_deposito FOR LOGIN login_encargado_deposito;
CREATE USER usr_auditor FOR LOGIN login_auditor_fiscal;
GO

-- Roles
CREATE ROLE rol_cajero;
CREATE ROLE rol_deposito;
CREATE ROLE rol_auditor;
GO

ALTER ROLE rol_cajero ADD MEMBER usr_cajero;
ALTER ROLE rol_deposito ADD MEMBER usr_deposito;
ALTER ROLE rol_auditor ADD MEMBER usr_auditor;
GO

-- Permisos rol_cajero
GRANT SELECT ON dbo.PRODUCTO TO rol_cajero;
GRANT SELECT ON dbo.CATEGORIA TO rol_cajero;
GRANT SELECT ON dbo.MEDIO_DE_PAGO TO rol_cajero;
GRANT SELECT ON dbo.CLIENTE TO rol_cajero;
GRANT SELECT ON dbo.PERSONA TO rol_cajero;
GRANT SELECT ON dbo.EMPLEADO TO rol_cajero;

GRANT INSERT, SELECT ON dbo.VENTA TO rol_cajero;
GRANT INSERT, SELECT ON dbo.DETALLE_VENTA TO rol_cajero;
GRANT INSERT, SELECT ON dbo.SE_ABONA_CON TO rol_cajero;
GRANT INSERT ON dbo.CLIENTE TO rol_cajero;
GRANT INSERT ON dbo.PERSONA TO rol_cajero;

DENY UPDATE, DELETE ON dbo.VENTA TO rol_cajero;
DENY UPDATE, DELETE ON dbo.DETALLE_VENTA TO rol_cajero;
DENY UPDATE, DELETE ON dbo.SE_ABONA_CON TO rol_cajero;
DENY UPDATE, DELETE ON dbo.PRODUCTO TO rol_cajero;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.PROVEEDOR TO rol_cajero;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.SUMINISTRA TO rol_cajero;
GO

-- Permisos rol_deposito
GRANT SELECT ON dbo.PRODUCTO TO rol_deposito;
GRANT UPDATE (stock_actual, stock_minimo) ON dbo.PRODUCTO TO rol_deposito;
GRANT SELECT ON dbo.CATEGORIA TO rol_deposito;
GRANT SELECT, INSERT, UPDATE ON dbo.PROVEEDOR TO rol_deposito;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.SUMINISTRA TO rol_deposito;

DENY UPDATE (precio_actual) ON dbo.PRODUCTO TO rol_deposito;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VENTA TO rol_deposito;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.DETALLE_VENTA TO rol_deposito;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.SE_ABONA_CON TO rol_deposito;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.MEDIO_DE_PAGO TO rol_deposito;
GO

-- Permisos rol_auditor
GRANT SELECT ON dbo.VENTA TO rol_auditor;
GRANT SELECT ON dbo.DETALLE_VENTA TO rol_auditor;
GRANT SELECT ON dbo.SE_ABONA_CON TO rol_auditor;
GRANT SELECT ON dbo.PRODUCTO TO rol_auditor;
GRANT SELECT ON dbo.CATEGORIA TO rol_auditor;
GRANT SELECT ON dbo.MEDIO_DE_PAGO TO rol_auditor;
GRANT SELECT ON dbo.PROVEEDOR TO rol_auditor;
GRANT SELECT ON dbo.SUMINISTRA TO rol_auditor;
GRANT SELECT ON dbo.CLIENTE TO rol_auditor;
GRANT SELECT ON dbo.EMPLEADO TO rol_auditor;
GRANT SELECT ON dbo.PERSONA TO rol_auditor;

DENY INSERT, UPDATE, DELETE ON dbo.VENTA TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON dbo.DETALLE_VENTA TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON dbo.SE_ABONA_CON TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON dbo.PRODUCTO TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON dbo.PROVEEDOR TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON dbo.SUMINISTRA TO rol_auditor;
GO

-- Pruebas

-- Caso 1: Consulta y facturacion (cajero)
EXECUTE AS USER = 'usr_cajero';

SELECT id_producto, codigo_barra, detalle, precio_actual 
FROM dbo.PRODUCTO 
WHERE id_producto IN (1, 2);

INSERT INTO dbo.VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
VALUES (9901, GETDATE(), 2400.00, 504.00, 0.00, 2904.00, 38333444, 29999000);

INSERT INTO dbo.DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)
VALUES (9901, 1, 2, 1200.00);

INSERT INTO dbo.SE_ABONA_CON (numero_ticket, id_medio_de_pago, monto_imputado)
VALUES (9901, 1, 2904.00);

SELECT v.numero_ticket, v.total, dv.id_producto, dv.Cantidad, dv.precio_unitario_cobrado
FROM dbo.VENTA v
INNER JOIN dbo.DETALLE_VENTA dv ON v.numero_ticket = dv.numero_ticket
WHERE v.numero_ticket = 9901;

REVERT;
GO

-- Caso 2: Intento de modificar precio (bloqueado)
EXECUTE AS USER = 'usr_cajero';

UPDATE dbo.PRODUCTO
SET precio_actual = 50.00
WHERE id_producto = 1;

REVERT;
GO

-- Caso 3: Intento de borrar ticket (bloqueado)
EXECUTE AS USER = 'usr_cajero';

DELETE FROM dbo.VENTA 
WHERE numero_ticket = 1001;

REVERT;
GO

-- Caso 4: Actualizacion de stock (deposito)
EXECUTE AS USER = 'usr_deposito';

UPDATE dbo.PRODUCTO
SET stock_actual = stock_actual + 50
WHERE id_producto = 2;

SELECT id_producto, detalle, stock_actual, stock_minimo 
FROM dbo.PRODUCTO 
WHERE id_producto = 2;

REVERT;
GO

-- Caso 5: Intento de ver ventas (bloqueado)
EXECUTE AS USER = 'usr_deposito';

SELECT numero_ticket, total, fecha_hora 
FROM dbo.VENTA;

REVERT;
GO

-- Caso 6: Consulta de ventas (auditor)
EXECUTE AS USER = 'usr_auditor';

SELECT v.numero_ticket, v.fecha_hora, v.total, p.detalle, dv.Cantidad, dv.precio_unitario_cobrado
FROM dbo.VENTA v
INNER JOIN dbo.DETALLE_VENTA dv ON v.numero_ticket = dv.numero_ticket
INNER JOIN dbo.PRODUCTO p ON dv.id_producto = p.id_producto
WHERE v.numero_ticket = 1001;

REVERT;
GO

-- Caso 7: Intento de modificar venta (bloqueado)
EXECUTE AS USER = 'usr_auditor';

UPDATE dbo.VENTA
SET total = 0.00
WHERE numero_ticket = 1001;

REVERT;
GO

-- Limpieza
DELETE FROM dbo.SE_ABONA_CON WHERE numero_ticket = 9901;
DELETE FROM dbo.DETALLE_VENTA WHERE numero_ticket = 9901;
DELETE FROM dbo.VENTA WHERE numero_ticket = 9901;
GO
