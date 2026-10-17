USE SupermercadoElSol;
GO

--===========================================================
--           ******** CONSULTA 1 **********
-- Consulta de ventas por categorías en el mes de marzo 2026
--===========================================================

SELECT 
    c.id_categoria,
    c.nombre AS categoria,
    COUNT(DISTINCT v.numero_ticket) AS cantidad_tickets,
    SUM(dv.Cantidad) AS total_unidades_vendidas,
    SUM(dv.Cantidad * dv.precio_unitario_cobrado) AS total_recaudado
FROM VENTA v
INNER JOIN DETALLE_VENTA dv ON v.numero_ticket = dv.numero_ticket
INNER JOIN PRODUCTO p ON dv.id_producto = p.id_producto
INNER JOIN CATEGORIA c ON p.id_categoria = c.id_categoria
WHERE v.fecha_hora >= '2026-03-01 00:00:00' 
  AND v.fecha_hora <= '2026-03-31 23:59:59'
GROUP BY c.id_categoria, c.nombre
ORDER BY total_recaudado DESC;
GO

-- Resultado obtenido con los datos de prueba:
-- id_categoria  categoria   cantidad_tickets  total_recaudado  total_unidades_vendidas 
-- 40            Limpieza    1                 13500.00         10
-- 20            Almacén     3                  9900.00          8
-- 10            Lácteos     2                  6750.00          5
-- 30            Bebidas     2                  4100.00          2


--===========================================================
--           ******** CONSULTA 2 **********
-- Consulta de ventas por categorías en el mes de marzo 2026
-- Pagados en Efectivo
--===========================================================

SELECT 
    c.id_categoria,
    c.nombre AS categoria,
    COUNT(DISTINCT v.numero_ticket) AS cantidad_tickets_efectivo,
    SUM(dv.Cantidad) AS total_unidades_vendidas,
    SUM(dv.Cantidad * dv.precio_unitario_cobrado) AS total_recaudado_efectivo
FROM VENTA v
INNER JOIN DETALLE_VENTA dv ON v.numero_ticket = dv.numero_ticket
INNER JOIN PRODUCTO p ON dv.id_producto = p.id_producto
INNER JOIN CATEGORIA c ON p.id_categoria = c.id_categoria
INNER JOIN SE_ABONA_CON sa ON v.numero_ticket = sa.numero_ticket
INNER JOIN MEDIO_DE_PAGO mp ON sa.id_medio_de_pago = mp.id_medio_de_pago
WHERE v.fecha_hora >= '2026-03-01 00:00:00' 
  AND v.fecha_hora <= '2026-03-31 23:59:59'
  AND mp.id_medio_de_pago = 1  -- Filtra exclusivamente pagos en efectivo
GROUP BY c.id_categoria, c.nombre
ORDER BY total_recaudado_efectivo DESC;
GO

-- Resultado obtenido con los datos de prueba:
-- id_categoria  categoria   cantidad_tickets_efectivo  total_recaudado_efectivo  total_unidades_vendidas 
-- 20            Almacén     3                          9900.00                   8
-- 10            Lácteos     2                          6750.00                   5
