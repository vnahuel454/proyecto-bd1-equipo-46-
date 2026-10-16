USE SupermercadoElSol;
GO

SELECT 
    p.dni,
    p.apellido + ', ' + p.nombre AS cliente,
    COUNT(v.numero_ticket) AS cantidad_compras,
    SUM(v.total) AS monto_total_gastado
FROM CLIENTE c
INNER JOIN PERSONA p ON c.dni = p.dni
INNER JOIN VENTA v ON c.dni = v.dni_Cliente
GROUP BY p.dni, p.apellido, p.nombre
HAVING SUM(v.total) > 5000.00
ORDER BY monto_total_gastado DESC;
GO
