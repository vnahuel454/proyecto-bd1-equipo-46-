1. **¿Qué son las transacciones en SQL?**

Una transacción SQL es una secuencia de una o varias operaciones en la base de datos (como INSERT, UPDATE o DELETE) tratadas como una única unidad de trabajo indivisible. Con las transacciones, o bien se aplican correctamente todos los cambios, o no se aplica ninguno. Esto garantiza que la base de datos permanezca coherente y libre de corrupción.

Por ejemplo, se desea transferir dinero entre dos cuentas bancarias:

1. Descontar 100 \$ de la cuenta A.
2. Añadir 100 \$ a la cuenta B.

Si una operación falla sin una transacción, se corre el riesgo de dejar los datos inconsistentes: dinero descontado pero no abonado. Al agrupar estos pasos en una transacción, nos aseguramos de que ambas operaciones se completen o no se aplique ninguna.

2. **Cómo implementar transacciones en SQL**

Para usar transacciones en SQL, utilizamos comandos como BEGIN, COMMIT y ROLLBACK para gestionarlas de forma eficaz, agrupar operaciones y manejar errores.

**Uso de BEGIN, COMMIT y ROLLBACK**

1. **BEGIN:** marca el inicio de una transacción. Todas las operaciones posteriores formarán parte de ella.
2. **COMMIT**: finaliza la transacción, haciendo permanentes todos los cambios en la base de datos.
3. **ROLLBACK**: deshace todos los cambios realizados durante la transacción, devolviendo la base de datos a su estado anterior en caso de error o fallo.

Este sería un flujo sencillo:

BEGIN TRANSACTION; -- Inicia la transacción

\-- Realizar operaciones en la base de datos

UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;

UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

COMMIT; -- Finalizar la transacción

Si ocurre un error, se puede revertir la transacción:

BEGIN TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;

\-- Simular un error

ROLLBACK; -- Deshacer los cambios

3. **Consejos para una gestión eficaz de transacciones**

Gestionar bien las transacciones es clave para mantener la integridad de la base de datos y que todo fluya sin problemas. Tanto si manejamos actualizaciones financieras como si trabajamos con datos complejos, seguir buenas prácticas nos ahorrará problemas. Aquí algunos consejos para optimizar su uso:

- **Usamos transacciones en operaciones críticas**: agrupamos operaciones que deban completarse juntas o fallar juntas, como actualizaciones financieras o inserciones en varias tablas.
- **Configuramos mecanismos de manejo de errores**: anticipamos posibles fallos y utilizamos ROLLBACK para mantener la integridad de los datos.
- **Prueba de transacciones**: simulamos distintos escenarios para asegurarnos de que la lógica funciona correctamente en todas las condiciones.

Comprender e implementar bien las transacciones refuerza la robustez de la base de datos y nos prepara para afrontar retos más avanzados en SQL.

4. **Mecanismos de Manejo de Errores en SQL**
5. **Bloque TRY … CATCH**

El bloque **TRY...CATCH** en SQL Server funciona como un mecanismo de seguridad y control de errores estructurado.

Hasta ahora, si uno de nuestros scripts fallaba (por ejemplo, una división por cero o una violación de llave foránea), SQL Server mostraba un mensaje rojo y detenía la ejecución.

Pero eso no queda muy profesional. No está bien que dejemos que el código "explote" sin control. Necesitamos **capturar el error, limpiarlo y decidir qué hacer**.

