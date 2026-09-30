USE SupermercadoElSol;
GO

IF OBJECT_ID('SUMINISTRA', 'U') IS NOT NULL DROP TABLE SUMINISTRA;
IF OBJECT_ID('PROVEEDOR', 'U') IS NOT NULL DROP TABLE PROVEEDOR;
GO

CREATE TABLE PROVEEDOR (
    cuit            VARCHAR(11)     NOT NULL,
    razon_social    VARCHAR(100)    NOT NULL,
    telefono        VARCHAR(20)     NOT NULL,
    calle           VARCHAR(100)    NOT NULL,
    numero          VARCHAR(10)     NOT NULL,
    ciudad          VARCHAR(50)     NOT NULL,
    codigo_postal   VARCHAR(10)     NOT NULL,
    provincia       VARCHAR(50)     NOT NULL,

    CONSTRAINT PK_Proveedor PRIMARY KEY (cuit),
    CONSTRAINT UQ_Proveedor_RazonSocial UNIQUE (razon_social),
    CONSTRAINT CK_Proveedor_CUIT CHECK (LEN(cuit) = 11 AND cuit NOT LIKE '%[^0-9]%')
);
GO

CREATE TABLE SUMINISTRA (
    cuit            VARCHAR(11)     NOT NULL,
    id_producto     INT             NOT NULL,

    CONSTRAINT PK_Suministra PRIMARY KEY (cuit, id_producto),
    CONSTRAINT FK_Suministra_Proveedor FOREIGN KEY (cuit)
        REFERENCES PROVEEDOR(cuit)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Suministra_Producto FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO(id_producto)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO
