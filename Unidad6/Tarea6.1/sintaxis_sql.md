# Sintaxis y clasificación de sentencias SQL (LDD y LMD)

## Características generales

- **Lenguaje declarativo.** Se indica **qué** datos se quieren, no **cómo** obtenerlos; el optimizador del SGBD elige el plan de ejecución.
- **Estandarizado.** Normas ANSI/ISO (SQL-86, SQL-89, SQL-92, SQL:1999, SQL:2003, SQL:2008, SQL:2011, SQL:2016 y SQL:2023, ISO/IEC 9075). Cada fabricante agrega extensiones: T-SQL (SQL Server), PL/pgSQL (PostgreSQL), PL/SQL (Oracle), MySQL/MariaDB.
- **Basado en el modelo relacional.** Sus sentencias corresponden a operadores del álgebra y del cálculo relacional (SELECT ≈ σ, π, ⋈; UNION ≈ ∪; EXCEPT ≈ −). A diferencia del álgebra, SQL trabaja con *multiconjuntos*: admite filas duplicadas salvo que se use DISTINCT.
- **Lógica de tres valores.** Los valores NULL generan resultados TRUE, FALSE o UNKNOWN; por eso se usa IS NULL / IS NOT NULL en lugar de = NULL.
- **Sintaxis.** Las palabras reservadas no distinguen mayúsculas de minúsculas; las sentencias se separan con punto y coma (en T-SQL es opcional, salvo en algunas sentencias) y los lotes con GO en SSMS. Los comentarios son `--` y `/* … */`.
- **Sublenguajes.** Se clasifica por su función en DDL, DML, DCL y TCL (tabla siguiente).
- **Portabilidad parcial.** El núcleo (SELECT, INSERT, UPDATE, DELETE, CREATE/ALTER/DROP TABLE) es común; difieren los tipos de datos, el autonumérico, la paginación y las funciones.

## Taxonomía de las sentencias SQL

| Sublenguaje | Nombre | Función | Sentencias principales |
|---|---|---|---|
| **DDL** | Lenguaje de Definición de Datos | Define y modifica la *estructura* de la base de datos | CREATE, ALTER, DROP, TRUNCATE (también RENAME vía sp_rename, COMMENT) |
| **DML** | Lenguaje de Manipulación de Datos | Consulta y modifica los *datos* almacenados | INSERT, UPDATE, DELETE, SELECT (MERGE) |
| DCL | Lenguaje de Control de Datos | Otorga o retira permisos | GRANT, REVOKE, DENY |
| TCL | Lenguaje de Control de Transacciones | Controla la atomicidad de un conjunto de sentencias | BEGIN TRANSACTION, COMMIT, ROLLBACK, SAVE TRANSACTION |

_Nota de clasificación: algunos autores separan SELECT como DQL (Data Query Language) y otros ubican TRUNCATE dentro de DML porque elimina datos; en esta tarea se usa la clasificación pedida: TRUNCATE en DDL y SELECT en DML._

## Comparativa LDD vs. LMD

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

### Comparativa por sentencia

| Sentencia | Tipo | Acción | ¿WHERE? | ¿ROLLBACK en SQL Server? | Dispara triggers DML |
|---|---|---|---|---|---|
| CREATE | DDL | Crea un objeto | No | Sí (salvo CREATE DATABASE) | No (eventos DDL) |
| ALTER | DDL | Modifica un objeto | No | Sí | No (eventos DDL) |
| DROP | DDL | Elimina un objeto | No | Sí (salvo DROP DATABASE) | No (eventos DDL) |
| TRUNCATE | DDL | Vacía una tabla y reinicia IDENTITY | No | Sí, dentro de una transacción | No |
| INSERT | DML | Agrega filas | No (usa SELECT/VALUES) | Sí | Sí |
| UPDATE | DML | Modifica filas | Sí | Sí | Sí |
| DELETE | DML | Elimina filas | Sí | Sí | Sí |
| SELECT | DML (DQL) | Consulta filas | Sí | No modifica datos | No |

## Sintaxis formal de cada sentencia (T-SQL)

Convenciones: MAYÚSCULAS = palabra reservada; minúsculas = parámetro; `[ ]` opcional; `{ }` alternativas obligatorias; `|` separa alternativas; `[ , ...n ]` repetición separada por comas.

