# Decisiones de diseño — Etapa II

## Cantidad de tablas (11)

La consigna del proyecto sugiere un esquema de entre 6 y 10 relaciones, permitiendo justificar una cantidad distinta cuando el dominio lo requiera. Nuestro esquema final tiene 
11 tablas: Producto, Proveedor, Venta, Categoria, Persona, 
Empleado, Cliente, Medio_de_Pago, Suministra, Detalle_Venta y Se_Abona_Con.

La tabla de más respecto al rango sugerido se explica por la siguiente decisión 
de diseño:

1. **Generalización Persona → Empleado / Cliente.** Se optó por modelar Persona 
   como superclase de Empleado y Cliente, ya que ambos roles comparten un 
   conjunto amplio de atributos personales (nombre, apellido, dirección, 
   teléfono, DNI, fecha de nacimiento, email). Esta decisión agrega una tabla 
   (Persona) respecto a modelar Cliente y Empleado como entidades totalmente 
   independientes, a cambio de eliminar la redundancia de esos atributos 
   compartidos y garantizar una única fuente de identidad (DNI) entre ambos 
   roles.

La generalización se definió como **solapada** (una misma persona puede ser 
Empleado y Cliente a la vez — por ejemplo, un empleado que también se registra 
como cliente frecuente) y **parcial** (puede existir una persona en el sistema 
sin haber sido clasificada aún como Empleado ni como Cliente).

Sobre este último punto hubo una diferencia de opiniones dentro del equipo: 
parte del grupo consideraba que debía ser **total**, argumentando que no 
tendría sentido registrar una Persona que no fuera ni Empleado ni Cliente. 
Finalmente se optó por dejarla parcial, ya que el sistema podría necesitar 
registrar una persona de forma anticipada (por ejemplo, un empleado en proceso 
de alta) antes de asignarle formalmente el rol correspondiente.

## Fusión de Descripcion_Producto en Producto

En una revisión posterior del DER se decidió fusionar el atributo `detalle` 
directamente en `Producto`, en lugar de mantenerlo como tabla separada 
(relación 1:1 total en ambos sentidos). Esta simplificación no afecta la 
normalización del esquema (el atributo depende igual de la clave, esté en 
una tabla o en la otra) y reduce el modelo de 12 a 11 tablas.

## Por qué existen las claves foráneas del modelo

| Tabla | FK | Relación que resuelve | Cardinalidad |
|---|---|---|---|
| Producto | fk_CATEGORIA | Un producto pertenece a una única categoría; una categoría agrupa varios productos | 1:N |
| Empleado | fk_PERSONA | Empleado hereda la identidad de Persona (generalización) | 1:1 |
| Cliente | fk_PERSONA | Cliente hereda la identidad de Persona (generalización) | 1:1 |
| Venta | fk_EMPLEADO | Toda venta es registrada por un único empleado (cajero) | 1:N |
| Venta | fk_CLIENTE | Toda venta corresponde a un único cliente (obligatorio, incluye "Consumidor Final") | 1:N |
| Suministra | fk_PROVEEDOR + fk_PRODUCTO | Resuelve la relación M:N: un proveedor suministra varios productos, y un producto puede tener varios proveedores | M:N |
| Detalle_Venta | fk_VENTA + fk_PRODUCTO | Resuelve la relación M:N entre Venta y Producto, permitiendo registrar precio y cantidad propios de cada línea (historial de precios, RN.05) | M:N |
| Se_Abona_Con | fk_VENTA + fk_MEDIO_DE_PAGO | Resuelve la relación M:N: una venta puede pagarse con varios métodos, cada uno con su monto imputado (RN.06) | M:N |

## Participación opcional en Categoría y Proveedor

Tanto `pertenece_a` (Producto↔Categoria) como `suministra` (Proveedor↔Producto) 
se modelaron con participación opcional del lado de Categoria y Proveedor 
respectivamente: se permite registrar una categoría o un proveedor en el 
sistema antes de tener productos efectivamente asociados. Del lado de 
Producto, en cambio, ambas relaciones son obligatorias — todo producto 
del catálogo pertenece a una única categoría (RN.02) y debe tener al menos 
un proveedor asignado (RN.04).

## Por qué Cliente es obligatorio en Venta

RN.01 permite vender a clientes no registrados bajo la figura de "Consumidor 
Final", asociándolos a un registro genérico por defecto. Esto significa que, 
aunque en la práctica el comprador no se identifique, el sistema siempre 
asocia la venta a algún registro de Cliente — por eso `fk_CLIENTE` en Venta 
es obligatorio (NOT NULL), sin que esto contradiga la posibilidad de vender 
a un comprador anónimo.

## Por qué Detalle_Venta y Se_Abona_Con no son simples relaciones M:N sin tabla propia

Ambas relaciones M:N necesitan guardar un atributo propio de la combinación 
(precio_unitario_cobrado y cantidad en un caso; monto_imputado en el otro), 
por lo que no alcanza con una relación M:N "vacía" — se requiere una tabla 
intermedia con clave compuesta que sostenga esos datos. Esto es consistente 
con la regla de negocio RN.05, que exige preservar el precio histórico de cada 
línea de venta sin verse afectado por cambios futuros en el precio de catálogo 
del producto.

## Por qué Suministra sí es una relación M:N simple

A diferencia de las dos anteriores, la relación entre Proveedor y Producto no 
requiere ningún atributo propio según las reglas de negocio relevadas — solo 
interesa saber qué proveedores pueden suministrar qué productos. Por eso se 
resuelve con una tabla de clave compuesta sin atributos adicionales.