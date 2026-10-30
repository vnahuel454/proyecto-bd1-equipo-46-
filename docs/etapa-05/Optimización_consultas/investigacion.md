# Informe Técnico: Optimización de Consultas e Índices en SQL Server

## 1. Introducción y Marco Teórico

El objetivo de esta investigación es analizar el comportamiento del motor de almacenamiento de Microsoft SQL Server ante la ejecución de consultas sobre tablas con volumen de datos masivo (100.000 registros), comparando la eficiencia en el consumo de memoria I/O y tiempos de procesamiento mediante el uso de **Índices Agrupados**, **Índices No Agrupados** e **Índices de Cobertura**.

### 1.1. Estructura Física de Almacenamiento
SQL Server organiza la información física en páginas de disco de **8 KB**. Cuando se ejecuta una consulta `SELECT`, el motor debe cargar estas páginas desde el disco rígido/SSD hacia la memoria RAM (*Buffer Pool*). El rendimiento de una base de datos depende directamente de minimizar la cantidad de **lecturas lógicas** (páginas de 8 KB leídas de la RAM).

### 1.2. Tipos de Índices Evaluados

1. **Índice Agrupado (*Clustered Index*):**
   * Define el orden físico en el que se almacenan los datos de la tabla en el disco.
   * Solo puede existir **uno por tabla** (creado automáticamente al definir la Clave Primaria `PRIMARY KEY` en `numero_ticket`).
   * Cuando no existe un índice secundario sobre una columna filtrada (`fecha_hora`), el motor realiza un **`Clustered Index Scan`**, leyendo toda la tabla de principio a fin.

2. **Índice No Agrupado Simple (*Non-Clustered Index*):**
   * Es una estructura en árbol B-Tree independiente que contiene una copia ordenada de la columna indexada (`fecha_hora`) junto con un puntero (*Bookmark* / *Clustered Key*) hacia la tabla principal.
   * **El Punto de Inflexión (*Tipping Point*):** Si la consulta devuelve un volumen considerable de filas y requiere columnas no incluidas en el índice (`total`, `dni_Cliente`), el costo de realizar miles de búsquedas individuales en la tabla base (**`Key Lookups`**) supera el costo de un escaneo completo. En este punto, el Optimizador de Consultas descarta el índice no agrupado simple y vuelve a ejecutar un **`Clustered Index Scan`**.

3. **Índice de Cobertura (*Covering Index with INCLUDE*):**
   * Incluye explícitamente en el nivel hoja del índice las columnas adicionales requeridas por la consulta (`INCLUDE (total, dni_Cliente)`).
   * Permite que la consulta sea respondida al 100% desde la propia estructura del índice mediante un **`Index Seek` puro**, eliminando por completo los `Key Lookups` y reduciendo las lecturas lógicas a su nivel mínimo posible.

---

## 2. Metodología de Pruebas

Se trabajó sobre la tabla real **`VENTA`** de la base de datos `SupermercadoElSol`. Se realizó un poblado de **100.000 registros** distribuidos entre los años 2020 y 2025, garantizando la integridad referencial con los clientes y empleados existentes.

La consulta de prueba seleccionada analiza las ventas del primer trimestre del año 2023:
```sql
SELECT numero_ticket, fecha_hora, total, dni_Cliente 
FROM VENTA 
WHERE fecha_hora BETWEEN '20230101' AND '20230331 23:59:59';
```

Las métricas fueron capturadas mediante las instrucciones T-SQL:
* `SET STATISTICS IO ON;` (para medir Lecturas Lógicas de páginas de 8 KB).
* `SET STATISTICS TIME ON;` (para medir Tiempos de CPU y tiempo transcurrido en milisegundos).
* **Actual Execution Plan** (Ctrl + M en SSMS) para analizar los operadores del motor.

---

## 3. Cuadro Comparativo de Resultados Reales

A continuación se resumen los datos reales obtenidos durante la ejecución en SQL Server Management Studio (SSMS):

| Escenario | Tipo de Estructura / Índice Aplicado | Operación en el Plan de Ejecución | Lecturas Lógicas (Páginas de 8 KB) | Tiempo CPU (ms) | Tiempo Transcurrido (ms) | Impacto / Eficiencia |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Escenario 1** | Sin índice en `fecha_hora` (Solo Clave Primaria) | **Clustered Index Scan** | **811** | 16 ms | 55 ms | **Línea Base** (100% de páginas leídas). |
| **Escenario 2** | Índice No Agrupado Simple (`IX_VENTA_FechaHora`) | **Clustered Index Scan** | **811** | 16 ms | 96 ms | **Tipping Point:** El motor descarta el índice por alto costo de `Key Lookups`. |
| **Escenario 3** | Índice de Cobertura (`IX_VENTA_FechaHora_Cobertura`) | **Index Seek** *(Covering)* | **19** | **0 ms** | 217 ms | **97.6% de reducción en lecturas lógicas** (de 811 a 19 páginas). |

---

## 4. Análisis Técnico de los Resultados

### 4.1. Escenario 1: Recorrido Completo (`Clustered Index Scan`)
En la prueba inicial, al filtrar por `fecha_hora` sin disponer de un índice secundario, SQL Server se vio obligado a realizar un **`Clustered Index Scan`**. Tuvo que examinar **811 páginas de datos** en memoria RAM para extraer las filas correspondientes al trimestre evaluado.

### 4.2. Escenario 2: El Fenómeno del *Tipping Point*
Al crear el índice simple `CREATE NONCLUSTERED INDEX IX_VENTA_FechaHora ON VENTA(fecha_hora);`, se esperaba una mejora. Sin embargo, el plan de ejecución mostró que SQL Server mantuvo el **`Clustered Index Scan`** con **811 lecturas lógicas**. 

**Explicación:** La consulta filtra un rango de 3 meses que abarca miles de ventas. Como el índice no agrupado simple solo contiene la columna `fecha_hora`, para cada fila encontrada SQL Server tendría que realizar un salto (**`Key Lookup`**) a la tabla principal para buscar `total` y `dni_Cliente`. Al calcular que hacer miles de `Key Lookups` aleatorios cuesta más recursos que leer secuencialmente las 811 páginas de la tabla, el Optimizador de Consultas eligió de forma inteligente ignorar el índice no agrupado simple.

### 4.3. Escenario 3: Cobertura Total de la Consulta (`Index Seek`)
Al aplicar el índice de cobertura:
```sql
CREATE NONCLUSTERED INDEX IX_VENTA_FechaHora_Cobertura 
ON VENTA(fecha_hora) 
INCLUDE (total, dni_Cliente);
```
SQL Server cambió su estrategia a un **`Index Seek` puro**. Dado que la clave del índice ordena por `fecha_hora` y las hojas del índice almacenan directamente los campos `total` y `dni_Cliente`, la consulta se resolvió en su totalidad sin acceder a la tabla base. 

Esto redujo las lecturas lógicas de **811 páginas a tan solo 19 páginas**, logrando un ahorro de recursos del **97.6%** y reduciendo el tiempo de CPU a **0 ms**.