### 1. CREATE DATABASE (DDL)

**Descripción:** Crea una base de datos nueva en la instancia del servidor.

**Sintaxis formal:**

```sql
CREATE DATABASE database_name
[ ON [ PRIMARY ]
    ( NAME = logical_name,
      FILENAME = 'os_file_name'
      [ , SIZE = size [ KB | MB | GB ] ]
      [ , MAXSIZE = { max_size | UNLIMITED } ]
      [ , FILEGROWTH = growth_increment ] ) ]
[ LOG ON ( NAME = logical_name, FILENAME = 'os_file_name' ) ]
[ COLLATE collation_name ]
```

| Parámetro / cláusula | Descripción |
|---|---|
| `database_name` | Nombre de la base de datos; único en la instancia, hasta 128 caracteres. |
| `ON PRIMARY … FILENAME` | Archivo de datos y su ruta; si se omite, el servidor usa la ubicación predeterminada. |
| `SIZE / MAXSIZE / FILEGROWTH` | Tamaño inicial, tamaño máximo y crecimiento automático del archivo. |
| `LOG ON` | Archivo del registro de transacciones. |
| `COLLATE` | Ordenamiento y comparación de cadenas (por ejemplo Modern_Spanish_CI_AS). |

**Restricciones y reglas:**

- Requiere el permiso CREATE DATABASE.
- No puede ejecutarse dentro de una transacción de varias sentencias.
- Con IF DB_ID(N'nombre') IS NULL se evita el error si ya existe.

**Opciones avanzadas:**

- Varios archivos y grupos de archivos (FILEGROUP).
- CONTAINMENT = PARTIAL para bases contenidas.
- ALTER DATABASE para cambiar opciones después de crearla.

**Ejemplo (base de datos veterinaria):**

```sql
CREATE DATABASE veterinaria
COLLATE Modern_Spanish_CI_AS;
```

### 2. CREATE TABLE (DDL)

**Descripción:** Crea una tabla con sus columnas, tipos de dato y restricciones.

**Sintaxis formal:**

```sql
CREATE TABLE [ schema_name. ] table_name
(
    column_name data_type
        [ IDENTITY [ ( seed , increment ) ] ]
        [ NULL | NOT NULL ]
        [ [ CONSTRAINT constraint_name ] DEFAULT constant_expression ]
        [ column_constraint [ ...n ] ]
  | [ CONSTRAINT constraint_name ] table_constraint
  [ , ...n ]
)

table_constraint ::=
    { PRIMARY KEY | UNIQUE } [ CLUSTERED | NONCLUSTERED ] ( column [ ASC | DESC ] [ , ...n ] )
  | FOREIGN KEY ( column [ , ...n ] )
        REFERENCES ref_table [ ( ref_column [ , ...n ] ) ]
        [ ON DELETE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]
        [ ON UPDATE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]
  | CHECK ( logical_expression )
```

| Parámetro / cláusula | Descripción |
|---|---|
| `data_type` | Tipo de dato: INT, VARCHAR(n), CHAR(n), DECIMAL(p,s), DATE, DATETIME2, BIT, … |
| `IDENTITY(seed, increment)` | Columna autonumérica: valor inicial e incremento. |
| `NULL \| NOT NULL` | Indica si la columna admite nulos (por omisión, NULL). |
| `DEFAULT` | Valor que se usa cuando no se proporciona uno. |
| `PRIMARY KEY` | Identifica cada fila; implica NOT NULL y UNIQUE; una por tabla. |
| `UNIQUE` | Impide valores repetidos; en SQL Server admite un solo NULL. |
| `FOREIGN KEY … REFERENCES` | Integridad referencial hacia otra tabla; ON DELETE / ON UPDATE definen la acción. |
| `CHECK` | Condición que todo valor de la fila debe cumplir. |

**Restricciones y reglas:**

- La tabla referenciada debe existir y la columna referenciada debe ser PRIMARY KEY o UNIQUE.
- Los nombres de restricción deben ser únicos en el esquema.
- Una columna IDENTITY no puede tener DEFAULT y solo hay una por tabla.
- SQL Server rechaza FK con ciclos o rutas múltiples de cascada (usar NO ACTION en alguna).
- RESTRICT no existe en T-SQL: su equivalente es NO ACTION.

**Opciones avanzadas:**

