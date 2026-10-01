USE SupermercadoElSol; 
GO

IF OBJECT_ID('PERSONA', 'U') IS NOT NULL DROP TABLE PERSONA;
IF OBJECT_ID('PROVEEDOR', 'U') IS NOT NULL DROP TABLE PROVEEDOR;
IF OBJECT_ID('MEDIO_DE_PAGO', 'U') IS NOT NULL DROP TABLE MEDIO_DE_PAGO;
IF OBJECT_ID('CATEGORIA', 'U') IS NOT NULL DROP TABLE CATEGORIA;
IF OBJECT_ID('EMPLEADO', 'U') IS NOT NULL DROP TABLE EMPLEADO;
IF OBJECT_ID('CLIENTE', 'U') IS NOT NULL DROP TABLE CLIENTE; 
IF OBJECT_ID('PRODUCTO', 'U') IS NOT NULL DROP TABLE PRODUCTO;
IF OBJECT_ID('VENTA', 'U') IS NOT NULL DROP TABLE VENTA;
IF OBJECT_ID('SE_ABONA_CON', 'U') IS NOT NULL DROP TABLE SE_ABONA_CON;
IF OBJECT_ID('SUMINISTRA', 'U') IS NOT NULL DROP TABLE SUMINISTRA;
IF OBJECT_ID('DETALLE_VENTA', 'U') IS NOT NULL DROP TABLE DETALLE_VENTA;


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

CREATE TABLE MEDIO_DE_PAGO (
    id_medio_de_pago INT PRIMARY KEY,
    [Descripción] VARCHAR(100) NOT NULL
);
GO

CREATE TABLE CATEGORIA (
    id_categoria    INT NOT NULL,
    nombre          VARCHAR(50) NOT NULL,      
    CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria)
);
GO
	
 CREATE TABLE EMPLEADO ( 
	 dni INT NOT NULL, 
	 numero_legajo INT NOT NULL, 
	 rol VARCHAR(50) NOT NULL, 
	 CONSTRAINT pk_empleado PRIMARY KEY (dni), 
	 CONSTRAINT uq_empleado_legajo UNIQUE (numero_legajo), 
	 CONSTRAINT fk_empleado_persona FOREIGN KEY (dni) REFERENCES Persona(dni) ON DELETE CASCADE ON UPDATE CASCADE, 
	 CONSTRAINT ck_empleado_rol CHECK (rol IN ('Cajero', 'Repositor', 'Gerente', 'Encargado de Depósito', 'Administrativo')) 
 );
 GO

CREATE TABLE CLIENTE (
    dni INT NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (dni),
    CONSTRAINT fk_cliente_persona FOREIGN KEY (dni) REFERENCES Persona(dni) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE PRODUCTO (
    id_producto     INT NOT NULL,
    codigo_barra    VARCHAR(20) NOT NULL,
    marca           VARCHAR(50) NOT NULL,
    detalle         VARCHAR(200) NOT NULL,
    precio_actual   DECIMAL(10,2) NOT NULL,
    stock_actual    INT NOT NULL,
    stock_minimo    INT NOT NULL,
    id_categoria    INT NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
    CONSTRAINT UQ_Producto_CodigoBarra UNIQUE (codigo_barra),
    CONSTRAINT CK_Producto_PrecioPositivo CHECK (precio_actual > 0),
    CONSTRAINT CK_Producto_StockActualPositivo CHECK (stock_actual >= 0),
    CONSTRAINT CK_Producto_StockMinimoPositivo CHECK (stock_minimo >= 0),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria) ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

CREATE TABLE VENTA (
    numero_ticket INT PRIMARY KEY,
    fecha_hora DATETIME NOT NULL,
    Subtotal DECIMAL(10, 2) NOT NULL,
    iva DECIMAL(10, 2) NOT NULL,
    descuento DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL,
    dni_Empleado INT NOT NULL,
    dni_Cliente INT NOT NULL,
    CONSTRAINT fk_venta_empleado FOREIGN KEY (dni_Empleado) REFERENCES EMPLEADO(dni),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (dni_Cliente) REFERENCES CLIENTE(dni)
);
GO

CREATE TABLE SE_ABONA_CON (
    numero_ticket INT NOT NULL,
    id_medio_de_pago INT NOT NULL,
    monto_imputado DECIMAL(10,2) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE() NOT NULL,
    usuario_registro VARCHAR(100) DEFAULT SYSTEM_USER NOT NULL,
    CONSTRAINT PK_SE_ABONA_CON PRIMARY KEY (numero_ticket, id_medio_de_pago),
    CONSTRAINT CK_SE_ABONA_CON_Monto CHECK (monto_imputado > 0)
);
GO

ALTER TABLE SE_ABONA_CON ADD CONSTRAINT FK_SE_ABONA_CON_VENTA FOREIGN KEY (numero_ticket) REFERENCES VENTA(numero_ticket) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE SE_ABONA_CON ADD CONSTRAINT FK_SE_ABONA_CON_MEDIO FOREIGN KEY (id_medio_de_pago) REFERENCES MEDIO_DE_PAGO(id_medio_de_pago) ON UPDATE CASCADE ON DELETE NO ACTION;
GO

CREATE TABLE SUMINISTRA (
    cuit            VARCHAR(11)     NOT NULL,
    id_producto     INT             NOT NULL,
    CONSTRAINT PK_Suministra PRIMARY KEY (cuit, id_producto),
    CONSTRAINT FK_Suministra_Proveedor FOREIGN KEY (cuit) REFERENCES PROVEEDOR(cuit) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Suministra_Producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto) ON UPDATE CASCADE ON DELETE CASCADE
);
GO

CREATE TABLE DETALLE_VENTA (
    numero_ticket INT NOT NULL,
    id_producto INT NOT NULL,
    Cantidad INT NOT NULL,
    precio_unitario_cobrado DECIMAL(10,2) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE() NOT NULL,
    usuario_registro VARCHAR(100) DEFAULT SYSTEM_USER NOT NULL,
    CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY (numero_ticket, id_producto),
    CONSTRAINT CK_DETALLE_VENTA_Cantidad CHECK (Cantidad >= 0)
);
GO

ALTER TABLE DETALLE_VENTA ADD CONSTRAINT FK_DETALLE_VENTA_PRODUCTO FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE DETALLE_VENTA ADD CONSTRAINT FK_DETALLE_VENTA_VENTA FOREIGN KEY (numero_ticket) REFERENCES VENTA(numero_ticket) ON UPDATE CASCADE ON DELETE CASCADE;
GO


