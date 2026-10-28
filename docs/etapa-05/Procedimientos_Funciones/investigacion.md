# Marco Teórico: Procedimientos y Funciones Almacenadas en T-SQL

## 1. Marco Teórico y Objetivos

En el desarrollo de sistemas gestores de bases de datos relacionales (SGBD) para entornos empresariales —como Microsoft SQL Server Express—, la separación de responsabilidades y la preservación de la integridad de los datos constituyen pilares fundamentales de la ingeniería de software. Tradicionalmente, las aplicaciones interactúan con la base de datos mediante sentencias SQL ad-hoc enviadas desde el lenguaje cliente. Sin embargo, a medida que la complejidad del dominio de negocio se incrementa, delegar la lógica comercial exclusivamente a la capa de aplicación introduce riesgos de inconsistencia, duplicación de código y cuellos de botella en la red.

La programación procedimental almacenada en el servidor de base de datos (mediante T-SQL) aborda estas limitaciones al permitir encapsular bloques de instrucciones, algoritmos y reglas de negocio directamente en el motor de datos. 

El presente documento de investigación constituye el marco teórico del **Tema 1 de la Etapa V (Implementación de Temas Técnicos)** para el sistema de gestión comercial del **Supermercado El Sol (Grupo 46)**. El objetivo principal es analizar en profundidad las definiciones, características internas, clasificaciones, diferencias operativas y ventajas arquitectónicas que ofrecen los **Procedimientos Almacenados (*Stored Procedures*)** y las **Funciones Almacenadas (*User-Defined Functions - UDF*)**, fundamentando su aplicación práctica dentro del modelo relacional implementado.

---

## 2. Funciones Almacenadas (User-Defined Functions - UDF)

### 2.1. Definición Técnica
Una **Función Almacenada por el Usuario (UDF)** en T-SQL es una rutina programable guardada en la base de datos que acepta parámetros de entrada, ejecuta una secuencia de operaciones lógicas o de cálculo, y **retorna obligatoriamente un valor único o un conjunto de datos estructurado en forma de tabla**.

Las UDFs están diseñadas para comportarse de forma análoga a las funciones matemáticas o a las funciones escalares nativas del lenguaje (como `ROUND`, `YEAR`, `UPPER` o `COALESCE`). Por este motivo, su característica distintiva principal es que **pueden ser invocadas directamente dentro de expresiones SQL**, incluyendo cláusulas `SELECT`, `WHERE`, `HAVING`, `GROUP BY` y listas de proyección.

### 2.2. Clasificación en SQL Server
En T-SQL, las funciones definidas por el usuario se dividen en tres categorías principales según la naturaleza de la estructura que retornan:

1. **Funciones Escalares (`Scalar Functions`):**
   * **Mecanismo:** Retornan un único valor atómico (de tipos como `INT`, `DECIMAL`, `VARCHAR`, `DATE`, etc.) definido mediante la cláusula `RETURNS <tipo_dato>`.
   * **Cuerpo:** Contienen un bloque `BEGIN ... END` donde se declaran variables locales, se ejecutan cálculos o consultas, y finalizan estrictamente con la sentencia `RETURN <expresion>`.
   * **Uso:** Se emplean en cualquier lugar donde se admita una expresión de columna (ejemplo: transformar un valor, calcular un porcentaje o evaluar una regla condicional por cada fila).

2. **Funciones de Tabla en Línea (`Inline Table-Valued Functions - ITVF`):**
   * **Mecanismo:** Retornan el resultado de una única sentencia `SELECT` en forma de tabla virtual (`RETURNS TABLE`).
   * **Cuerpo:** No utilizan bloque `BEGIN ... END`. El cuerpo consiste exclusivamente en la sentencia `RETURN (SELECT ...)`.
   * **Uso:** Actúan como vistas parametrizadas, ofreciendo un excelente rendimiento gracias a que el optimizador de consultas de SQL Server puede integrar su definición directamente en el plan de ejecución global (*query inlining*).

3. **Funciones de Tabla Multisentencia (`Multi-Statement Table-Valued Functions - MSTVF`):**
   * **Mecanismo:** Retornan una tabla cuya estructura se declara explícitamente en el encabezado (`RETURNS @TablaResultados TABLE (...)`).
   * **Cuerpo:** Utilizan un bloque `BEGIN ... END` que permite ejecutar múltiples instrucciones complejas, poblando iterativa o condicionalmente la tabla temporal `@TablaResultados`, finalizando con un comando `RETURN` ciego.

