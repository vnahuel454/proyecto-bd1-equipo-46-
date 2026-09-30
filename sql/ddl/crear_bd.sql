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
