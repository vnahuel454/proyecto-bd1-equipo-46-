RN.01: Registro de Clientes
Para acceder a beneficios, promociones y acumulación de puntos, los clientes deben registrarse en el sistema proporcionando obligatoriamente su DNI (que actuará como identificador único), CUIL, nombre, apellido, dirección, teléfono, correo electrónico y fecha de nacimiento. No obstante, se permitirá realizar ventas a clientes no registrados bajo la figura tributaria de "Consumidor Final", asociándolos a un registro genérico por defecto para permitir la venta libre.

RN.02: Catálogo de Productos y Categorías
Cada producto del supermercado se identifica mediante un identificador interno único y debe registrar su código de barra, una descripción, una marca, un precio de venta actual y pertenecer a una única categoría de productos (ej. Almacén, Lácteos, Limpieza, Bebidas) para facilitar su organización y clasificación.

RN.03: Gestión de Stock y Alertas
De cada producto se debe registrar el stock actual y un nivel de stock mínimo permitido. Al concretarse una venta, el stock actual del producto debe disminuir automáticamente según la cantidad vendida. Si el stock actual desciende por debajo de su límite mínimo, el sistema debe generar de forma automática una alerta de reposición.

RN.04: Suministro de Productos por Proveedores
Los productos son suministrados por proveedores externos. Un mismo producto puede ser abastecido por uno o varios proveedores, y un proveedor puede suministrar una amplia variedad de productos. De cada proveedor se debe almacenar su CUIT (identificador único), razón social, dirección, teléfono de contacto y provincia.

RN.05: Historial de Precios Unitarios en el Detalle de Venta
Cada transacción de venta genera un detalle con los productos adquiridos. En dicho detalle se debe registrar obligatoriamente el precio unitario cobrado al momento de realizar la transacción y la cantidad vendida. Si el precio de un producto se modifica a futuro en el catálogo general, las ventas históricas ya registradas en la base de datos no deben verse alteradas bajo ninguna circunstancia, preservando la integridad de la facturación y las auditorías contables.

RN.06: Métodos de Pago Diversos
Cada venta efectuada se puede abonar mediante uno o varios métodos de pago de forma simultánea (Efectivo, Tarjeta de Débito, Tarjeta de Crédito, Transferencia Bancaria o Billetera Virtual). El sistema debe registrar de forma obligatoria el monto exacto imputado a cada medio de pago seleccionado en la transacción.

RN.07: Control de Empleados y Cajeros
Cada venta es registrada de forma obligatoria por un único Empleado en rol de Cajero, asociando su número de legajo de personal a la transacción para fines de auditoría, control de arqueo de caja y rendimiento laboral.

RN.08: Emisión de Tickets de Venta
Toda venta exitosa debe generar un Ticket de Facturación con un número correlativo único, fecha y hora de emisión, el subtotal de la compra, el IVA calculado, los descuentos aplicados y el importe total facturado.