### 2.3. Restricciones Operativas de las UDFs
Para garantizar la predictibilidad y consistencia en la evaluación de consultas, el motor de SQL Server impone limitaciones estrictas a las funciones almacenadas:
* **Prohibición de Modificaciones de Estado DML:** Una función no puede ejecutar sentencias `INSERT`, `UPDATE` o `DELETE` sobre tablas permanentes de la base de datos (solo puede manipular variables de tabla locales).
* **Prohibición de Gestión Transaccional (TCL):** No se permite el uso de `BEGIN TRANSACTION`, `COMMIT` ni `ROLLBACK` dentro de una UDF.
* **Incompatibilidad con Operaciones de Efectos Secundarios:** No pueden alterar la configuración de la sesión ni invocar procedimientos almacenados que realicen modificaciones.
* **Determinismo:** Determinadas funciones no deterministas nativas (como `NEWID()`) no pueden ser utilizadas dentro de UDFs escalares convencionales.

---

## 3. Procedimientos Almacenados (Stored Procedures)

### 3.1. Definición Técnica
Un **Procedimiento Almacenado (*Stored Procedure*)** es un programa ejecutable compuesto por una o más sentencias T-SQL almacenadas en forma compilada dentro del catálogo de la base de datos. A diferencia de las funciones, los procedimientos están concebidos para **ejecutar flujos de trabajo completos, tareas administrativas y transacciones comerciales complejas** que alteran el estado del sistema.

Un procedimiento almacenado se invoca de manera independiente mediante el comando `EXEC` o `EXECUTE`. No está sujeto a las restricciones de las UDFs: puede aceptar múltiples parámetros de entrada (`IN`) y de salida (`OUTPUT`), ejecutar cualquier comando DDL (`CREATE`, `ALTER`), DML (`INSERT`, `UPDATE`, `DELETE`) o TCL (`BEGIN TRAN`, `COMMIT`), e invocar a otros procedimientos o funciones.

### 3.2. Características Clave
* **Soporte Transaccional Completo:** Constituyen el entorno natural para implementar transacciones `ACID` (Atomicidad, Consistencia, Aislamiento y Durabilidad), garantizando que operaciones compuestas por múltiples pasos (como registrar un ticket, insertar sus detalles y actualizar inventarios) se confirmen o reviertan de forma atómica.
* **Control de Excepciones:** Incorporan estructuras avanzadas de manejo de errores en T-SQL mediante bloques `BEGIN TRY ... END TRY` y `BEGIN CATCH ... END CATCH`, permitiendo capturar fallos de ejecución, registrar auditorías de error y ejecutar `ROLLBACK` de manera segura.
* **Retorno de Múltiples Resultados:** Pueden devolver cero, uno o múltiples conjuntos de resultados (*result sets*) derivados de sentencias `SELECT` internas, además de retornar un código numérico de estado mediante la sentencia `RETURN <entero>` (por convención, `0` indica éxito y valores distintos de cero indican códigos de error).
* **Parámetros OUTPUT:** Permiten devolver valores calculados directamente a las variables del entorno llamante sin necesidad de generar un *result set*.

---

## 4. Cuadro Comparativo: Funciones vs. Procedimientos Almacenados

La siguiente tabla sintetiza las diferencias estructurales y operativas fundamentales entre ambos objetos programables en T-SQL:

| Criterio de Comparación | Función Almacenada (UDF) | Procedimiento Almacenado (Stored Procedure) |
| :--- | :--- | :--- |
| **Propósito Principal** | Calcular valores o transformar datos para usarse dentro de consultas. | Ejecutar lógica de negocio, flujos de trabajo y modificaciones de estado. |
| **Valor de Retorno** | **Obligatorio.** Retorna un valor escalar o una tabla virtual. | **Opcional.** Puede no retornar nada, retornar parámetros `OUTPUT` o devolver múltiples *result sets*. |
| **Invocación Sintáctica** | Integrada dentro de sentencias SQL (`SELECT fn(...)`, `WHERE fn(...) = x`). | Independiente mediante la sentencia `EXEC nombre_procedimiento` o `CALL`. |
| **Modificación de Datos (DML)** | **No permitida.** No puede modificar tablas permanentes de la base de datos. | **Permitida.** Puede realizar `INSERT`, `UPDATE`, `DELETE` y DDL sobre cualquier objeto. |
| **Manejo de Transacciones (TCL)**| **Prohibido.** No admite `BEGIN TRAN`, `COMMIT` ni `ROLLBACK`. | **Permitido y recomendado.** Permite control completo de transacciones `ACID`. |
| **Manejo de Errores** | Limitado. No admite bloques `TRY ... CATCH`. | Completo. Soporta estructuración `TRY ... CATCH` y re-emisión de errores con `RAISERROR` / `THROW`. |
| **Uso de Parámetros** | Solo parámetros de entrada (`IN`). | Parámetros de entrada (`IN`) y de salida (`OUTPUT`). |
| **Anidamiento y Llamadas** | Puede invocar otras UDFs, pero **no** procedimientos almacenados. | Puede invocar otras UDFs y otros procedimientos almacenados. |

