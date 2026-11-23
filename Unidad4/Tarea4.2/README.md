# Unidad 4 · Tarea 4.2: Normalización paso a paso y script SQL normalizado

**Materia:** Estructura de Datos
**Alumno:** Ximena Sánchez Lugo
**Docente:** Rubén Miguel Riojas Rodríguez
**Institución:** Instituto Tecnológico Superior de Monclova (ITSM)

**SGBD:** Microsoft SQL Server (T-SQL) · **Herramienta:** SQL Server Management Studio (SSMS)

## Contenido de la carpeta

| Archivo | Descripción |
|---|---|
| [`Tarea4.2_Normalizacion.pdf`](Tarea4.2_Normalizacion.pdf) | Desglose analítico de cada fase de normalización y de las anomalías corregidas |
| [`normalized_schema.sql`](normalized_schema.sql) | **Script SQL del esquema totalmente normalizado** (25 tablas, 3 vistas) |
| [`normalized_data.sql`](normalized_data.sql) | Datos de prueba |
| [`normalized_tests.sql`](normalized_tests.sql) | 26 pruebas de integridad (TRY…CATCH con mensajes PRINT) |
| [`dependencias_funcionales.md`](dependencias_funcionales.md) | Dependencias funcionales de la hoja de consulta |

## Estructura normalizada: la hoja de consulta

Se parte de la hoja única con la que la clínica registra las consultas (cuadernos y hojas de cálculo):

`HOJA_CONSULTA(folio, fecha, id_mascota, nombre_mascota, especie, raza, id_propietario, nombre_propietario, {telefono}, id_veterinario, nombre_veterinario, cedula, {id_medicamento, nombre_medicamento, precio, dosis, duracion}, {id_vacuna, nombre_vacuna, lote, caducidad}, diagnostico, no_factura, subtotal)`

| # | Dependencia | Significado |
|---|---|---|
| F1 | folio → fecha, id_mascota, id_veterinario, diagnostico, no_factura | Una consulta es de una mascota, la atiende un veterinario y genera una factura |
| F2 | id_mascota → nombre_mascota, raza, id_propietario | Datos de la mascota |
| F3 | raza → especie | Cada raza pertenece a una especie |
| F4 | id_propietario → nombre_propietario | Datos del propietario |
| F5 | id_veterinario → nombre_veterinario, cedula | Datos del veterinario |
| F6 | id_medicamento → nombre_medicamento, precio | Datos del medicamento |
| F7 | (folio, id_medicamento) → dosis, duracion | Receta |
| F8 | id_vacuna → nombre_vacuna | Datos de la vacuna |
| F9 | lote → id_vacuna, caducidad | Un lote es de una vacuna y tiene una caducidad |
| F10 | (folio, id_vacuna) → lote | Lote aplicado |
| F11 | no_factura → folio, subtotal; folio → no_factura | Relación 1:1 consulta–factura |
| MVD | folio ↠ telefono \| medicamentos \| vacunas | Grupos independientes |

## Transición paso a paso

| Fase | Regla | Qué se hizo | Anomalías corregidas |
|---|---|---|---|
| **UNF → 1FN** | Atributos atómicos, sin grupos repetitivos | Cada valor de teléfono, medicamento y vacuna pasa a su fila. Llave: (folio, telefono, id_medicamento, id_vacuna). 6 filas para 2 consultas | Valores no atómicos |
| **1FN → 2FN** | Sin dependencias parciales | Se separan CONSULTA, TELEFONO_CONSULTA, RECETA, MEDICAMENTO, APLICACION y VACUNA | Precio y nombre del medicamento repetidos; catálogos que no se podían registrar sin consulta |
| **2FN → 3FN** | Sin dependencias transitivas | Se separan MASCOTA, RAZA, PROPIETARIO, TELEFONO_PROPIETARIO, VETERINARIO, FACTURA, LOTE y se simplifican CONSULTA y APLICACION | Nombre del propietario, caducidad del lote y raza repetidos; pérdida de datos al borrar una consulta |
| **FNBC / 4FN / 5FN** | Todo determinante es superclave; sin MVD ni JD | Validación: las 12 relaciones cumplen; la MVD quedó resuelta al separar los grupos | — |

Se comprobó por cálculo que la reunión de las 12 relaciones en 3FN reproduce exactamente las filas de la hoja en 1FN (reunión sin pérdida).

## Normalización del esquema completo (Unidad 3)