- Columnas calculadas: `total AS (cantidad * precio) PERSISTED`.
- Tablas temporales: #local y ##global.
- CREATE TABLE … AS no existe; se usa SELECT … INTO.
- Índices en la definición: PRIMARY KEY CLUSTERED, INDEX ix (col).

**Ejemplo (base de datos veterinaria):**

```sql
CREATE TABLE mascota (
    id_mascota INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    peso DECIMAL(6,2) NULL,
    id_propietario INT NOT NULL,
    CONSTRAINT pk_mascota PRIMARY KEY (id_mascota),
    CONSTRAINT ck_mascota_peso CHECK (peso > 0),
    CONSTRAINT fk_mascota_propietario FOREIGN KEY (id_propietario)
        REFERENCES propietario (id_propietario)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
```

### 3. ALTER TABLE (DDL)

**Descripción:** Modifica la estructura de una tabla existente: columnas y restricciones.

**Sintaxis formal:**

```sql
ALTER TABLE table_name
{
    ALTER COLUMN column_name new_data_type [ NULL | NOT NULL ]
  | ADD { column_definition | [ CONSTRAINT constraint_name ] table_constraint } [ , ...n ]
  | DROP { [ CONSTRAINT ] [ IF EXISTS ] constraint_name
         | COLUMN [ IF EXISTS ] column_name } [ , ...n ]
  | [ WITH { CHECK | NOCHECK } ] { CHECK | NOCHECK } CONSTRAINT { ALL | constraint_name [ , ...n ] }
}
```

| Parámetro / cláusula | Descripción |
|---|---|
| `ALTER COLUMN` | Cambia el tipo o la nulabilidad de una columna. |
| `ADD column_definition` | Agrega una columna (con su tipo y restricciones). |
| `ADD CONSTRAINT` | Agrega una PRIMARY KEY, UNIQUE, FOREIGN KEY, CHECK o DEFAULT. |
| `DROP COLUMN / DROP CONSTRAINT` | Elimina una columna o una restricción. |
| `WITH CHECK \| NOCHECK` | Valida (o no) los datos existentes al agregar una restricción. |
| `CHECK \| NOCHECK CONSTRAINT` | Habilita o deshabilita una restricción FOREIGN KEY o CHECK. |

**Restricciones y reglas:**

- No se puede eliminar una columna que forma parte de una PK, FK, CHECK, índice o DEFAULT sin quitar antes la restricción.
- Al agregar NOT NULL, las filas existentes no deben tener NULL.
- ALTER COLUMN no puede modificar columnas IDENTITY, calculadas ni de tipo incompatible con los datos.
- Para renombrar una tabla o columna se usa el procedimiento sp_rename (no existe ALTER … RENAME).

**Opciones avanzadas:**

- ALTER TABLE … ADD … con valores DEFAULT para llenar filas existentes (WITH VALUES).
- NOCHECK CONSTRAINT ALL para cargas masivas y CHECK para reactivar.
- SWITCH PARTITION y REBUILD para tablas particionadas.

**Ejemplo (base de datos veterinaria):**

```sql
ALTER TABLE medicamento
    ADD fecha_caducidad DATE NULL;

ALTER TABLE medicamento
    ADD CONSTRAINT ck_medicamento_precio CHECK (precio >= 0);

ALTER TABLE medicamento
    DROP COLUMN fecha_caducidad;
```

### 4. DROP (DDL)

**Descripción:** Elimina de forma permanente un objeto de la base de datos (tabla, base de datos, índice o vista).

**Sintaxis formal:**

```sql
DROP TABLE [ IF EXISTS ] [ schema_name. ] table_name [ , ...n ]
DROP DATABASE [ IF EXISTS ] database_name [ , ...n ]
DROP INDEX [ IF EXISTS ] index_name ON table_name
DROP VIEW [ IF EXISTS ] view_name [ , ...n ]
```

| Parámetro / cláusula | Descripción |
|---|---|
| `IF EXISTS` | Evita el error si el objeto no existe (SQL Server 2016 o superior). |
| `table_name [ , ...n ]` | Se pueden eliminar varias tablas en una sentencia. |
| `DROP DATABASE` | Elimina la base de datos y sus archivos físicos. |

**Restricciones y reglas:**

