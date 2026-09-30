-- Insertar 10 registros en PERSONA
INSERT INTO PERSONA (dni, cuil, nombre, apellido, calle, numero, ciudad, provincia, codigo_postal, telefono, correo_electronico, fecha_nacimiento) VALUES 
(35111222, '20-35111222-9', 'Carlos', 'Gómez', 'Av. 3 de Abril', 1250, 'Corrientes', 'Corrientes', '3400', '3794111111', 'carlos.gomez@email.com', '1990-05-12'), 
(38333444, '27-38333444-4', 'Laura', 'Martínez', 'San Martín', 845, 'Resistencia', 'Chaco', '3500', '3624222222', 'laura.martinez@email.com', '1994-08-25'), 
(32555666, '20-32555666-3', 'Roberto', 'Fernández', 'Belgrano', 2340, 'Corrientes', 'Corrientes', '3400', '3794333333', 'roberto.f@email.com', '1987-03-30'), 
(40777888, '27-40777888-8', 'María', 'López', 'Rivadavia', 560, 'Goya', 'Corrientes', '3450', '3777444444', 'maria.lopez@email.com', '1998-11-15'), 
(29999000, '20-29999000-1', 'Juan', 'Pérez', 'Junín', 1120, 'Corrientes', 'Corrientes', '3400', '3794555555', 'juan.perez@email.com', '1983-01-20'), 
(36123456, '27-36123456-5', 'Ana', 'Rodríguez', '9 de Julio', 430, 'Resistencia', 'Chaco', '3500', '3624666666', 'ana.rodriguez@email.com', '1991-07-08'), 
(41987654, '20-41987654-2', 'Diego', 'Sánchez', 'Córdoba', 780, 'Corrientes', 'Corrientes', '3400', '3794777777', 'diego.sanchez@email.com', '1999-09-14'), 
(34456789, '27-34456789-6', 'Patricia', 'Romero', 'Mendoza', 1540, 'Corrientes', 'Corrientes', '3400', '3794888888', 'patricia.r@email.com', '1989-12-03'), 
(37654321, '20-37654321-7', 'Gonzalo', 'Benítez', 'Santa Fe', 910, 'Resistencia', 'Chaco', '3500', '3624999999', 'gonzalo.b@email.com', '1993-04-18'), 
(42111222, '27-42111222-0', 'Florencia', 'Díaz', 'Salta', 320, 'Corrientes', 'Corrientes', '3400', '3794000000', 'florencia.diaz@email.com', '2000-02-28'),
(43111333, '20-43111333-5', 'Martín', 'Acosta', 'Av. Italia', 450, 'Resistencia', 'Chaco', '3500', '3624112233', 'martin.acosta@email.com', '2001-06-20'), 
(31888999, '27-31888999-1', 'Silvia', 'Vargas', 'Pellegrini', 1890, 'Corrientes', 'Corrientes', '3400', '3794998877', 'silvia.vargas@email.com', '1985-10-11'), 
(39222111, '20-39222111-8', 'Lucas', 'Mendoza', 'Bolívar', 620, 'Corrientes', 'Corrientes', '3400', '3794332211', 'lucas.mendoza@email.com', '1996-02-14');
GO

-- Insertar 8 empleados 
INSERT INTO EMPLEADO (dni, numero_legajo, rol) VALUES 
(35111222, 1001, 'Gerente'), 
(38333444, 1002, 'Cajero'), 
(32555666, 1003, 'Cajero'), 
(40777888, 1004, 'Repositor'), 
(36123456, 1005, 'Encargado de Depósito'),
(43111333, 1006, 'Cajero'), 
(31888999, 1007, 'Administrativo'), 
(39222111, 1008, 'Repositor');
GO

-- Insertar 8 clientes 
INSERT INTO CLIENTE (dni) VALUES 
(29999000), (41987654), (34456789), (37654321), (42111222), (38333444), (35111222), (40777888); 
GO
