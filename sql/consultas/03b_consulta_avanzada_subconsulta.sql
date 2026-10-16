USE SupermercadoElSol;
GO

-- Consulta principal: tickets con monto superior al promedio general de ventas
SELECT 
    v.numero_ticket,
    v.fecha_hora,
    CONCAT(p_cli.apellido, ', ', p_cli.nombre) AS cliente,
    p_cli.correo_electronico                   AS email_cliente,
    CONCAT(p_emp.apellido, ', ', p_emp.nombre) AS atendido_por,
    e.rol                                      AS rol_empleado,
    v.subtotal,
    v.descuento,
    v.total                                    AS total_ticket,
    ROUND((SELECT AVG(total) FROM VENTA), 2)   AS promedio_general,
    ROUND(v.total - (SELECT AVG(total) FROM VENTA), 2) AS diferencia
FROM VENTA v
JOIN CLIENTE c     ON c.dni = v.dni_Cliente
JOIN PERSONA p_cli ON p_cli.dni = c.dni
JOIN EMPLEADO e    ON e.dni = v.dni_Empleado
JOIN PERSONA p_emp ON p_emp.dni = e.dni
WHERE v.total > (SELECT AVG(total) FROM VENTA)
ORDER BY v.total DESC;
GO

-- Variante 2: tickets que superan el promedio del propio cliente
SELECT 
    v.numero_ticket,
    v.fecha_hora,
    CONCAT(p_cli.apellido, ', ', p_cli.nombre) AS cliente,
    v.total                                    AS total_ticket,
    ROUND((
        SELECT AVG(v2.total) 
        FROM VENTA v2 
        WHERE v2.dni_Cliente = v.dni_Cliente
    ), 2) AS promedio_cliente
FROM VENTA v
JOIN CLIENTE c     ON c.dni = v.dni_Cliente
JOIN PERSONA p_cli ON p_cli.dni = c.dni
WHERE v.total > (
    SELECT AVG(v2.total) 
    FROM VENTA v2 
    WHERE v2.dni_Cliente = v.dni_Cliente
)
ORDER BY cliente ASC, v.total DESC;
GO

-- Variante 3: productos que todavia no registran ventas
SELECT 
    p.id_producto,
    p.codigo_barra,
    p.marca,
    p.detalle,
    c.nombre AS categoria,
    p.precio_actual,
    p.stock_actual
FROM PRODUCTO p
JOIN CATEGORIA c ON c.id_categoria = p.id_categoria
WHERE NOT EXISTS (
    SELECT 1 
    FROM DETALLE_VENTA dv 
    WHERE dv.id_producto = p.id_producto
)
ORDER BY c.nombre ASC, p.marca ASC;
GO
