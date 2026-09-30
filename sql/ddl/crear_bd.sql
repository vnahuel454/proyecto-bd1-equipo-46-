USE SupermercadoElSol; 
GO

IF OBJECT_ID('CLIENTE', 'U') IS NOT NULL DROP TABLE CLIENTE; 
IF OBJECT_ID('EMPLEADO', 'U') IS NOT NULL DROP TABLE EMPLEADO; 
IF OBJECT_ID('PERSONA', 'U') IS NOT NULL DROP TABLE PERSONA;
GO

CREATE TABLE PERSONA ( 
	dni INT NOT NULL, 
	cuil VARCHAR(15) NOT NULL, 
	nombre VARCHAR(50) NOT NULL, 
	apellido VARCHAR(50) NOT NULL, 
	calle VARCHAR(100) NOT NULL, 
	numero INT NOT NULL, 
	ciudad VARCHAR(50) NOT NULL, 
	provincia VARCHAR(50) NOT NULL, 
	codigo_postal VARCHAR(10) NOT NULL, 
	telefono VARCHAR(20) NULL, 
	correo_electronico VARCHAR(100) NOT NULL, 
	fecha_nacimiento DATE NOT NULL, 

	CONSTRAINT pk_persona PRIMARY KEY (dni), 
	CONSTRAINT uq_persona_cuil UNIQUE (cuil), 
	CONSTRAINT uq_persona_email UNIQUE (correo_electronico), 
	CONSTRAINT ck_persona_dni_positivo CHECK (dni >= 0)
 );
 GO
 
 CREATE TABLE EMPLEADO ( 
	 dni INT NOT NULL, 
	 numero_legajo INT NOT NULL, 
	 rol VARCHAR(50) NOT NULL, 
	 
	 CONSTRAINT pk_empleado PRIMARY KEY (dni), 
	 CONSTRAINT uq_empleado_legajo UNIQUE (numero_legajo), 
	 CONSTRAINT fk_empleado_persona FOREIGN KEY (dni) 
		 REFERENCES Persona(dni) 
		 ON DELETE CASCADE 
		 ON UPDATE CASCADE, 
	 CONSTRAINT ck_empleado_rol CHECK (rol IN ('Cajero', 'Repositor', 'Gerente', 'Encargado de Depósito', 'Administrativo')) 
 );
 GO

CREATE TABLE CLIENTE (
    dni INT NOT NULL,
    
    CONSTRAINT pk_cliente PRIMARY KEY (dni),
    CONSTRAINT fk_cliente_persona FOREIGN KEY (dni) 
        REFERENCES Persona(dni) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO










































































	

CREATE TABLE DETALLE_VENTA (
    numero_ticket INT NOT NULL,
    id_producto INT NOT NULL,
    Cantidad INT NOT NULL,
    precio_unitario_cobrado DECIMAL(10,2) NOT NULL,
    
    fecha_creacion DATETIME DEFAULT GETDATE() NOT NULL,
    usuario_creacion VARCHAR(100) DEFAULT SYSTEM_USER NOT NULL,
    
    CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY (numero_ticket, id_producto),
    CONSTRAINT CK_DETALLE_VENTA_Cantidad CHECK (Cantidad >= 0)
);

CREATE TABLE SE_ABONA_CON (
    numero_ticket INT NOT NULL,
    id_medio_de_pago INT NOT NULL,
    monto_imputado DECIMAL(10,2) NOT NULL,
    
    fecha_creacion DATETIME DEFAULT GETDATE() NOT NULL,
    usuario_creacion VARCHAR(100) DEFAULT SYSTEM_USER NOT NULL,
    
    CONSTRAINT PK_SE_ABONA_CON PRIMARY KEY (numero_ticket, id_medio_de_pago),
    CONSTRAINT CK_SE_ABONA_CON_Monto CHECK (monto_imputado > 0)
);














-- =========================================
-- Bloque: Categoria y Producto
-- Luz Espíndola - Equipo 46
-- =========================================
use [supermercadoElSol-Prueba]
go

-- Categoría del producto (ej. Lácteos, Almacén, Bebidas)
-- No tiene FK: es una tabla base, no depende de ninguna otra.
CREATE TABLE CATEGORIA (
    id_categoria    INT NOT NULL,              -- Clave interna autogenerada
    nombre          VARCHAR(50) NOT NULL,      

    CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria)
);


-- Producto del catálogo del supermercado.
-- Depende de Categoria (relación 1:N, todo producto pertenece a una única categoría).
CREATE TABLE PRODUCTO (
    id_producto     INT NOT NULL,              -- Clave interna autogenerada
    codigo_barra    VARCHAR(20) NOT NULL,      -- RN.02: identificador único del producto en el mundo real
    marca           VARCHAR(50) NOT NULL,
    detalle         VARCHAR(200) NOT NULL,     -- Descripción extendida del producto
    precio_actual   DECIMAL(10,2) NOT NULL,
    stock_actual    INT NOT NULL,
    stock_minimo    INT NOT NULL,              -- Umbral para alertas de reposición (RN.03)
    id_categoria    INT NOT NULL,              -- FK obligatoria: RN.02 exige categoría única por producto

    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),

    -- Aunque id_producto es la clave interna, codigo_barra debe ser único
    -- porque es el identificador real del producto según RN.02.
    CONSTRAINT UQ_Producto_CodigoBarra UNIQUE (codigo_barra),

    -- Ningún precio ni stock puede ser negativo.
    CONSTRAINT CK_Producto_PrecioPositivo CHECK (precio_actual > 0),
    CONSTRAINT CK_Producto_StockActualPositivo CHECK (stock_actual >= 0),
    CONSTRAINT CK_Producto_StockMinimoPositivo CHECK (stock_minimo >= 0),

    -- No se puede borrar una categoría mientras tenga productos asociados.
    -- Si cambia el id_categoria, se actualiza en cascada en Producto.
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) 
        REFERENCES CATEGORIA(id_categoria)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
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