---

## 5. Ventajas Arquitectónicas en el Sistema de Ventas

La implementación de procedimientos y funciones almacenadas en el sistema del **Supermercado El Sol** proporciona beneficios estratégicos decisivos para la arquitectura de la base de datos:

### 5.1. Centralización y Consistencia de Reglas de Negocio
En un supermercado mediano, las reglas comerciales —como la escala de descuentos acumulados por compras históricas de clientes frecuentes (**RN.01**) o la actualización automática del stock de productos (**RN.03**)— deben aplicarse con absoluta consistencia. Al encapsular estas reglas en el motor de base de datos, se garantiza que cualquier punto de acceso (cajas registradoras, aplicaciones web de administración o reportes gerenciales) aplique exactamente la misma lógica sin riesgo de discrepancias.

### 5.2. Mantenibilidad y Desacoplamiento (Capa de Abstracción)
Si la gerencia del supermercado decide modificar la escala de fidelización de clientes (por ejemplo, cambiando los umbrales de compra acumulada de \$500.000 a \$600.000), solo se requiere actualizar la definición interna de la función `fn_CalcularDescuentoCliente` mediante `ALTER FUNCTION`. La capa de aplicación cliente no requiere ser recompilada ni redistribuida, logrando un desacoplamiento efectivo entre la interfaz de usuario y la persistencia de datos.

### 5.3. Rendimiento Optimizado y Reutilización de Planes de Ejecución
Cuando se ejecuta un procedimiento almacenado por primera vez, el optimizador de SQL Server analiza las sentencias internas, genera un plan de ejecución óptimo y lo almacena en la memoria caché (*procedure cache*). En las ejecuciones subsecuentes, el motor reutiliza este plan compilado de forma inmediata, evitando la sobrecarga de análisis sintáctico (*parsing*) y compilación que requieren las consultas SQL dinámicas ad-hoc.

### 5.4. Reducción Significativa del Tráfico de Red
Registrar una venta en el supermercado requiere múltiples consultas: verificar stock, obtener precio vigente, calcular descuento, insertar encabezado de venta, insertar ítems de detalle y descontar inventario. Si la aplicación enviara cada sentencia individualmente por la red, se generarían múltiples latencias de ida y vuelta (*round-trips*). Con un procedimiento almacenado, la aplicación envía un único comando `EXEC sp_RegistrarVentaCompleta ...` enviando únicamente los parámetros. Toda la secuencia se ejecuta localmente en la memoria del servidor a velocidad de bus interno.

### 5.5. Seguridad y Principio de Mínimo Privilegio
Los procedimientos almacenados actúan como una capa de seguridad y abstracción. Mediante la concesión de permisos de ejecución (`GRANT EXECUTE ON dbo.sp_RegistrarVentaCompleta TO Rol_Cajero`), los cajeros pueden registrar ventas sin necesidad de poseer permisos directos de inserción o modificación (`INSERT` / `UPDATE`) sobre las tablas base como `producto`, `venta` o `detalle_venta`. Esto previene modificaciones no autorizadas o maliciosas fuera de los flujos validados.

---

## 6. Fundamentación del Caso de Uso Aplicado (Supermercado El Sol)

En la solución técnica desarrollada para el Grupo 46, se han seleccionado dos objetos programables que resuelven requerimientos concretos del dominio comercial:

### 6.1. Función Escalar `fn_CalcularDescuentoCliente`
* **Necesidad de Negocio:** El sistema del supermercado debe incentivar la fidelidad calculando en tiempo real el porcentaje de descuento que le corresponde a un cliente en función de su historial acumulado de compras.
* **Justificación de Elección (UDF Escalar):** Dado que el descuento debe consultarse o proyectarse dentro de las consultas de facturación y reportes de clientes (`SELECT nombre, dbo.fn_CalcularDescuentoCliente(id_cliente) ...`), una función escalar es la estructura ideal, ya que permite integrarse directamente dentro de cualquier expresión SQL sin alterar el estado de la base de datos.

### 6.2. Procedimiento Almacenado `sp_RegistrarVentaCompleta`
* **Necesidad de Negocio:** El proceso de cobro en línea de cajas requiere registrar una venta garantizando que el encabezado del ticket, el detalle de productos con precio histórico cobrado (**RN.05**), la aplicación del descuento del cliente y el descuento de stock (**RN.03**) se ejecuten como una operación integrada.
* **Justificación de Elección (Stored Procedure):** Este proceso requiere coordinar escrituras DML en múltiples tablas (`venta`, `detalle_venta`, `producto`), invocar a la función de descuentos y manejar lógica condicional. Debido a que las UDFs no pueden modificar datos permanentes, un procedimiento almacenado es el único componente capaz de orquestar este flujo transaccional seguro y centralizado.
