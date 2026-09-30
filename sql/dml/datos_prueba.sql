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

-- 1\. Ver todas las personas 
SELECT * FROM PERSONA; 
-- 2\. Ver todos los empleados 
SELECT * FROM EMPLEADO; 
-- 3\. Ver todos los clientes 
SELECT * FROM CLIENTE; 
GO

-- =========================================
-- Bloque: Categoria y Producto
-- Luz Espíndola - Equipo 46
-- =========================================
use [supermercadoElSol-Prueba]
go
-- Insertar datos de prueba en las tablas CATEGORIA y PRODUCTO
INSERT INTO CATEGORIA (id_categoria, nombre) VALUES (10, 'Lácteos');
INSERT INTO CATEGORIA (id_categoria, nombre) VALUES (20, 'Almacén');
INSERT INTO CATEGORIA (id_categoria, nombre) VALUES (30, 'Bebidas');
INSERT INTO CATEGORIA (id_categoria, nombre) VALUES (40, 'Limpieza');

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (1, '779123456001', 'La Serenísima', 'Leche Entera 1L sachet', 1200, 50, 10, 10);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (2, '779123456002', 'Matarazzo', 'Fideos Guiseros 500g', 900, 120, 20, 20);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (3, '779123456003', 'Gallo', 'Arroz Blanco 1kg', 1500, 80, 15, 20);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (4, '779123456004', 'Coca-Cola', 'Gaseosa Cola 2.25L', 2100, 60, 15, 30);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (5, '779123456005', 'Ayudín', 'Detergente 750ml', 1350, 40, 10, 40);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (6, '779123456006', 'La Serenísima', 'Yogur Bebible 1L', 1450, 35, 8, 10);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (7, '779123456007', 'Matarazzo', 'Polenta 500g', 750, 90, 20, 20);

INSERT INTO PRODUCTO (id_producto, codigo_barra, marca, detalle, precio_actual, stock_actual, stock_minimo, id_categoria)
VALUES (8, '779123456008', 'Pepsi', 'Gaseosa Cola Light 2.25L', 2000, 45, 12, 30);

--Verificación de los datos insertados
select *from Categoria;
select *from Producto;























-- 8 registros en DETALLE_VENTA

INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado) VALUES 
(1001, 10, 2, 150.00),
(1001, 12, 1, 450.50),
(1002, 15, 5, 20.00),
(1003, 10, 1, 150.00),
(1004, 22, 10, 99.99),
(1005, 12, 3, 450.50),
(1005, 15, 2, 20.00),
(1006, 30, 1, 1200.00);

-- 8 registros en SE_ABONA_CON
INSERT INTO SE_ABONA_CON (numero_ticket, id_medio_de_pago, monto_imputado) VALUES 
(1001, 1, 500.00),
(1001, 2, 250.50),
(1002, 1, 100.00),
(1003, 3, 150.00),
(1004, 2, 999.90),
(1005, 1, 1000.00),
(1005, 4, 410.00),
(1006, 2, 1200.00);

SELECT * FROM DETALLE_VENTA;
SELECT * FROM SE_ABONA_CON;
