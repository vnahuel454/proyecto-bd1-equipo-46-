Este documento detalla el proceso de transformación del modelo lógico relacional a su implementación física en el Sistema Gestor de Bases de Datos (SGBD) Microsoft SQL Server Express y SQLfiddle server online, 
asegurando la integridad, consistencia y correcto rendimiento del sistema. 

1. Mapeo y Transformación de Entidades a Tablas el modelo lógico se trasladó al SGBD siguiendo reglas estrictas de derivación relacional:

Entidades Fuertes: Se convirtieron directamente en tablas independientes (PERSONA, CATEGORIA, MEDIO_DE_PAGO). Sus atributos identificadores pasaron a ser Claves Primarias (PRIMARY KEY). Las tablas EMPLEADO y CLIENTE heredan el identificador DNI de PERSONA. Este campo actúa simultáneamente como Clave Primaria (PK) y Clave Foránea (FK) apuntando a PERSONA. Esto garantiza la integridad referencial y evita la duplicación de datos comunes. Relaciones Muchos a Muchos (N:M): Las relaciones complejas se rompieron mediante tablas intermedias/asociativas: SUMINISTRA: Une PROVEEDOR y PRODUCTO utilizando una clave primaria compuesta por las foráneas cuit e id_producto. SE_ABONA_CON: Vincula VENTA con MEDIO_DE_PAGO mediante numero_ticket e id_medio_de_pago.  Entidades Débiles por Asociación: La tabla DETALLE_VENTA se implementó dependiendo estrictamente de VENTA (numero_ticket) y PRODUCTO (id_producto),  conformando una clave primaria compuesta para identificar cada línea de la venta

2. Estrategia y Orden de Ejecución de los Scripts (DDL)
Para evitar errores de restricciones de clave foránea (FOREIGN KEY) durante la creación de la base de datos, los scripts se organizaron en niveles jerárquicos estrictos dentro del archivo crear_bd.sql:
 Nivel 1 (Tablas Base sin dependencias): PERSONA, CATEGORIA, MEDIO_DE_PAGO.
 Nivel 2 (Dependencia directa de Nivel 1): PROVEEDOR (depende de Persona), EMPLEADO (depende de Persona), CLIENTE (depende de Persona), PRODUCTO (depende de Categoría).
 Nivel 3 (Dependencia de Nivel 1 y 2): VENTA (depende de Cliente y Empleado), SUMINISTRA (depende de Proveedor y Producto).
 Nivel 4 (Dependencias finales): DETALLE_VENTA (depende de Venta y Producto), SE_ABONA_CON (depende de Venta y Medio de Pago).

3. Entorno de Pruebas y Validación
• Motor de Base de Datos: Microsoft SQL Server Express, utilizando SQL Server Management Studio (SSMS) para la ejecución local.
• Validación Online: Se empleó SQLFiddle configurando el entorno en el motor MS SQL Server para validar la portabilidad y la sintaxis estándar de los scripts de creación (DDL) y de inserción de datos de prueba (DML).

 
