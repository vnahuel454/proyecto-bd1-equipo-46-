# Seguridad y Control de Acceso en SQL Server Express

## Definición y objetivos

La seguridad en una base de datos relacional establece quién puede conectarse a la instancia y qué operaciones concretas tiene autorizadas sobre cada tabla o columna. En lugar de permitir un acceso abierto a la estructura completa, el diseño se apoya en dos conceptos centrales: el principio de menor privilegio y la defensa en profundidad.

El principio de menor privilegio plantea que cada usuario o proceso debe contar únicamente con las autorizaciones indispensables para su función operativa. Por ejemplo, una terminal de cobro necesita consultar precios y asentar comprobantes, pero no tiene motivos para alterar el catálogo de productos ni eliminar registros históricos. Por su parte, la defensa en profundidad busca que las restricciones críticas queden fijadas en el propio motor de base de datos. De esta manera, si la aplicación de cajas presenta fallas o es vulnerada, el motor sigue actuando como una barrera independiente.

En SQL Server Express, esta arquitectura se divide en dos niveles complementarios. A nivel de instancia se gestiona la autenticación mediante inicios de sesión (Logins), que pueden basarse en cuentas integradas del sistema operativo o en credenciales propias de SQL Server con contraseña. A nivel de base de datos se maneja la autorización mapeando cada inicio de sesión a un usuario específico dentro de `SupermercadoElSol`. Para evitar la asignación desordenada de permisos cuenta por cuenta, los usuarios se agrupan en roles de base de datos que representan funciones operativas del negocio.

---

## Ventajas y aplicaciones frente a controles en la aplicación

Delegar la seguridad únicamente a las interfaces de usuario o al código de una aplicación cliente suele ser insuficiente. Los usuarios con conocimientos técnicos pueden sortear validaciones de pantalla mediante herramientas externas como Excel, entornos de consulta o scripts. Definir los privilegios en el motor garantiza que las reglas de acceso se cumplan sin importar desde qué software se realice la conexión.

Un punto clave de este enfoque es la contención de ataques por inyección SQL. Esta vulnerabilidad ocurre cuando se concatenan datos sin sanear en consultas dinámicas. Si la conexión de la aplicación corre con privilegios elevados de administrador (`sysadmin` o `db_owner`), una sentencia inyectada puede vaciar tablas completas o alterar balances contables. En cambio, si la terminal opera con una cuenta restringida como `rol_cajero`, cualquier intento de ejecutar sentencias no autorizadas (como `DROP TABLE` o `DELETE FROM VENTA`) es interceptado y cancelado por el motor mediante el error `Msg 229`, limitando el daño en la capa de datos.

La administración mediante roles también simplifica el mantenimiento cotidiano. Los permisos se otorgan a los roles del supermercado y no a las personas físicas. Cuando ingresa un nuevo cajero o se traslada a un empleado de sector, basta con modificar su membresía en el rol correspondiente, sin necesidad de reconfigurar la base de datos tabla por tabla. Además, SQL Server implementa una jerarquía estricta donde una denegación explícita (`DENY`) prevalece siempre sobre cualquier permiso concedido (`GRANT`), garantizando que los bloqueos sobre operaciones sensibles se mantengan firmes.

---

## Implementación técnica en SQL Server Express

El motor relacional de SQL Server Express cuenta con soporte completo para la administración de seguridad mediante Transact-SQL. La configuración se implementa en pasos sucesivos que abarcan la instancia, la base de datos y los objetos de negocio.

Para habilitar el acceso al servidor se crean los inicios de sesión en la base `master`, aplicando políticas de complejidad de contraseñas:

```sql
CREATE LOGIN login_cajero_pos 
    WITH PASSWORD = 'CajeroPassword#2026', 
    CHECK_POLICY = ON;
```

Dentro de la base `SupermercadoElSol`, cada inicio de sesión se asocia a un usuario interno y se incorporan los roles temáticos del negocio:

```sql
USE SupermercadoElSol;
CREATE USER usr_cajero FOR LOGIN login_cajero_pos;

CREATE ROLE rol_cajero;
ALTER ROLE rol_cajero ADD MEMBER usr_cajero;
```

El control granular se aplica mediante las sentencias `GRANT` y `DENY`. En SQL Server es posible restringir acciones no solo a tablas completas, sino también a columnas específicas. Esto resulta útil para perfiles como el de depósito, donde se permite modificar las cantidades de stock pero se bloquea la columna de precios para evitar cambios comerciales no autorizados:

```sql
GRANT UPDATE (stock_actual, stock_minimo) ON dbo.PRODUCTO TO rol_deposito;
DENY UPDATE (precio_actual) ON dbo.PRODUCTO TO rol_deposito;
```

Para comprobar el comportamiento del esquema sin necesidad de cerrar la sesión de administración en SQL Server Management Studio, se utiliza la suplantación de contexto mediante `EXECUTE AS USER` y su posterior restablecimiento con `REVERT`. Esta instrucción permite ejecutar consultas asumiendo temporalmente la identidad de cualquier usuario creado.

---

## Caso concreto aplicado al Supermercado "El Sol"

