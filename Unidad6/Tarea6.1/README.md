# Unidad 6 · Tarea 6.1: Sintaxis y clasificación de sentencias SQL (LDD y LMD)

**Materia:** Estructura de Datos
**Alumno:** Ximena Sánchez Lugo
**Docente:** Rubén Miguel Riojas Rodríguez
**Institución:** Instituto Tecnológico Superior de Monclova (ITSM)

## Contenido de la carpeta

| Archivo | Descripción |
|---|---|
| [`Tarea6.1_Sintaxis_SQL_LDD_LMD.pdf`](Tarea6.1_Sintaxis_SQL_LDD_LMD.pdf) | Documento con la tabla comparativa, la sintaxis formal y las descripciones técnicas |
| [`sintaxis_sql.md`](sintaxis_sql.md) | Documentación técnica completa en Markdown |

## Video explicativo

[Enlace de YouTube (pendiente de agregar)](https://youtube.com/)

## Resumen

### Taxonomía

| Sublenguaje | Nombre | Función | Sentencias principales |
|---|---|---|---|
| **DDL** | Lenguaje de Definición de Datos | Define y modifica la *estructura* de la base de datos | CREATE, ALTER, DROP, TRUNCATE (también RENAME vía sp_rename, COMMENT) |
| **DML** | Lenguaje de Manipulación de Datos | Consulta y modifica los *datos* almacenados | INSERT, UPDATE, DELETE, SELECT (MERGE) |
| DCL | Lenguaje de Control de Datos | Otorga o retira permisos | GRANT, REVOKE, DENY |
| TCL | Lenguaje de Control de Transacciones | Controla la atomicidad de un conjunto de sentencias | BEGIN TRANSACTION, COMMIT, ROLLBACK, SAVE TRANSACTION |

### Comparativa LDD vs. LMD

| Criterio | LDD / DDL | LMD / DML |
|---|---|---|
| Propósito | Definir y modificar la estructura (esquema) | Consultar y modificar los datos (tuplas) |
| Actúa sobre | Objetos: bases de datos, tablas, índices, vistas, restricciones | Filas de las tablas |
| Sentencias | CREATE, ALTER, DROP, TRUNCATE | INSERT, UPDATE, DELETE, SELECT |
| Efecto | Cambia el catálogo (metadatos) del SGBD | Cambia o lee el contenido de las tablas |
| Cláusula WHERE | No aplica (excepto en restricciones CHECK) | Sí: UPDATE, DELETE y SELECT filtran con WHERE |
| Transacciones | En SQL Server se pueden revertir con ROLLBACK; en MySQL, MariaDB y Oracle hacen COMMIT implícito | Se pueden confirmar o revertir con COMMIT / ROLLBACK |
| Disparadores (triggers) | Eventos DDL (CREATE_TABLE, ALTER_TABLE, …); TRUNCATE no activa triggers DELETE | Triggers INSERT, UPDATE, DELETE |
| Permisos típicos | CREATE TABLE, ALTER, CONTROL (db_ddladmin) | INSERT, UPDATE, DELETE, SELECT (db_datawriter / db_datareader) |
| Riesgo | Alto: DROP y TRUNCATE eliminan estructura o todos los datos | Medio: UPDATE o DELETE sin WHERE afectan todas las filas |
| Ejemplo (proyecto) | `CREATE TABLE mascota (…)` | `INSERT INTO mascota (…) VALUES (…)` |

La sintaxis formal (parámetros, restricciones y opciones avanzadas de CREATE, ALTER, DROP, TRUNCATE, INSERT, UPDATE, DELETE y SELECT), el orden lógico de SELECT y la comparación entre dialectos están en [`sintaxis_sql.md`](sintaxis_sql.md).

## Referencias bibliográficas (APA)

- Beaulieu, A. (2020). *Learning SQL* (3rd ed.). O'Reilly Media.
- Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of Database Systems* (7th ed.). Pearson.
- International Organization for Standardization. (2016). *ISO/IEC 9075:2016 Information technology — Database languages — SQL*. ISO.
- Microsoft. (2025). *Transact-SQL reference (Database Engine)*. Microsoft Learn. https://learn.microsoft.com/sql/t-sql/
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database System Concepts* (7th ed.). McGraw-Hill Education.