- No se puede eliminar una tabla referenciada por una FOREIGN KEY: hay que eliminar antes la FK o la tabla hija.
- No se puede eliminar una base de datos en uso ni las bases del sistema (master, model, msdb, tempdb); se cambia a master antes.
- Es irreversible fuera de una transacción (DROP DATABASE no puede revertirse).
- Se pierden también los índices, disparadores y permisos de la tabla.

**Opciones avanzadas:**

- ALTER DATABASE nombre SET SINGLE_USER WITH ROLLBACK IMMEDIATE antes de DROP DATABASE.
- DROP TABLE sobre varias tablas en orden inverso a las dependencias.

**Ejemplo (base de datos veterinaria):**

```sql
DROP TABLE IF EXISTS aplica, receta;      -- hijas primero
DROP VIEW  IF EXISTS v_factura;
DROP DATABASE IF EXISTS veterinaria;
```

### 5. TRUNCATE TABLE (DDL)

**Descripción:** Elimina todas las filas de una tabla de forma rápida y conserva su estructura.

**Sintaxis formal:**

```sql
TRUNCATE TABLE [ schema_name. ] table_name
    [ WITH ( PARTITIONS ( { partition_number | range } [ , ...n ] ) ) ]
```

| Parámetro / cláusula | Descripción |
|---|---|
| `table_name` | Tabla que se vacía. |
| `WITH PARTITIONS` | Vacía solo las particiones indicadas. |

**Restricciones y reglas:**

- No admite WHERE: borra todas las filas.
- No se puede usar en una tabla referenciada por una FOREIGN KEY (aunque la tabla hija esté vacía).
- No activa triggers DELETE.
- Reinicia el contador IDENTITY a su valor inicial.
- Requiere permiso ALTER sobre la tabla.

**Opciones avanzadas:**

- Registra solo la desasignación de páginas (registro mínimo), por lo que es mucho más rápida que DELETE.
- Se puede revertir con ROLLBACK si se ejecuta dentro de una transacción.

**Ejemplo (base de datos veterinaria):**

```sql
TRUNCATE TABLE telefono_propietario;   -- no la referencia ninguna FK
-- TRUNCATE TABLE medicamento;         -- error: la referencian receta y suministra
```

### 6. INSERT (DML)

**Descripción:** Agrega una o varias filas a una tabla.

**Sintaxis formal:**

```sql
INSERT [ INTO ] table_name [ ( column_list ) ]
[ OUTPUT inserted.column [ , ...n ] ]
{ VALUES ( { expression | DEFAULT | NULL } [ , ...n ] ) [ , ...n ]
| select_statement
| DEFAULT VALUES }
```

| Parámetro / cláusula | Descripción |
|---|---|
| `column_list` | Columnas que recibirán valores; el orden de VALUES debe coincidir. |
| `VALUES` | Una o varias filas (hasta 1,000 por sentencia). |
| `select_statement` | INSERT … SELECT: inserta el resultado de una consulta. |
| `DEFAULT VALUES` | Inserta una fila con los valores predeterminados. |
| `OUTPUT` | Devuelve las filas insertadas (por ejemplo, el IDENTITY generado). |

**Restricciones y reglas:**

- Las columnas NOT NULL sin DEFAULT deben recibir un valor.
- No se puede insertar en una columna IDENTITY, salvo con SET IDENTITY_INSERT tabla ON.
- Se validan PRIMARY KEY, UNIQUE, FOREIGN KEY y CHECK; si una fila falla, toda la sentencia se cancela.
- Los tipos deben ser compatibles (conversión implícita).

**Opciones avanzadas:**

- INSERT … SELECT para copiar datos.
- OUTPUT inserted.id para recuperar identificadores.
- SCOPE_IDENTITY() devuelve el último IDENTITY de la sesión.
- INSERT … EXEC procedimiento.

**Ejemplo (base de datos veterinaria):**

```sql
INSERT INTO propietario (nombre_pila, ap_paterno, calle, colonia, cp)
VALUES ('Luis', 'Herrera', 'Calle 5', 'Centro', '25700'),
       ('Rosa', 'Vega', 'Av. Juárez 10', 'Pape', '25730');
```

### 7. UPDATE (DML)

**Descripción:** Modifica los valores de columnas de las filas que cumplen una condición.

**Sintaxis formal:**

