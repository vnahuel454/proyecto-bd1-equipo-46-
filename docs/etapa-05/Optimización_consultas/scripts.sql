
USE SupermercadoElSol_test;
GO

-- ============================================================================
-- PASO 1: POBLADO MASIVO DE DATOS EN LA TABLA VENTA (100.000 Registros)
-- ============================================================================
-- Para evaluar el comportamiento real de los índices, se insertan 100.000
-- ventas respetando la integridad referencial (FK) con CLIENTE y EMPLEADO.

SET NOCOUNT ON;
GO

-- Limpieza de pruebas anteriores (tickets > 2000)
DELETE FROM SE_ABONA_CON WHERE numero_ticket > 2000;
DELETE FROM DETALLE_VENTA WHERE numero_ticket > 2000;
DELETE FROM VENTA WHERE numero_ticket > 2000;
GO

-- Carga en tablas temporales de DNIs válidos para asignación aleatoria
DECLARE @Clientes TABLE (id INT IDENTITY(1,1), dni INT);
INSERT INTO @Clientes (dni) SELECT dni FROM CLIENTE;

DECLARE @Empleados TABLE (id INT IDENTITY(1,1), dni INT);
INSERT INTO @Empleados (dni) SELECT dni FROM EMPLEADO;

DECLARE @CantClientes INT = (SELECT COUNT(*) FROM @Clientes);
DECLARE @CantEmpleados INT = (SELECT COUNT(*) FROM @Empleados);

-- Generación e inserción masiva
WITH Numeros AS
(
    SELECT TOP (100000)
           ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
    CROSS JOIN sys.objects c
)
INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)
SELECT 
    2000 + n.n AS numero_ticket,
    DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % (5 * 365 * 24 * 60), '2021-01-01') AS fecha_hora,
    ROUND(1000 + (ABS(CHECKSUM(NEWID())) % 40000), 2) AS Subtotal,
    ROUND((1000 + (ABS(CHECKSUM(NEWID())) % 40000)) * 0.21, 2) AS iva,
    0.00 AS descuento,
    ROUND((1000 + (ABS(CHECKSUM(NEWID())) % 40000)) * 1.21, 2) AS total,
    emp.dni AS dni_Empleado,
    cli.dni AS dni_Cliente
FROM Numeros n
CROSS APPLY (
    SELECT dni FROM @Empleados WHERE id = (n.n % @CantEmpleados) + 1
) emp
CROSS APPLY (
    SELECT dni FROM @Clientes WHERE id = (n.n % @CantClientes) + 1
) cli;
GO

-- Verificar volumen total de ventas
SELECT COUNT(*) AS Total_Ventas_Registradas FROM VENTA;
GO


-- ============================================================================
-- PASO 2: LIMPIEZA DE ÍNDICES SECUNDARIOS PREVIOS
-- ============================================================================
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VENTA_FechaHora' AND object_id = OBJECT_ID('VENTA'))
    DROP INDEX IX_VENTA_FechaHora ON VENTA;
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VENTA_FechaHora_Cobertura' AND object_id = OBJECT_ID('VENTA'))
    DROP INDEX IX_VENTA_FechaHora_Cobertura ON VENTA;
GO


-- ============================================================================
-- PASO 3: ESCENARIO 1 - CONSULTA SIN ÍNDICE SECUNDARIO (Clustered Index Scan)
-- ============================================================================
-- La tabla VENTA posee una PK en 'numero_ticket' (Índice Agrupado).
-- Al filtrar por 'fecha_hora' sin un índice secundario, el motor debe
-- escanear el 100% de la tabla fila por fila.

CHECKPOINT; -- Limpia páginas sucias en búfer
DBCC DROPCLEANBUFFERS; -- Limpia la memoria caché para medir I/O real
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

PRINT '=== ESCENARIO 1: Consulta por rango de fechas sin índice secundario ==='; 
SELECT numero_ticket, fecha_hora, total, dni_Cliente 
FROM VENTA 
WHERE fecha_hora BETWEEN '20230101' AND '20230331 23:59:59'; 
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- ============================================================================
-- PASO 4: ESCENARIO 2 - ÍNDICE NO AGRUPADO SIMPLE (Nonclustered Index Seek)
-- ============================================================================
-- Se crea un índice no agrupado sobre la columna de filtro 'fecha_hora'.
-- El motor realiza un Index Seek, pero requiere 'Key Lookup' para obtener
-- las columnas 'total' y 'dni_Cliente' desde el índice agrupado base.

CREATE NONCLUSTERED INDEX IX_VENTA_FechaHora 
ON VENTA(fecha_hora);
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

PRINT '=== ESCENARIO 2: Consulta utilizando Índice No Agrupado Simple ==='; 
SELECT numero_ticket, fecha_hora, total, dni_Cliente 
FROM VENTA 
WHERE fecha_hora BETWEEN '20230101' AND '20230331 23:59:59';
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- ============================================================================
-- PASO 5: ESCENARIO 3 - ÍNDICE DE COBERTURA (Covering Index)
-- ============================================================================
-- Se crea un índice no agrupado que incluye en su nivel hoja las columnas
-- de proyección ('total', 'dni_Cliente') mediante la cláusula INCLUDE.
-- La consulta se resuelve 100% en el índice sin tocar la tabla base.

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VENTA_FechaHora' AND object_id = OBJECT_ID('VENTA'))
    DROP INDEX IX_VENTA_FechaHora ON VENTA;
GO

CREATE NONCLUSTERED INDEX IX_VENTA_FechaHora_Cobertura 
ON VENTA(fecha_hora) 
INCLUDE (total, dni_Cliente);
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

PRINT '=== ESCENARIO 3: Consulta utilizando Índice de Cobertura ==='; 
SELECT numero_ticket, fecha_hora, total, dni_Cliente 
FROM VENTA 
WHERE fecha_hora BETWEEN '20230101' AND '20230331 23:59:59'; 
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
