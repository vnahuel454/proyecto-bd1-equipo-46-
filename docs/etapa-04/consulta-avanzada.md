# Consulta 4: clientes con compras acumuladas superiores a \$5000

## Qué necesita saber el negocio

¿Quiénes son los clientes que realizaron un gasto total significativo en el supermercado? Esta información permite al área de marketing identificar a los clientes de alto valor (clientes VIP) para diseñar campañas de fidelización dirigidas o beneficios exclusivos.

## Tablas que se usan

| Tabla | Para qué se usa |
|---|---|
| CLIENTE | Permite identificar a los sujetos registrados como clientes en el sistema |
| PERSONA | Aporta los datos filiatorios (DNI, apellido y nombre) del cliente para el reporte |
| VENTA | Contiene el historial de los tickets emitidos con sus respectivos montos totales |

## Cómo funciona

1. Se realiza un `INNER JOIN` entre CLIENTE y PERSONA por el DNI para obtener los datos del comprador.
2. Se vincula con la tabla VENTA a través del campo `dni_Cliente` para acceder al historial de sus transacciones.
3. `GROUP BY` agrupa los registros por el DNI, apellido y nombre para colapsar los múltiples tickets de un mismo cliente en una única fila de resumen.
4. `COUNT(v.numero_ticket)` calcula la cantidad de compras realizadas por cada persona.
5. `SUM(v.total)` suma los montos de todos los tickets pertenecientes a cada cliente.
6. `HAVING SUM(v.total) > 5000.00` actúa como el filtro del reporte, eliminando de la lista a todos los clientes que no superen el umbral de los 5.000 pesos.
7. `ORDER BY` ordena el listado de mayor a menor según el monto total gastado.

## Consulta principal

```sql
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
```

## Resultados esperado 

| DNI | Cliente | Cantidad compras | Monto total gastado |
|---|---|---|---|
| 35111222 | Gómez, Carlos | 2 | 82750.00 |
| 29999000 | Pérez, Juan | 2 | 24273.00 |
| 37654321 | Benítez, Gonzalo | 1 | 14335.00 |
| 40777888 | López, María | 1 | 8954.00 |
| 41987654 | Sánchez, Diego | 1 | 8075.00 |
| 42111222 | Díaz, Florencia | 1 | 7078.50 |

## Decisiones tomadas

- **Uso obligatorio de HAVING:** Se seleccionó esta cláusula porque el criterio de filtrado depende de una suma agregada. Intentar colocar esta condición dentro del `WHERE` provocaría un error de ejecución, ya que el motor de la base de datos evalúa el `WHERE` antes de consolidar los grupos (siguiendo el Orden Lógico de Procesamiento).
- **Monto total neto:** Se eligió la columna `VENTA.total` para calcular el gasto acumulado debido a que este campo ya contempla el impacto final del IVA y los descuentos aplicados en la línea de caja.
- **Control de exclusión:** Aquellos clientes registrados cuyo gasto total sea menor o igual a \$5.000 (como el caso de Romero, Patricia, que posee un único ticket por \$2.041) son omitidos correctamente por el motor para preservar la pureza del reporte VIP.

Archivo con las consultas: `sql/consultas/03a_clientes_compras_mayores_5000.sql`