```sql
UPDATE [ TOP ( expression ) ] table_name
SET { column_name = { expression | DEFAULT | NULL }
    | column_name { += | -= | *= | /= | %= } expression } [ , ...n ]
[ OUTPUT deleted.column , inserted.column [ , ...n ] ]
[ FROM table_source [ , ...n ] ]
[ WHERE search_condition ]
```

| Parámetro / cláusula | Descripción |
|---|---|
| `SET` | Columnas por modificar y sus nuevos valores; admite operadores compuestos (+=, *=). |
| `FROM` | Permite actualizar con datos de otras tablas mediante JOIN. |
| `WHERE` | Condición que selecciona las filas; sin WHERE se actualizan todas. |
| `TOP (n)` | Limita el número de filas actualizadas. |
| `OUTPUT` | Devuelve los valores anteriores (deleted) y nuevos (inserted). |

**Restricciones y reglas:**

- Sin WHERE modifica todas las filas de la tabla.
- No puede asignar valores a columnas IDENTITY ni calculadas.
- El nuevo valor debe cumplir NOT NULL, CHECK, UNIQUE y la integridad referencial; si no, se cancela toda la sentencia.
- Si la PK referenciada se actualiza, la FK actúa según ON UPDATE (CASCADE o NO ACTION).

**Opciones avanzadas:**

- UPDATE … FROM … JOIN para actualizar con valores de otra tabla.
- Subconsultas en SET y WHERE.
- Ejecutar dentro de BEGIN TRANSACTION para poder revertir.

**Ejemplo (base de datos veterinaria):**

```sql
UPDATE medicamento
SET precio = precio * 1.10
WHERE id_medicamento = 1;
```

### 8. DELETE (DML)

**Descripción:** Elimina las filas que cumplen una condición.

**Sintaxis formal:**

```sql
DELETE [ TOP ( expression ) ] [ FROM ] table_name
[ OUTPUT deleted.column [ , ...n ] ]
[ FROM table_source [ , ...n ] ]
[ WHERE search_condition ]
```

| Parámetro / cláusula | Descripción |
|---|---|
| `WHERE` | Filas que se eliminan; sin WHERE se eliminan todas. |
| `FROM … JOIN` | Permite eliminar según datos de otras tablas. |
| `OUTPUT` | Devuelve las filas eliminadas. |
| `TOP (n)` | Limita el número de filas eliminadas. |

**Restricciones y reglas:**

- Sin WHERE elimina todas las filas (la tabla permanece).
- No reinicia el contador IDENTITY.
- Respeta la integridad referencial: ON DELETE NO ACTION rechaza la operación si hay filas dependientes; ON DELETE CASCADE elimina también las dependientes.
- Registra cada fila eliminada (más lento que TRUNCATE) y activa triggers DELETE.

**Opciones avanzadas:**

- DELETE … OUTPUT deleted.* INTO tabla_respaldo.
- DELETE por lotes con TOP para tablas muy grandes.
- Subconsultas con IN / EXISTS.

**Ejemplo (base de datos veterinaria):**

```sql
DELETE FROM consulta
WHERE folio = 7;     -- elimina también sus recetas (ON DELETE CASCADE)
```

### 9. SELECT (DML)

**Descripción:** Consulta datos de una o más tablas y devuelve un conjunto de resultados.

**Sintaxis formal:**

```sql
SELECT [ ALL | DISTINCT ] [ TOP ( expression ) [ PERCENT ] [ WITH TIES ] ]
    select_list
[ INTO new_table ]
[ FROM table_source [ , ...n ] ]
[ WHERE search_condition ]
[ GROUP BY { column_expression | ROLLUP ( … ) | CUBE ( … ) } [ , ...n ] ]
[ HAVING search_condition ]
[ ORDER BY order_expression [ ASC | DESC ] [ , ...n ]
    [ OFFSET n { ROW | ROWS } [ FETCH { FIRST | NEXT } m { ROW | ROWS } ONLY ] ] ]

table_source ::=
    table_name [ [ AS ] alias ]
  | table_source { [ INNER ] | { LEFT | RIGHT | FULL } [ OUTER ] } JOIN table_source ON search_condition
  | table_source CROSS JOIN table_source
```

