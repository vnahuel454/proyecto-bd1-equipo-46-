Consulta 1: Ventas por Categoría en un Rango de Fechas

Descripción

Esta consulta genera un informe consolidado de las ventas agrupadas por categoría de producto para un periodo determinado 
(marzo de 2026). Permite analizar el volumen de transacciones, las unidades físicas vendidas y el monto total recaudado 
por cada categoría de producto.

Explicación Técnica

1. Unión de Tablas (INNER JOIN):

	VENTA se relaciona con DETALLE_VENTA a través de numero_ticket para obtener los ítems vendidos en cada transacción.

	DETALLE_VENTA se conecta con PRODUCTO por id_producto para acceder al detalle de cada artículo.

	PRODUCTO se vincula con CATEGORIA por id_categoria para agrupar los artículos en sus respectivas clasificaciones comerciales.

2. Filtro Temporal (WHERE):

	Restringe la búsqueda a las ventas realizadas entre el 1 de marzo de 2026 y el 31 de marzo de 2026.

3. Métricas de Agregación y Agrupamiento (SELECT / GROUP BY):

	COUNT(DISTINCT v.numero_ticket): Cuenta cuántos comprobantes o tickets únicos compraron artículos de la categoría.

	SUM(dv.Cantidad): Suma la cantidad total de unidades vendidas pertenecientes a la categoría.

	SUM(dv.Cantidad * dv.precio_unitario_cobrado): Calcula el total del dinero recaudado por la categoría en el rango especificado.

	GROUP BY c.id_categoria, c.nombre: Consolida los resultados por cada categoría.

	ORDER BY total_recaudado DESC: Ordena las categorías de mayor a menor ingreso monetario.


Consulta 2: Ventas por Categoría Pagadas en Efectivo

Descripción

Esta consulta permite obtener un reporte consolidado de las ventas por categoría de productos abonadas exclusivamente 
en efectivo (ARS) durante un periodo determinado (marzo de 2026).


Explicación Técnica

1. Relación entre Tablas (INNER JOIN):

	VENTA se conecta con DETALLE_VENTA para acceder a los productos individuales de cada ticket.

	DETALLE_VENTA se une con PRODUCTO y CATEGORIA para obtener la clasificación por categoría de los productos vendidos.

	VENTA se vincula con SE_ABONA_CON y MEDIO_DE_PAGO para identificar el método de pago utilizado.

2. Filtros Aplicados (WHERE):

	v.fecha_hora: Limita la búsqueda al periodo comprendido entre el 1 y el 31 de marzo de 2026.

	mp.id_medio_de_pago = 1: Filtra únicamente las ventas abonadas con el id de medio de pago correspondiente a Efectivo ARS.

3. Métricas Calculadas (SELECT y GROUP BY):

	COUNT(DISTINCT v.numero_ticket): Cantidad de tickets únicos en efectivo.

	SUM(dv.Cantidad): Total de unidades físicas vendidas en la categoría.

	SUM(dv.Cantidad * dv.precio_unitario_cobrado): Monto total recaudado en efectivo por cada categoría.

	GROUP BY: Agrupa los datos por el ID y nombre de cada categoría.

	ORDER BY: Ordena los resultados de forma descendente según el total recaudado.



  Archivo: sql/consultas/consulta_ventas_por_categoria.sql