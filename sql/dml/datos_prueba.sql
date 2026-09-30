USE SupermercadoElSol;
GO

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

INSERT INTO SUMINISTRA (cuit, id_producto)
VALUES 
    ('30501234568', 1),
    ('30501234568', 6),
    ('30502345679', 2),
    ('30502345679', 7),
    ('30503456780', 3),
    ('30505678902', 4),
    ('30507890124', 5),
    ('30508901235', 8),
    ('30711223344', 1),
    ('30711223344', 2),
    ('30711223344', 3);
GO

SELECT * FROM PROVEEDOR;
SELECT * FROM SUMINISTRA;
GO
