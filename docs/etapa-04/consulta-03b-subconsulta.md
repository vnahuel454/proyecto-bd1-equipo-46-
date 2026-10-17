# Consulta 3b: ventas superiores al ticket promedio

Esta consulta busca responder cuáles fueron las ventas con un monto total superior al promedio general del supermercado, permitiendo ver las compras más altas de la tienda, qué cliente las hizo y qué cajero cobró el ticket.

Para armarla se parte de la tabla VENTA, que guarda número de ticket, fecha, subtotal, descuento y total cobrado, y se une con CLIENTE y EMPLEADO por el DNI correspondiente. La tabla PERSONA se vincula dos veces usando los alias p_cli y p_emp para traer nombre, apellido y correo tanto del cliente como del empleado sin generar nombres duplicados.

En la cláusula WHERE se aplica la subconsulta escalar (SELECT AVG(total) FROM VENTA), que calcula el promedio de todas las ventas y filtra los tickets que quedan por encima. Se utiliza VENTA.total en lugar del subtotal porque representa el dinero que efectivamente pagó el cliente con IVA y descuentos incluidos. Además, se proyectan ese promedio general y la diferencia en pesos respecto al ticket, aplicando ROUND a dos decimales para que se lean como importes monetarios, y se ordenan los resultados de mayor a menor según el total vendido.

```sql
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
```

Con los datos de prueba actuales el promedio general de los 10 tickets cargados es de $14.872,65. Los registros obtenidos son:

| Nro. Ticket | Fecha y Hora | Cliente | Email Cliente | Atendido por | Rol | Subtotal | Descuento | Total Ticket | Promedio General | Diferencia |
|---|---|---|---|---|---|---|---|---|---|---|
| 1010 | 2026-03-28 21:00:00 | Gómez, Carlos | carlos.gomez@email.com | Fernández, Roberto | Cajero | 45000.00 | 5000.00 | 49450.00 | 14872.65 | 34577.35 |
| 1007 | 2026-03-18 18:35:00 | Gómez, Carlos | carlos.gomez@email.com | Fernández, Roberto | Cajero | 30000.00 | 3000.00 | 33300.00 | 14872.65 | 18427.35 |
| 1009 | 2026-03-25 20:15:00 | Pérez, Juan | juan.perez@email.com | Acosta, Martín | Cajero | 18000.00 | 1500.00 | 20280.00 | 14872.65 | 5407.35 |

En el archivo sql/consultas/03b_consulta_avanzada_subconsulta.sql se incluyen además dos variantes: una que compara cada ticket contra el promedio histórico de ese mismo cliente en lugar del general, y otra que muestra los productos cargados que todavía no registran ventas utilizando NOT EXISTS con DETALLE_VENTA.