En el esquema comercial del supermercado se identificaron tres perfiles con responsabilidades operativas diferenciadas:

```text
SupermercadoElSol
├── Rol Cajero (usr_cajero)
│   ├── Lectura: PRODUCTO, CATEGORIA, MEDIO_DE_PAGO, CLIENTE, PERSONA, EMPLEADO
│   ├── Inserción: VENTA, DETALLE_VENTA, SE_ABONA_CON, CLIENTE, PERSONA
│   └── Restricciones: DENY UPDATE y DELETE en ventas y productos; sin acceso a proveedores
│
├── Rol Depósito (usr_deposito)
│   ├── Lectura: PRODUCTO, CATEGORIA, PROVEEDOR, SUMINISTRA
│   ├── Modificación: PRODUCTO (únicamente columnas de stock)
│   └── Restricciones: DENY UPDATE en precio_actual; bloqueo total a facturación
│
└── Rol Auditor (usr_auditor)
    ├── Lectura: Acceso de consulta general sobre todas las tablas
    └── Restricciones: DENY INSERT, UPDATE y DELETE en todo el sistema
```

El rol de cajas cubre las necesidades de facturación diaria. El cajero necesita consultar códigos de barra y precios para cobrar, dar de alta clientes frecuentes si no están empadronados y generar los comprobantes con sus renglones y medios de pago. Sin embargo, para evitar fraudes internos o desarreglos en el arqueo, tiene terminantemente prohibido alterar el precio comercial de los productos o modificar y borrar tickets ya emitidos. Esto asegura el cumplimiento de la regla de precios históricos cobrados.

El personal de depósito se enfoca en el abastecimiento y la recepción de mercadería de proveedores. Requiere actualizar las existencias mínimas y actuales cuando ingresan productos, pero no debe tener intervención sobre los precios de góndola ni visibilidad sobre la facturación, los márgenes de ganancia o los medios de pago de los clientes. Por esta razón, se le aplica un bloqueo de lectura sobre las tablas contables.

El perfil auditor está destinado a supervisión contable y gerencial. Cuenta con acceso de lectura a todas las tablas del supermercado para analizar rendiciones de caja, ventas por período y movimientos de stock, pero carece de permisos de escritura para asegurar que los informes reflejen datos inalterados.

---

## Demostración práctica y resultados obtenidos

Las sentencias completas de creación de cuentas, asignación de permisos y pruebas se encuentran en el archivo `scripts.sql`. A continuación se resumen los casos evaluados en SQL Server Management Studio junto con las evidencias capturadas.

### Operaciones del rol cajero

En la primera prueba se verificó la operativa regular de cajas. Bajo el contexto de `usr_cajero`, se ejecutó una consulta sobre los productos disponibles y se registró el ticket de prueba número 9901, incluyendo su detalle de artículos y el medio de pago imputado. Las inserciones se completaron de manera correcta, confirmando que el cajero cuenta con los permisos necesarios para facturar (`evidencias/01_cajero_venta_ok.png`).

En la segunda prueba se evaluó el intento de modificar ilícitamente el precio actual de un producto en la tabla `PRODUCTO`. El motor bloqueó la sentencia de forma inmediata, emitiendo el mensaje de error `Msg 229 (The UPDATE permission was denied on the object 'PRODUCTO')`, lo que valida la protección sobre los precios comerciales (`evidencias/02_cajero_bloqueo_precio.png`).

En la tercera prueba se simuló un intento de eliminar un comprobante emitido (`DELETE FROM dbo.VENTA WHERE numero_ticket = 1001`) para comprobar si un cajero podía borrar registros para encubrir faltantes. La operación fue rechazada por el motor con error `Msg 229`, confirmando la inmutabilidad de la facturación (`evidencias/03_cajero_bloqueo_delete_venta.png`).

### Operaciones del rol depósito

Para el personal de depósito se probó la actualización de stock tras la recepción de mercadería de proveedores. Bajo el usuario `usr_deposito`, se ejecutó un incremento de 50 unidades sobre el producto de fideos guiseros. La actualización afectó una fila y reflejó el nuevo valor de stock actual sin inconvenientes (`evidencias/04_deposito_stock_ok.png`).

A continuación se intentó consultar la recaudación del supermercado mediante una consulta `SELECT` sobre la tabla `VENTA`. Al poseer una denegación explícita, SQL Server rechazó el acceso arrojando el error `Msg 229`, manteniendo aislada la información financiera (`evidencias/05_deposito_bloqueo_venta.png`).

### Operaciones del rol auditor

En la verificación del perfil de auditoría se asumió la identidad de `usr_auditor` para consultar el comprobante 1001 vinculando el encabezado, el detalle de artículos y los nombres de productos. La consulta se ejecutó de forma fluida, permitiendo la fiscalización de los importes y cantidades cobradas (`evidencias/06_auditor_consulta_ok.png`).

Por último, se intentó alterar el importe total de dicha venta mediante un `UPDATE`. El motor impidió la modificación mediante el error `Msg 229`, garantizando que la cuenta auditora opere estrictamente bajo modalidad de solo lectura (`evidencias/07_auditor_bloqueo_update.png`).