Al analizar las 22 tablas de la Unidad 3 se encontraron dos relaciones que no cumplían 3FN:

| Relación | Dependencia | Corrección |
|---|---|---|
| MASCOTA (`especie`, `raza`, `tipo`) | raza → especie; especie → tipo | Catálogos `especie` y `raza`; MASCOTA guarda `id_especie` e `id_raza` con FK compuestas |
| APLICA (`id_vacuna`, `lote`, `caducidad`) | lote → id_vacuna, caducidad | Tabla `lote_vacuna`; `aplica(folio, id_lote)` |

Resultado: **25 tablas**. La columna `tipo` de MASCOTA se conserva como discriminador de la especialización disjunta (desnormalización controlada: la FK compuesta (id_especie, tipo) → ESPECIE impide que sea inconsistente).

## Cómo ejecutar el script en SSMS

1. Abrir SSMS y conectarse al servidor.
2. Ejecutar (F5) `normalized_schema.sql`: crea la base `veterinaria`, las 25 tablas, índices, vistas y descripciones. Es reejecutable.
3. Ejecutar `normalized_data.sql` y, una sola vez, `normalized_tests.sql` (resultados en la pestaña *Messages*).

## Validación previa

El esquema, los datos y las pruebas se ejecutaron en SQLite 3.45 con llaves foráneas activadas para comprobar la lógica. No sustituye la ejecución en SQL Server.

| Prueba | Qué se verifica | Resultado (SQLite) |
|---|---|---|
| T01 | Entidad: llave primaria duplicada (teléfono repetido para el mismo propietario) | Correcto |
| T02 | NOT NULL: propietario sin nombre_pila | Correcto |
| T03 | Referencial: mascota con propietario inexistente | Correcto |
| T04 | CHECK: peso menor o igual a cero | Correcto |
| T05 | CHECK: existencia negativa de medicamento | Correcto |
| T06 | CHECK: estado de cita fuera del dominio | Correcto |
| T07 | CHECK: código postal con formato inválido | Correcto |
| T08 | CHECK: tipo de mascota fuera del dominio | Correcto |
| T09 | UNIQUE: RFC de empleado repetido | Correcto |
| T10 | UNIQUE: veterinario con dos citas a la misma hora (regla 6) | Correcto |
| T11 | UNIQUE: segunda factura para la misma consulta (relación 1:1) | Correcto |
| T12 | Disyunción: la mascota 1 es CANINO y se intenta registrar como FELINO | Correcto |
| T13 | CHECK de subtipo: fila de CANINO con discriminador distinto | Correcto |
| T14 | Jerarquía: especialista asignado a un empleado que no es veterinario | Correcto |
| T15 | RESTRICT: borrar un propietario que tiene mascotas | Correcto |
| T16 | RESTRICT: borrar un medicamento que ya fue recetado | Correcto |
| T17 | Vista v_factura: total = subtotal + medicamentos recetados (450 + 120) | Correcto |
| T18 | ON DELETE CASCADE: al borrar la consulta 3 se borran sus recetas | Correcto |
| T19 | ON DELETE CASCADE: al borrar un empleado se borra su rol de auxiliar | Correcto |
| T20 | ON DELETE CASCADE: al borrar un propietario sin mascotas se borran sus teléfonos | Correcto |
| T21 | ON UPDATE CASCADE: al cambiar la llave de un veterinario se actualizan sus especialidades | Correcto |
| T22 | 3FN raza → especie: raza de otra especie (Siamés es de gato, no de perro) | Correcto |
| T23 | 3FN especie → tipo: tipo incoherente con la especie (Perro como FELINO) | Correcto |
| T24 | UNIQUE: el mismo código de lote repetido para la misma vacuna | Correcto |
| T25 | Anomalía de modificación corregida: la caducidad del lote se cambia en un solo lugar | Correcto |
| T26 | Anomalía de modificación corregida: la raza se renombra en un solo lugar | Correcto |

## Referencias bibliográficas (APA)

- Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377-387.
- Codd, E. F. (1972). Further normalization of the data base relational model. En R. Rustin (Ed.), *Data base systems* (pp. 33-64). Prentice-Hall.
- Date, C. J. (2003). *An introduction to database systems* (8th ed.). Addison-Wesley.
- Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of database systems* (7th ed.). Pearson.
- Fagin, R. (1977). Multivalued dependencies and a new normal form for relational databases. *ACM Transactions on Database Systems, 2*(3), 262-278.
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7th ed.). McGraw-Hill Education.
