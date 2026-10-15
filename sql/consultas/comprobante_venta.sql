USE SupermercadoElSol;
GO

DECLARE @numero_ticket INT = 1001;

SELECT
    v.numero_ticket                              AS [Nro. Ticket],
    v.fecha_hora                                 AS [Fecha y Hora],
    p_cli.apellido + ', ' + p_cli.nombre         AS [Cliente],
    p_emp.apellido + ', ' + p_emp.nombre         AS [Atendido por],
    prod.marca + ' - ' + prod.detalle            AS [Producto],
    dv.Cantidad                                  AS [Cantidad],
    dv.precio_unitario_cobrado                   AS [Precio Unit.],
    dv.Cantidad * dv.precio_unitario_cobrado     AS [Subtotal],
    (SELECT SUM(d2.Cantidad * d2.precio_unitario_cobrado)
     FROM DETALLE_VENTA d2
     WHERE d2.numero_ticket = dv.numero_ticket
       AND d2.id_producto <= dv.id_producto)     AS [Total Acumulado],
    v.total                                      AS [Total Final]
FROM VENTA v
    INNER JOIN CLIENTE c         ON v.dni_Cliente   = c.dni
    INNER JOIN PERSONA p_cli     ON c.dni           = p_cli.dni
    INNER JOIN EMPLEADO e        ON v.dni_Empleado  = e.dni
    INNER JOIN PERSONA p_emp     ON e.dni           = p_emp.dni
    INNER JOIN DETALLE_VENTA dv  ON v.numero_ticket = dv.numero_ticket
    INNER JOIN PRODUCTO prod     ON prod.id_producto = dv.id_producto
WHERE v.numero_ticket = @numero_ticket
ORDER BY dv.id_producto;
GO
