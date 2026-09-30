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