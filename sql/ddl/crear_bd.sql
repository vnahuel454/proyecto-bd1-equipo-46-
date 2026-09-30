-- =========================================
-- Bloque: Proveedor y Suministra
-- Alfredo López - Equipo 46
-- =========================================
USE SupermercadoElSol;
GO

-- Borrado condicional en orden inverso para evitar conflictos de claves foráneas
IF OBJECT_ID('SUMINISTRA', 'U') IS NOT NULL DROP TABLE SUMINISTRA;
IF OBJECT_ID('PROVEEDOR', 'U') IS NOT NULL DROP TABLE PROVEEDOR;
GO

-- =============================================================================
-- TABLA: PROVEEDOR
-- Almacena los proveedores externos que abastecen al supermercado (RN.04).
-- Identificador natural único: CUIT.
-- =============================================================================
CREATE TABLE PROVEEDOR (
    cuit            VARCHAR(11)     NOT NULL,
    razon_social    VARCHAR(100)    NOT NULL,
    telefono        VARCHAR(20)     NOT NULL,
    calle           VARCHAR(100)    NOT NULL,
    numero          VARCHAR(10)     NOT NULL,
    ciudad          VARCHAR(50)     NOT NULL,
    codigo_postal   VARCHAR(10)     NOT NULL,
    provincia       VARCHAR(50)     NOT NULL,

    -- Clave Primaria
    CONSTRAINT PK_Proveedor PRIMARY KEY (cuit),

    -- Razón Social única para evitar duplicar empresas
    CONSTRAINT UQ_Proveedor_RazonSocial UNIQUE (razon_social),

    -- Validación de formato CUIT (exactamente 11 dígitos numéricos)
    CONSTRAINT CK_Proveedor_CUIT CHECK (LEN(cuit) = 11 AND cuit NOT LIKE '%[^0-9]%')
);
GO

-- =============================================================================
-- TABLA: SUMINISTRA (Relación Muchos a Muchos entre Proveedor y Producto)
-- Modela qué proveedor suministra qué productos del catálogo (RN.04).
-- =============================================================================
CREATE TABLE SUMINISTRA (
    cuit            VARCHAR(11)     NOT NULL,
    id_producto     INT             NOT NULL,

    -- Clave Primaria Compuesta
    CONSTRAINT PK_Suministra PRIMARY KEY (cuit, id_producto),

    -- Clave Foránea hacia PROVEEDOR
    CONSTRAINT FK_Suministra_Proveedor FOREIGN KEY (cuit)
        REFERENCES PROVEEDOR(cuit)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    -- Clave Foránea hacia PRODUCTO
    CONSTRAINT FK_Suministra_Producto FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO
