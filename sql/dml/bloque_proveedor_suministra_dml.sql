-- =========================================
-- Bloque: Proveedor y Suministra
-- Alfredo López - Equipo 46
-- =========================================
USE SupermercadoElSol;
GO

-- =============================================================================
-- POBLADO INICIAL: PROVEEDOR (10 registros coherentes)
-- =============================================================================
INSERT INTO PROVEEDOR (cuit, razon_social, telefono, calle, numero, ciudad, codigo_postal, provincia)
VALUES 
    ('30501234568', 'Mastellone Hermanos S.A.',          '01144808000', 'Av. Almirante Brown',   '957',  'General Rodríguez', '1748', 'Buenos Aires'),
    ('30502345679', 'Molinos Río de la Plata S.A.',      '01143401000', 'Uruguay',               '4075', 'Victoria',          '1644', 'Buenos Aires'),
    ('30503456780', 'Arrocera San Salvador S.A.',        '03454911222', 'Ruta Nacional 18',      'Km 2', 'San Salvador',      '3218', 'Entre Ríos'),
    ('30505678902', 'Coca-Cola FEMSA de Argentina S.A.', '01146308000', 'Av. Amancio Alcorta',   '3570', 'CABA',              '1437', 'Buenos Aires'),
    ('30507890124', 'The Clorox Company de Argentina',   '01140082000', 'Gdor. Ugarte',          '2826', 'Munro',             '1605', 'Buenos Aires'),
    ('30508901235', 'Cervecería y Maltería Quilmes S.A.', '01147895000', 'Av. 12 de Octubre',    '100',  'Quilmes',           '1878', 'Buenos Aires'),
    ('30504567891', 'Aceitera General Deheza S.A.',      '03584053000', 'Ruta Nacional 158',     'Km 2', 'General Deheza',    '5923', 'Córdoba'),
    ('30506789013', 'Aguas Danone de Argentina S.A.',    '01143485000', 'Moreno',                '877',  'CABA',              '1091', 'Buenos Aires'),
    ('30509012346', 'Mondelez Argentina S.A.',           '01147087000', 'Av. Del Libertador',    '498',  'Vicente López',     '1638', 'Buenos Aires'),
    ('30711223344', 'Distribuidora del Litoral S.R.L.',  '03794455667', 'Av. Independencia',     '3200', 'Corrientes',        '3400', 'Corrientes');
GO

-- =============================================================================
-- POBLADO INICIAL: SUMINISTRA (11 registros de abastecimiento)
-- Relaciona los proveedores con los productos reales del catálogo (IDs 1 al 8)
-- =============================================================================
INSERT INTO SUMINISTRA (cuit, id_producto)
VALUES 
    -- Mastellone abastece Leche (1) y Yogur (6)
    ('30501234568', 1),
    ('30501234568', 6),

    -- Molinos abastece Fideos (2) y Polenta (7)
    ('30502345679', 2),
    ('30502345679', 7),

    -- Arrocera San Salvador abastece Arroz Gallo (3)
    ('30503456780', 3),

    -- Coca-Cola FEMSA abastece Gaseosa Coca-Cola (4)
    ('30505678902', 4),

    -- Clorox abastece Detergente Ayudín (5)
    ('30507890124', 5),

    -- Quilmes abastece Gaseosa Pepsi (8)
    ('30508901235', 8),

    -- Distribuidora del Litoral (abastece también Leche, Fideos y Arroz a nivel regional, RN.04)
    ('30711223344', 1),
    ('30711223344', 2),
    ('30711223344', 3);
GO

-- =============================================================================
-- CONSULTAS DE VERIFICACIÓN
-- =============================================================================
SELECT * FROM PROVEEDOR;
SELECT * FROM SUMINISTRA;
GO
