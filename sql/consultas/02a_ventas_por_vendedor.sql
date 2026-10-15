/* ============================================================
   Etapa IV - Consultas y Casos de Uso
   Archivo : 02a_ventas_por_vendedor.sql
   Equipo  : 46 - Supermercado El Sol
   Alumna : Luz Espíndola
   Consigna: Reporte agregado - total de ventas realizadas por
             cada vendedor en un rango de fechas.
   Tablas  : VENTA, EMPLEADO, PERSONA
   Conceptos: JOIN, WHERE, GROUP BY, COUNT, SUM, ORDER BY
   
   ============================================================ */


/* ------------------------------------------------------------
   CONSULTA 1: ¿cuánto vendió cada vendedor en marzo de 2026 y
   cuántos tickets emitió?
   Rango semiabierto: >= 01/03 y < 01/04 (incluye todo el 31/03).
   Resultado esperado con los datos de prueba actuales:
     Fernández  3 tickets  90825.00
     Acosta     3 tickets  43569.00
     Martínez   4 tickets  14332.50
   ------------------------------------------------------------ */
SELECT e.dni,
       p.apellido,
       COUNT(*)     AS tickets,
       SUM(v.total) AS total_vendido
FROM VENTA v
JOIN EMPLEADO e ON e.dni = v.dni_Empleado   
JOIN PERSONA  p ON p.dni = e.dni            
WHERE v.fecha_hora >= '20260301'
  AND v.fecha_hora <  '20260401'
GROUP BY e.dni, p.apellido                 
ORDER BY total_vendido DESC;
GO


/* ------------------------------------------------------------
   CONSULTA 2: Misma idea que la consulta 1, mostrando nombre y rol.
   Las columnas del SELECT que no están dentro de COUNT ni de SUM
   (dni, nombre, apellido y rol) deben estar también en el GROUP BY.
   ------------------------------------------------------------ */
SELECT e.dni,
       p.nombre + ' ' + p.apellido AS vendedor,
       e.rol,
       COUNT(*)     AS tickets,
       SUM(v.total) AS total_vendido
FROM VENTA v
JOIN EMPLEADO e ON e.dni = v.dni_Empleado
JOIN PERSONA  p ON p.dni = e.dni
WHERE v.fecha_hora >= '20260301'
  AND v.fecha_hora <  '20260401'
GROUP BY e.dni, p.nombre, p.apellido, e.rol
ORDER BY total_vendido DESC;
GO


/* ------------------------------------------------------------
   CONSULTA 3 (control de la RN.07): solo empleados con rol Cajero
   RN.07: cada venta la registra un empleado en rol de Cajero.
   Mismo reporte que la consulta 1, filtrando por rol 'Cajero'.
   Con los datos corregidos da el mismo resultado que la consulta 1.
   Si diera distinto, habría una venta registrada por un empleado
   que no tiene rol Cajero.
   Resultado esperado con los datos actuales:
     Fernández 3 / 90825.00 ; Acosta 3 / 43569.00 ; Martínez 4 / 14332.50
   ------------------------------------------------------------ */
SELECT e.dni,
       p.apellido,
       COUNT(*)     AS tickets,
       SUM(v.total) AS total_vendido
FROM VENTA v
JOIN EMPLEADO e ON e.dni = v.dni_Empleado
JOIN PERSONA  p ON p.dni = e.dni
WHERE e.rol = 'Cajero'
  AND v.fecha_hora >= '20260301'
  AND v.fecha_hora <  '20260401'
GROUP BY e.dni, p.apellido
ORDER BY total_vendido DESC;
GO


/* ------------------------------------------------------------
   CONSULTA 4: rango de fechas con variables
   Para cambiar el rango se modifican solo @desde y @hasta.
   @hasta es el primer día que NO se incluye.
   Con el rango 01/03 a 16/03 (hasta el 15 inclusive) esperado:
     Acosta 1 / 14335.00 ; Martínez 4 / 14332.50 ; Fernández 1 / 8075.00
   ------------------------------------------------------------ */
DECLARE @desde DATETIME = '20260301';
DECLARE @hasta DATETIME = '20260316';

SELECT e.dni,
       p.apellido,
       COUNT(*)     AS tickets,
       SUM(v.total) AS total_vendido
FROM VENTA v
JOIN EMPLEADO e ON e.dni = v.dni_Empleado
JOIN PERSONA  p ON p.dni = e.dni
WHERE v.fecha_hora >= @desde
  AND v.fecha_hora <  @hasta
GROUP BY e.dni, p.apellido
ORDER BY total_vendido DESC;
GO
