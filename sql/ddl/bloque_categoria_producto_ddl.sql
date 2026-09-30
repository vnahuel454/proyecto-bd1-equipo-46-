-- =========================================
-- Bloque: Categoria y Producto
-- Luz Espíndola - Equipo 46
-- =========================================
use [supermercadoElSol-Prueba]
go

-- Categoría del producto (ej. Lácteos, Almacén, Bebidas)
-- No tiene FK: es una tabla base, no depende de ninguna otra.
CREATE TABLE CATEGORIA (
    id_categoria    INT NOT NULL,              -- Clave interna autogenerada
    nombre          VARCHAR(50) NOT NULL,      

    CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria)
);


-- Producto del catálogo del supermercado.
-- Depende de Categoria (relación 1:N, todo producto pertenece a una única categoría).
CREATE TABLE PRODUCTO (
    id_producto     INT NOT NULL,              -- Clave interna autogenerada
    codigo_barra    VARCHAR(20) NOT NULL,      -- RN.02: identificador único del producto en el mundo real
    marca           VARCHAR(50) NOT NULL,
    detalle         VARCHAR(200) NOT NULL,     -- Descripción extendida del producto
    precio_actual   DECIMAL(10,2) NOT NULL,
    stock_actual    INT NOT NULL,
    stock_minimo    INT NOT NULL,              -- Umbral para alertas de reposición (RN.03)
    id_categoria    INT NOT NULL,              -- FK obligatoria: RN.02 exige categoría única por producto

    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),

    -- Aunque id_producto es la clave interna, codigo_barra debe ser único
    -- porque es el identificador real del producto según RN.02.
    CONSTRAINT UQ_Producto_CodigoBarra UNIQUE (codigo_barra),

    -- Ningún precio ni stock puede ser negativo.
    CONSTRAINT CK_Producto_PrecioPositivo CHECK (precio_actual > 0),
    CONSTRAINT CK_Producto_StockActualPositivo CHECK (stock_actual >= 0),
    CONSTRAINT CK_Producto_StockMinimoPositivo CHECK (stock_minimo >= 0),

    -- No se puede borrar una categoría mientras tenga productos asociados.
    -- Si cambia el id_categoria, se actualiza en cascada en Producto.
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) 
        REFERENCES CATEGORIA(id_categoria)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
