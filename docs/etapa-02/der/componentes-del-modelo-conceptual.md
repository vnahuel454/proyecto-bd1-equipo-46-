Entidades:

-Venta.
-Empleado.
-Persona.
-Cliente.
-Producto.
-Proveedor.
-Medio_de_pago.
-Categoria.
-descripcion_producto.

Relaciones:

- Venta —>  se_abona_con —>  medio_de_pago 
- Venta —> detalle_venta —> producto 
- Cliente —> realiza —> Venta
- Empleado —> registra —> Venta
- Producto —> pertenece_a —> Categoria
- Proveedor —> suministra —> Producto

Atributos (entidades y relaciones):

Entidad Persona: dni (atributo unico), fecha_nacimiento, cuil, email, telefono, nombre_completo(atributo compuesto formado por: nombre, apellido), direccion(atributo compuesto formado por: ciudad, numero, calle, provincia,codigo_postal).

Entidad Cliente: -

Entidad  Empleado: numero_legajo, rol.

Entidad Venta: total, numero_ticket(atributo unico), fecha_hora, descuento, iva, subtotal.

Entidad medio_de_pago: id_medio_de_pago(atributo unico), descripcion.

Entidad producto: stock_actual, id_producto(atributo unico), codigo_barra, stock_minimo, marca, precio_actual, detalle.

Entidad proveedor: razon_social, cuit(atributo unico), telefono, direccion(atributo compuesto: numero, ciudad, calle, codigo_postal, provincia).

Entidad categoria: id_categoria(atributo unico) , nombre.

Relacion detalle_venta: subtotal(atributo parcial), cantidad, precio_unitario_cobrado.

Relacion se_abona_con: monto_imputado.



Supertipos y subtipos:

Supertipo: Persona

Subtipo: Empleado y Cliente

clasificacion: solapada, parcial.