| Parámetro / cláusula | Descripción |
|---|---|
| `DISTINCT` | Elimina las filas duplicadas del resultado. |
| `TOP (n) [PERCENT]` | Devuelve las primeras n filas (o el n por ciento). |
| `select_list` | Columnas, expresiones, funciones de agregación o *; admite alias con AS. |
| `FROM … JOIN` | Tablas de origen y reuniones: INNER, LEFT, RIGHT, FULL OUTER, CROSS. |
| `WHERE` | Filtra filas antes de agrupar (no admite funciones de agregación). |
| `GROUP BY` | Agrupa filas con el mismo valor para aplicar agregaciones (COUNT, SUM, AVG, MAX, MIN). |
| `HAVING` | Filtra grupos después de agrupar. |
| `ORDER BY` | Ordena el resultado (ASC por omisión; DESC descendente). |
| `OFFSET … FETCH` | Paginación; requiere ORDER BY. |

**Restricciones y reglas:**

- Toda columna del SELECT que no esté en una función de agregación debe aparecer en GROUP BY.
- WHERE no puede usar agregaciones; para ello se usa HAVING.
- Los alias definidos en el SELECT no pueden usarse en WHERE o HAVING, pero sí en ORDER BY.
- Una consulta sin ORDER BY no garantiza el orden de las filas.
- OFFSET … FETCH exige ORDER BY.

**Opciones avanzadas:**

- Subconsultas (en SELECT, FROM, WHERE) y subconsultas correlacionadas con EXISTS.
- Operadores de conjuntos: UNION, UNION ALL, INTERSECT, EXCEPT.
- Expresiones CTE: `WITH nombre AS ( SELECT … ) SELECT …`.
- Funciones de ventana: `SUM(x) OVER (PARTITION BY g ORDER BY f)`.
- CASE para lógica condicional; SELECT … INTO para crear una tabla desde una consulta.

**Ejemplo (base de datos veterinaria):**

```sql
SELECT p.nombre_pila, COUNT(m.id_mascota) AS num_mascotas
FROM propietario p
LEFT JOIN mascota m ON m.id_propietario = p.id_propietario
GROUP BY p.id_propietario, p.nombre_pila
HAVING COUNT(m.id_mascota) >= 1
ORDER BY num_mascotas DESC;
```

## Orden lógico de evaluación de SELECT

**FROM / JOIN** → **WHERE** → **GROUP BY** → **HAVING** → **SELECT (y DISTINCT)** → **ORDER BY** → **TOP / OFFSET-FETCH**

## Diferencias entre dialectos

| Característica | SQL Server (T-SQL) | PostgreSQL | MySQL / MariaDB | Estándar SQL |
|---|---|---|---|---|
| Autonumérico | IDENTITY(1,1) | GENERATED … AS IDENTITY / SERIAL | AUTO_INCREMENT | GENERATED … AS IDENTITY |
| Limitar filas | TOP n  ·  OFFSET … FETCH | LIMIT n OFFSET m | LIMIT n OFFSET m | FETCH FIRST n ROWS ONLY |
| Booleano | BIT | BOOLEAN | TINYINT(1) / BOOLEAN | BOOLEAN |
| Fecha y hora actual | GETDATE(), SYSDATETIME() | NOW(), CURRENT_TIMESTAMP | NOW(), CURRENT_TIMESTAMP | CURRENT_TIMESTAMP |
| Concatenar texto | + o CONCAT() | \|\| o CONCAT() | CONCAT() | \|\| |
| DROP … IF EXISTS | Sí (2016+) | Sí | Sí | No (extensión) |
| TRUNCATE en transacción | Sí se puede revertir | Sí se puede revertir | Hace COMMIT implícito | — |
| Renombrar tabla | sp_rename | ALTER TABLE … RENAME TO | RENAME TABLE | No estandarizado |
| Acción RESTRICT en FK | NO ACTION | RESTRICT y NO ACTION | RESTRICT y NO ACTION | RESTRICT y NO ACTION |

## Referencias bibliográficas (APA)

- Beaulieu, A. (2020). *Learning SQL* (3rd ed.). O'Reilly Media.
- Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of Database Systems* (7th ed.). Pearson.
- International Organization for Standardization. (2016). *ISO/IEC 9075:2016 Information technology — Database languages — SQL*. ISO.
- Microsoft. (2025). *Transact-SQL reference (Database Engine)*. Microsoft Learn. https://learn.microsoft.com/sql/t-sql/
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database System Concepts* (7th ed.). McGraw-Hill Education.