Para ello, T-SQL implementa la estructura TRY...CATCH (muy similar al que usan lenguajes de programación como C#, Java o Python).

En el contexto del script de transacciones para **SupermercadoElSol**, funciona como un **sistema de "todo o nada"** guiado por los siguientes pasos:

**1\. El Bloque BEGIN TRY (La zona de operaciones)**

- **Cómo actúa:** SQL Server intenta ejecutar secuencialmente todas las instrucciones que se encuentran dentro de este bloque (en este caso: insertar la venta, insertar el detalle y descontar el stock).
- **Si todo sale bien:** Si la última línea se ejecuta sin problemas, el motor llega a la instrucción **COMMIT TRANSACTION**. En ese momento, todos los cambios provisionales se graban de forma permanente y definitiva en la base de datos. El bloque CATCH se ignora por completo.

**2\. El Bloque BEGIN CATCH (La red de seguridad)**

- **Cómo actúa:** Si **cualquiera** de las instrucciones dentro del TRY falla (por ejemplo, si intentas registrar una venta con un DNI de cliente que no existe, o un producto inválido), SQL Server **interrumpe de inmediato la ejecución** y salta directo al bloque CATCH, sin importar si quedaban líneas pendientes en el TRY.
- **El ROLLBACK de emergencia:** Dentro del CATCH, la instrucción IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; verifica si hay una transacción abierta y la deshace por completo. Esto borra cualquier rastro de los cambios parciales que se habían hecho en memoria (como cuando el stock o la venta intentaban grabarse a medias), devolviendo la base de datos a su estado original exacto.
- **Diagnóstico:** Además, el CATCH permite capturar detalles técnicos del error (como el mensaje de la Clave Foránea que te apareció antes) para que puedas ver exactamente qué falló.

**Obtener información del error**

Saber que hubo un error está bien, pero también necesitamos **saber qué pasó**. Dentro del bloque CATCH, tenemos acceso a **funciones especiales del sistema que nos dan los detalles** del accidente:

| **Función**         | **Descripción**                                            |
| ------------------- | ---------------------------------------------------------- |
| `ERROR_NUMBER()`    | El código interno del error.                               |
| `ERROR_MESSAGE()`   | El texto descriptivo ("Divide by zero error encountered"). |
| `ERROR_SEVERITY()`  | La gravedad (1-25).                                        |
| `ERROR_LINE()`      | En qué línea de código explotó.                            |
| `ERROR_PROCEDURE()` | En qué procedimiento almacenado ocurrió.                   |

**Consecuencias de la ausencia del bloque TRY CATCH**

Si no utilizamos un bloque **TRY...CATCH** y trabajamos únicamente con BEGIN TRANSACTION, las consecuencias sobre la consistencia de los datos y el comportamiento del código en SQL Server son significativas:

- **Pérdida del Control Automatizado del Deshacimiento (ROLLBACK)**

Sin un bloque CATCH, **SQL Server no ejecuta automáticamente un ROLLBACK** cuando se produce un error en una sentencia individual (como una violación de Clave Foránea o un error de datos), a menos que una configuración especial esté activa.

- **¿Qué sucede por defecto?** Si el primer INSERT (cabecera de la venta) es exitoso y el segundo INSERT (detalle de la venta) falla por un error, SQL Server simplemente cancela esa instrucción específica y **continúa ejecutando las siguientes líneas** (como el UPDATE de stock) o deja la transacción **abierta en memoria (TRANCOUNT > 0)**.
- **Los Escenarios de Riesgo**

**Escenario A: Datos Inconsistentes (Transacciones Parciales)**

Si ocurre un error intermedio pero el script continúa hasta llegar a la instrucción COMMIT TRANSACTION, SQL Server grabará los datos que sí funcionaron.

- **Resultado:** Tendrías una venta registrada en VENTA, pero sin ningún detalle en DETALLE_VENTA y/o con un stock descontado incorrectamente. Se rompe la propiedad de **Atomicidad** ("todo o nada").

**Escenario B: Transacciones Huérfanas y Bloqueos de Tablas**

Si el script se interrumpe debido al error y nunca llega a ejecutarse ni un COMMIT ni un ROLLBACK explícito:

- La transacción permanece **abierta e indefinida** en el servidor.
- La sesión mantiene **bloqueos exclusivos (Locks)** sobre las tablas afectadas (VENTA, PRODUCTO), lo que puede congelar las consultas de otros cajeros o usuarios del sistema que intenten acceder a esas mismas tablas.
- **¿Cómo funcionaría sin TRY...CATCH?**

Para trabajar de manera segura sin TRY...CATCH, estamos obligados a consultar manualmente la variable del sistema **@@ERROR** después de **cada instrucción SQL**, lo cual hace el código verboso y propenso a fallas humanas:

BEGIN TRANSACTION;

\-- 1. Insertar Venta

INSERT INTO VENTA (numero_ticket, fecha_hora, Subtotal, iva, descuento, total, dni_Empleado, dni_Cliente)

VALUES (1014, GETDATE(), 1000.00, 210.00, 0.00, 1210.00, 35111222, 33666777);

IF @@ERROR <> 0

BEGIN

ROLLBACK TRANSACTION;

PRINT 'Error en la venta. Se cancela todo.';

RETURN;

END

\-- 2. Insertar Detalle

INSERT INTO DETALLE_VENTA (numero_ticket, id_producto, Cantidad, precio_unitario_cobrado)

VALUES (1014, 999, 1, 1000.00); -- Error por FK

IF @@ERROR <> 0

BEGIN

ROLLBACK TRANSACTION; -- Hay que acordarse de ponerlo manualmente

PRINT 'Error en el detalle. Se deshace la venta.';

RETURN;

END

COMMIT TRANSACTION;

- **La excepción: Opción SET XACT_ABORT ON**

Si se opta no usar TRY...CATCH, la única forma segura de automatizar el deshacimiento es activando la directiva de sesión:

SQL

```
SET XACT_ABORT ON; -- Fuerza el ROLLBACK automático ante cualquier error
BEGIN TRANSACTION;
    INSERT INTO VENTA ... ;
    INSERT INTO DETALLE_VENTA ... ; -- Si falla aquí, aborta y deshace todo de inmediato
    UPDATE PRODUCTO ... ;
COMMIT TRANSACTION;
```

**Resumen**

| **Enfoque**               | **Control de Errores**                 | **Riesgo de Datos Inconsistentes**              | **Manejo de Transacciones**                         |
| ------------------------- | -------------------------------------- | ----------------------------------------------- | --------------------------------------------------- |
| **Solo BEGIN / ROLLBACK** | Manual (evaluando @@ERROR paso a paso) | **Alto** (si se olvida validar una sentencia)   | Quedan transacciones abiertas y bloqueos en tablas. |
| **Con TRY...CATCH**       | **Automático y Centralizado**          | **Nulo** (captura cualquier fallo en el bloque) | Garantiza ROLLBACK inmediato y limpia recursos.     |

2. **Otras Formas de Manejo de Errores**

Aparte de los bloques TRY...CATCH, SQL Server (T-SQL) ofrece otros mecanismos y directivas históricas o complementarias para el manejo y control de errores en las transacciones.

A continuación, las alternativas más importantes:

**1\. La directiva SET XACT_ABORT ON**

Es la alternativa más recomendada si quieres evitar el uso de bloques TRY...CATCH pero necesitas seguridad transaccional.

- **Cómo funciona:** Por defecto está en OFF. Al activarla (SET XACT_ABORT ON), si se produce un error en tiempo de ejecución (como una violación de llave foránea o un desbordamiento), SQL Server **cancela automáticamente la transacción en curso y ejecuta un ROLLBACK inmediato**, deteniendo la ejecución del script.
- **Ventaja:** Automatiza el comportamiento de seguridad sin necesidad de escribir estructuras complejas de captura de errores.

**2\. Evaluación manual de la variable del sistema @@ERROR**

Es el método tradicional (más antiguo) que se utilizaba antes de que existieran los bloques TRY...CATCH.

- **Cómo funciona:** La variable global @@ERROR almacena el número de error de la última instrucción T-SQL ejecutada. Si la instrucción fue exitosa, vale 0.
- **Implementación:** Obliga al programador a evaluar el estado de @@ERROR renglón por renglón de manera secuencial
- **Desventaja:** El código se vuelve muy extenso, repetitivo y propenso a errores humanos si se olvida validar alguna línea.

**3\. Uso de THROW y RAISERROR**

Estos comandos no capturan errores, sino que los generan y los lanzan de manera explícita dentro de la lógica del negocio.

Cómo funcionan: Permiten validar reglas complejas personalizadas (por ejemplo, verificar si el stock es menor al requerido) y lanzar un error controlado que rompa la ejecución normal.

Ejemplo:

```
IF (SELECT stock_actual FROM PRODUCTO WHERE id_producto = 1) < 3
    THROW 50001, 'Stock insuficiente para procesar la venta.', 1;
```

Al dispararse un THROW, si estmos dentro de un bloque TRY o con XACT_ABORT ON, la transacción se abortará automáticamente.

El comando **RAISERROR** en SQL Server se utiliza para generar y lanzar un mensaje de error personalizado de manera explícita. Es muy útil cuando queremos validar reglas de negocio en el código (por ejemplo, verificar si hay stock suficiente) y forzar a que la transacción falle para que salte directo al bloque CATCH y ejecute el ROLLBACK.

- **Sintaxis Básica**

La estructura general de RAISERROR es la siguiente:

```
RAISERROR ('Mensaje de error', NivelDeGravedad, Estado);
```

- **¿Qué significan sus parámetros principales?**

1. **'Mensaje de error'**: El texto descriptivo que se quiere mostrar. Puede incluir comodines de formato similares a C (como %s para texto o %d para números).
2. **Nivel de Gravedad (_Severity_)**: Un número del 0 al 25.

Los niveles del **11 al 18** son los más utilizados para errores controlados por el usuario, ya que son lo suficientemente graves como para interrumpir la ejecución normal y **ser capturados por un bloque CATCH**.

3. **Estado (_State_)**: Un número entero del 1 al 127 que indica el estado interno de la llamada (suele utilizarse 1 por defecto). Ayuda a identificar en qué parte exacta del código se originó el error si hay múltiples llamadas al mismo mensaje.

- **Ejemplo Práctico Aplicado a la Venta**

Imaginemos que antes de registrar una venta en **SupermercadoElSol**, queremos validar mediante una regla de negocio que el stock del producto sea mayor o igual al que el cliente quiere comprar. Si no hay stock, lanzamos un error con RAISERROR.

USE SupermercadoElSol;

GO

BEGIN TRANSACTION;

BEGIN TRY

\-- Declaramos una variable simulando la cantidad que se quiere llevar

DECLARE @CantidadAComprar INT = 100; -- Una cantidad exagerada para forzar el error

DECLARE @StockActual INT;

\-- Consultamos el stock actual del producto con ID 1

SELECT @StockActual = stock_actual

FROM PRODUCTO

WHERE id_producto = 1;

\-- REGLA DE NEGOCIO: Validar stock insuficiente

IF @StockActual < @CantidadAComprar

BEGIN

\-- Lanzamos un error personalizado (Severidad 16 para que active el CATCH)

RAISERROR('Stock insuficiente. Stock disponible: %d, cantidad solicitada: %d', 16, 1, @StockActual, @CantidadAComprar);

END

\-- Si hubiera stock, aquí continuarían los INSERT de la venta...

\-- INSERT INTO VENTA ...

COMMIT TRANSACTION;

PRINT '--- TRANSACCIÓN EXITOSA ---';

END TRY

BEGIN CATCH

\-- Si ocurrió el RAISERROR u otro error, se revierte todo

IF @@TRANCOUNT > 0

ROLLBACK TRANSACTION;

PRINT '--- ERROR CAPTURADO ---';

\-- Mostramos los datos del error estructurados

SELECT

ERROR_NUMBER() AS NumeroError,

ERROR_MESSAGE() AS Mensaje,

ERROR_LINE() AS Linea;

END CATCH;

GO

- **¿Qué sucede al ejecutar este código?**

1. El sistema evalúa que el stock (50) es menor que la cantidad a comprar (100).
2. Se ejecuta el RAISERROR con **severidad 16**.
3. SQL Server interrumpe de inmediato el flujo del bloque TRY y salta al bloque CATCH.
4. El bloque CATCH ejecuta el ROLLBACK y muestra en la grilla de resultados el mensaje personalizado que definiste: _"Stock insuficiente. Stock disponible: 50, cantidad solicitada: 100"_.