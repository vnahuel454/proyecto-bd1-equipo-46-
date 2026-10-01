<div align="center">

<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=14&pause=1200&color=00529B&center=true&vCenter=true&width=620&lines=Licenciatura+en+Sistemas+de+Informaci%C3%B3n+%E2%80%94+FaCENA+%28UNNE%29;Bases+de+Datos+I+%E2%80%94+2026;Equipo+46" alt="Typing SVG" /></a>

# Supermercado "El Sol"
### Bases de Datos I (2026) - FaCENA, UNNE

<p>
  <img src="https://img.shields.io/badge/UNNE-FaCENA-00529B?style=for-the-badge" alt="Universidad"/>
  <img src="https://img.shields.io/badge/Bases%20de%20Datos%20I-2026-1565C0?style=for-the-badge" alt="Cátedra"/>
  <img src="https://img.shields.io/badge/SGBD-SQL%20Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white" alt="Motor"/>
  <img src="https://img.shields.io/badge/Equipo-46-2E7D32?style=for-the-badge" alt="Equipo"/>
</p>

</div>

---

## Descripción

Trabajo práctico integrador de la cátedra Bases de Datos I (FaCENA - UNNE). El proyecto comprende el análisis del negocio, modelado conceptual y lógico, y la implementación en SQL Server de la base de datos para el Supermercado "El Sol", un comercio minorista de consumo masivo.

## Objetivos del sistema

- Registrar ventas en línea de cajas con detalle de artículos, cajero y múltiples medios de pago.
- Preservar el precio unitario histórico cobrado al momento de cada compra.
- Controlar el stock con alertas automáticas de reposición para depósito y góndolas.
- Gestionar clientes registrados para beneficios y registrar ventas a consumidor final.
- Administrar el abastecimiento de mercadería con la red de proveedores.

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

## Avance del proyecto

| Etapa | Contenido                                            |                                     Estado                                     |
| :---: | :--------------------------------------------------- | :----------------------------------------------------------------------------: |
|  01   | Requerimientos y dominio del negocio                 |  ![Completa](https://img.shields.io/badge/-Completa-2E7D32?style=flat-square)  |
|  02   | Modelo conceptual, relacional y normalización        |  ![Completa](https://img.shields.io/badge/-Completa-2E7D32?style=flat-square)  |
|  03   | Implementación de la base de datos (DDL y DML)       |  ![Completa](https://img.shields.io/badge/-Completa-2E7D32?style=flat-square)  |
|  04   | Consultas del negocio y casos de uso                 | ![Pendiente](https://img.shields.io/badge/-Pendiente-9E9E9E?style=flat-square) |
|  05   | Temas técnicos (procedimientos, triggers, seguridad) | ![Pendiente](https://img.shields.io/badge/-Pendiente-9E9E9E?style=flat-square) |

## Documentación

<details>
<summary><b>Etapa 01: Requerimientos y dominio del negocio</b></summary>
<br>

- [Descripción del caso de estudio](docs/etapa-01/descripcion-caso-estudio.md)
- [Alcance del sistema](docs/etapa-01/alcance-sistema.md)
- [Reglas de negocio](docs/etapa-01/reglas-de-negocio.md)

</details>

<details>
<summary><b>Etapa 02: Modelado conceptual y relacional</b></summary>
<br>

- [Diagrama Entidad-Relación (DER)](docs/etapa-02/der/SupermercadoElSol-DER-final.png)
- [Componentes del modelo conceptual](docs/etapa-02/der/componentes-del-modelo-conceptual.md)
- [Decisiones de diseño del DER](docs/etapa-02/der/decisiones-diseno-der.md)
- [Decisiones de diseño del Modelo Relacional](docs/etapa-02/decisiones-modelo-relacional.md)
- [Modelo Relacional](docs/etapa-02/SupermercadoElSol-modelo-relacional(corregido).png)
- [Normalización](docs/etapa-02/normalizacion.md)

</details>

<details>
<summary><b>Etapa 03: Implementación física (Scripts SQL)</b></summary>
<br>

- [Script DDL (crear_bd.sql)](sql/ddl/crear_bd.sql)
- [Script DML (datos_prueba.sql)](sql/dml/datos_prueba.sql)

</details>

## Diagrama Entidad-Relación

<p align="center">
  <img src="docs/etapa-02/der/SupermercadoElSol-DER-final.png" alt="Diagrama Entidad-Relación" width="100%">
</p>

## Diagrama del Modelo Relacional

<p align="center">
  <img src="docs/etapa-02/SupermercadoElSol-modelo-relacional(corregido).png" alt="Diagrama del Modelo Relacional" width="100%">
</p>

## Integrantes (Equipo 46)

<div align="center">

|       Integrante        |
| :---------------------: |
|      Espíndola Luz      |
|  López Alfredo Gabriel  |
| Maciel Jorge Alejandro  |
|     Vega José María     |
| Villagra Facundo Nahuel |

</div>
