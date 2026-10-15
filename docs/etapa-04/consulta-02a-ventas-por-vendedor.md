# Consulta 2a: ventas por vendedor

## Qué necesita saber el negocio

¿Cuánto vendió cada vendedor en un período y cuántos tickets emitió? Esta información sirve para evaluar el rendimiento de cada cajero, como pide la RN.07.

## Tablas que se usan

| Tabla | Para qué se usa |
|---|---|
| VENTA | Tiene el total de cada ticket, la fecha y el DNI del empleado que lo registró |
| EMPLEADO | Une cada venta con la persona que vendió |
| PERSONA | Tiene el apellido y el nombre del empleado |

## Cómo funciona

1. Se parte de VENTA, que tiene un registro por ticket.
2. Se une con EMPLEADO por el DNI, para saber quién registró cada venta.
3. Se une con PERSONA por el DNI, para obtener el apellido.
4. Se filtran los tickets del período con `WHERE`.
5. `GROUP BY` agrupa los tickets por vendedor.
6. `COUNT(*)` cuenta los tickets y `SUM(v.total)` suma sus totales.
7. `ORDER BY` ordena de mayor a menor venta.

## Consulta principal

```sql
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
```

## Resultado esperado (marzo de 2026)

| Apellido | Tickets | Total vendido |
|---|---|---|
| Fernández | 3 | 90825.00 |
| Acosta | 3 | 43569.00 |
| Martínez | 4 | 14332.50 |

## Decisiones tomadas

- **Rango de fechas:** se usa `>= inicio` y `< día siguiente al fin`. Así se incluye todo el último día, sin importar la hora de la venta.
- **Total por ticket:** se suma `VENTA.total`, que ya incluye IVA y descuento.
- **Datos de prueba:** los tickets 1005 y 1009 estaban registrados por un empleado con rol Gerente. Se corrigieron para que los registre un cajero.

## Variantes incluidas en el archivo

| Variante | Qué agrega |
|---|---|
| 2 | Muestra el nombre completo y el rol del vendedor |
| 3 | Filtra por rol Cajero, como control de la RN.07 |
| 4 | Usa las variables `@desde` y `@hasta` para cambiar el rango fácilmente |

Archivo con las consultas: `sql/consultas/02a_ventas_por_vendedor.sql`
