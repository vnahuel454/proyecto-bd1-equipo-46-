USE SupermercadoElSol;
GO

IF OBJECT_ID('AUDITORIA_PRODUCTO', 'U') IS NOT NULL DROP TABLE AUDITORIA_PRODUCTO;  
GO

CREATE TABLE AUDITORIA_PRODUCTO (    --tabla auxiliar
    id_auditoria     INT IDENTITY(1,1) PRIMARY KEY,
    id_producto      INT NOT NULL,
    codigo_barra     VARCHAR(20),
    marca            VARCHAR(50),
    detalle          VARCHAR(200),
    precio_anterior  DECIMAL(10,2),
    precio_nuevo     DECIMAL(10,2),
    tipo_operacion   VARCHAR(10) NOT NULL,
    fecha_hora       DATETIME DEFAULT GETDATE() NOT NULL,
    usuario_db       VARCHAR(100) DEFAULT SYSTEM_USER NOT NULL
);
GO


IF OBJECT_ID('tr_AuditarProducto_Update', 'TR') IS NOT NULL DROP TRIGGER tr_AuditarProducto_Update;
GO

CREATE TRIGGER tr_AuditarProducto_Update                      --creamos el trigger de auditoria de precios
ON PRODUCTO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AUDITORIA_PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_anterior, precio_nuevo, tipo_operacion)
    SELECT 
        d.id_producto,
        d.codigo_barra,
        d.marca,
        d.detalle,
        d.precio_actual,  -- Valor viejo (tabla deleted)
        i.precio_actual,  -- Valor nuevo (tabla inserted)
        'UPDATE'
    FROM deleted d
    INNER JOIN inserted i ON d.id_producto = i.id_producto;
END;
GO


-- Prueba: Modificar el precio del Producto ID 1
UPDATE PRODUCTO 
SET precio_actual = 1450.00 
WHERE id_producto = 1;

-- Verificar que se haya registrado en la tabla de auditoría automáticamente
SELECT * FROM AUDITORIA_PRODUCTO;
GO