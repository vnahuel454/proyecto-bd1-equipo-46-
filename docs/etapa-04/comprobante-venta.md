# Etapa IV – Comprobante de venta

## Necesidad de información
Emitir el comprobante de una venta: encabezado (ticket, fecha, cliente y
empleado que atendió) y detalle de productos, con el subtotal de cada
renglón y el total acumulado.

## Tablas involucradas
VENTA, CLIENTE, EMPLEADO, PERSONA, DETALLE_VENTA y PRODUCTO.
PERSONA se usa dos veces, con los alias `p_cli` (cliente) y `p_emp` (empleado).

## Estrategia SQL
- `INNER JOIN` entre 6 tablas (7 referencias, porque PERSONA se une dos
  veces), con alias, para reunir encabezado y detalle.
- Se une PERSONA dos veces (`p_cli` y `p_emp`) para obtener los nombres
  del cliente y del empleado.
- Subtotal por renglón: `Cantidad * precio_unitario_cobrado`. Se usa el
  precio cobrado en la venta y no `precio_actual` de PRODUCTO, para que el
  comprobante no cambie si el precio se modifica después.
- Total acumulado: subconsulta correlacionada que suma los renglones del
  mismo ticket hasta el renglón actual (`d2.id_producto <= dv.id_producto`).
- El número de ticket se recibe en la variable `@numero_ticket`.
- El total final (IVA y descuento incluidos) se toma de `VENTA.total`.

## Consulta
Ver `sql/consultas/comprobante_venta.sql`.

## Resultado esperado (ticket 1001)

| Nro. Ticket | Fecha y Hora | Cliente | Atendido por | Producto | Cantidad | Precio Unit. | Subtotal | Total Acumulado | Total Final |
|---|---|---|---|---|---|---|---|---|---|
| 1001 | 2026-03-01 09:15:00.000 | Pérez, Juan | Martínez, Laura | La Serenísima - Leche Entera 1L sachet | 2 | 1200.00 | 2400.00 | 2400.00 | 3993.00 |
| 1001 | 2026-03-01 09:15:00.000 | Pérez, Juan | Martínez, Laura | Matarazzo - Fideos Guiseros 500g | 1 | 900.00 | 900.00 | 3300.00 | 3993.00 |

Total final del comprobante: 3993.00 (subtotal 3300.00 + IVA 693.00 - descuento 0.00).


