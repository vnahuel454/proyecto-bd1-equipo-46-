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


Cardinalidades
1. Venta — Medio_de_pago
Un mismo ticket se puede abonar combinando varios medios de pago (efectivo, débito, etc.), y un medio de pago (ej. "Efectivo") se utiliza en muchas ventas.
•	Venta a Medio_de_pago: Una venta debe abonarse como mínimo con 1 medio de pago y puede incluir N medios de pago.
•	Medio_de_pago a Venta: Un medio de pago puede no haberse usado en ninguna venta todavía (0) o registrarse en muchas ventas (N).
•	Cardinalidad de la relación: Muchos a Muchos (N:M)
o	Relación intermediaria (se_abona_con): Venta (1,N) <--- se_abona_con ---> (0,N) Medio_de_pago
2. Venta — Producto
Una venta incluye uno o varios productos en su detalle, y un producto puede venderse múltiples veces en distintas ventas.
•	Venta a Producto: Una venta incluye como mínimo 1 producto (o ítem) y como máximo N productos.
•	Producto a Venta: Un producto puede no haberse vendido aún (0) o figurar en los detalles de N ventas.
•	Cardinalidad de la relación: Muchos a Muchos (N:M)
o	Relación intermediaria (detalle_venta): Venta (1,N) <--- detalle_venta ---> (0,N) Producto
3. Cliente — Venta
Hay dos tipos de compradores: clientes registrados y consumidores finales que compran sin registrarse.
•	Cliente a Venta: Un cliente registrado puede haberse dado de alta pero no haber comprado aún (0) o haber realizado N ventas.
•	Venta a Cliente: Una venta puede pertenecer a 0 clientes (si la realizó un consumidor final no registrado) o a 1 cliente registrado.
•	Cardinalidad de la relación: Uno a Muchos (1:N)
o	Cliente (0,N) <--- realiza ---> (0,1) Venta
4. Empleado — Venta
Todas las ventas son atendidas por un empleado con rol de cajero.
•	Empleado a Venta: Un empleado (cajero) puede no haber registrado ventas aún (0) o registrar N ventas a lo largo de su jornada.
•	Venta a Empleado: Toda venta debe ser registrada obligatoriamente por 1 y solo 1 empleado cajero.
•	Cardinalidad de la relación: Uno a Muchos (1:N)
o	Empleado (0,N) <--- registra ---> (1,1) Venta
5. Producto — Categoria
Cada producto pertenece a una sola categoría.
•	Producto a Categoria: Un producto pertenece obligatoriamente a 1 y solo 1 categoría.
•	Categoria a Producto: Una categoría puede no tener productos asignados temporalmente (0) o agrupar N productos.
•	Cardinalidad de la relación: Uno a Muchos (1:N)
o	Categoria (0,N) <--- pertenece_a ---> (1,1) Producto
6. Proveedor — Producto
Un mismo producto puede ser suministrado por más de un proveedor externo.
•	Proveedor a Producto: Un proveedor puede suministrar 0 productos (proveedor dado de alta reciente) o N productos.
•	Producto a Proveedor: Un producto puede no tener proveedor registrado temporalmente o ser de fabricación propia (0), o ser suministrado por N proveedores.
•	Cardinalidad de la relación: Muchos a Muchos (N:M)
o	Proveedor (0,N) <--- suministra ---> (0,N) Producto


