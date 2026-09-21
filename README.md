# Sistema de Gestión Comercial - Supermercado "El Sol"
### Proyecto Estudio | Bases de Datos I - Equipo 46
#### Licenciatura en Sistemas de Información - FaCENA (UNNE)

![Universidad](https://img.shields.io/badge/UNNE-FaCENA-00529B?style=flat-square)
![Carrera](https://img.shields.io/badge/Carrera-Lic._en_Sistemas_de_Información-blue?style=flat-square)
![Cátedra](https://img.shields.io/badge/Bases%20de%20Datos%20I-2026-blue?style=flat-square)
![Motor](https://img.shields.io/badge/SGBD-Microsoft%20SQL%20Server-CC292B?style=flat-square)

Proyecto estudio de la cátedra Bases de Datos I (UNNE). Consiste en el diseño conceptual, lógico e implementación de una base de datos relacional para el **Supermercado "El Sol"**, un comercio minorista de consumo masivo, desarrollada sobre **Microsoft SQL Server**.

## Objetivos del sistema

El proyecto busca cubrir los siguientes aspectos operativos del supermercado:

- Registrar las ventas en línea de cajas con detalle de artículos, cajero y medios de pago.
- Mantener el precio histórico de venta congelado al momento de cada compra.
- Monitorear el stock entre depósito y góndolas con alertas de reposición.
- Gestionar clientes frecuentes para promociones y permitir compras a consumidor final.
- Administrar el reabastecimiento de mercadería con la red de proveedores.

## Tecnologías

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- ERDPlus
- Git y GitHub

## Estructura del repositorio

```text
proyecto-bd1-equipo-46/
├── docs/
│   ├── etapa-01/          Requerimientos y dominio del negocio
│   ├── etapa-02/          DER, modelo relacional y normalización
│   ├── etapa-03/          Implementación de la base de datos
│   ├── etapa-04/          Consultas y casos de uso
│   └── etapa-05/          Temas técnicos y optimización
├── sql/
│   ├── ddl/               Definición de estructuras
│   ├── dml/               Carga de datos
│   ├── consultas/         Consultas del negocio
│   └── tecnico/           Objetos técnicos (vistas, triggers, etc.)
└── README.md
```

## Avance

| Etapa | Contenido | Estado |
| :---: | :--- | :---: |
| 01 | Requerimientos y dominio del negocio | ![](https://img.shields.io/badge/-Completa-2E7D32?style=flat-square) |
| 02 | Modelo conceptual, relacional y normalización | ![](https://img.shields.io/badge/-En%20curso-F9A825?style=flat-square) |
| 03 | Implementación de la base de datos (DDL y DML) | ![](https://img.shields.io/badge/-Pendiente-9E9E9E?style=flat-square) |
| 04 | Consultas del negocio y casos de uso | ![](https://img.shields.io/badge/-Pendiente-9E9E9E?style=flat-square) |
| 05 | Temas técnicos (procedimientos, triggers, seguridad) | ![](https://img.shields.io/badge/-Pendiente-9E9E9E?style=flat-square) |

## Documentación

### Etapa 01 - Requerimientos y dominio del negocio
- [Descripción del caso de estudio](docs/etapa-01/descripcion-caso-estudio.md)
- [Alcance del sistema](docs/etapa-01/alcance-sistema.md)
- [Reglas de negocio](docs/etapa-01/reglas-de-negocio.md)

### Etapa 02 - Modelado conceptual y relacional
- [Diagrama Entidad-Relación (DER)](docs/etapa-02/der/SupermercadoElSol-DER(Corregido)%20(2).png)
- [Componentes del modelo conceptual](docs/etapa-02/der/componentes-del-modelo-conceptual.md)
- [Decisiones de diseño del DER](docs/etapa-02/der/decisiones-diseno-der.md)
- [Modelo Relacional](docs/etapa-02/modelo-relacional.png)

## Diagrama Entidad-Relación

<p align="center">
  <img src="docs/etapa-02/der/SupermercadoElSol-DER(Corregido) (2).png" alt="Diagrama Entidad-Relación" width="100%">
</p>

## Integrantes - Equipo 46

- Espinola Luz
- López Alfredo Gabriel
- Maciel Jorge Alejandro
- Vega José Maria
- Villagra Facundo Nahuel