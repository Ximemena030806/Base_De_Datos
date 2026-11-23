# Unidad 6 · Tarea 6.2: Implementación de script DDL, carga de datos y consultas DML

**Materia:** Estructura de Datos
**Alumno:** Ximena Sánchez Lugo
**Docente:** Rubén Miguel Riojas Rodríguez
**Institución:** Instituto Tecnológico Superior de Monclova (ITSM)

**SGBD:** Microsoft SQL Server 2019 o superior · **Herramienta:** SQL Server Management Studio (SSMS) o `sqlcmd`

## Estructura del repositorio

| Archivo | Fase | Descripción |
|---|---|---|
| [`01_schema_ddl.sql`](01_schema_ddl.sql) | LDD | Crea la base de datos `veterinaria`, las 25 tablas con PK, FK (ON UPDATE / ON DELETE), UNIQUE, CHECK, NOT NULL, DEFAULT, índices y vistas. Reejecutable |
| [`02_data_inserts.sql`](02_data_inserts.sql) | LMD (INSERT) | 113 filas de prueba en las 25 tablas, en orden padre → hijo |
| [`03_queries_dml.sql`](03_queries_dml.sql) | LMD (SELECT / UPDATE / DELETE) | Parte A: 17 consultas SELECT. Parte B: 13 pruebas de mantenimiento con transacciones |
| [`Tarea6.2_Implementacion_DDL_DML.pdf`](Tarea6.2_Implementacion_DDL_DML.pdf) | Reporte | Reporte técnico con las consultas, resultados y evidencias |

## Video demostrativo

[Enlace de YouTube (pendiente de agregar)](https://youtube.com/)

## Cómo clonar y ejecutar

### Requisitos

- SQL Server 2019 o superior (Developer o Express) y permiso para crear bases de datos.
- SQL Server Management Studio (SSMS) o la herramienta de línea de comandos `sqlcmd`.
- Git.

### 1. Clonar el repositorio

```bash
git clone <URL-DEL-REPOSITORIO>
cd <carpeta-del-repositorio>/Unidad6/Tarea6.2
```

### 2. Ejecutar los scripts **en este orden**

**Con SSMS:** conectarse al servidor (`localhost` o `localhost\SQLEXPRESS`; si pide certificado, marcar *Trust server certificate*), abrir cada archivo con *File → Open → File…* y pulsar **Execute (F5)**.

**Con sqlcmd:**

```bash
sqlcmd -S localhost -E -C -f 65001 -i 01_schema_ddl.sql
sqlcmd -S localhost -E -C -f 65001 -i 02_data_inserts.sql
sqlcmd -S localhost -E -C -f 65001 -i 03_queries_dml.sql
```

(`-E` autenticación de Windows, `-C` confía en el certificado del servidor, `-f 65001` lee los archivos en UTF-8.)

### 3. Qué debe verse

1. `01_schema_ddl.sql`: sin errores; en *Object Explorer → veterinaria → Tables* aparecen 25 tablas.
2. `02_data_inserts.sql`: al final devuelve el conteo de filas por tabla (ninguna en cero).
3. `03_queries_dml.sql`: Parte A devuelve los resultados de las 17 consultas; Parte B imprime en *Messages* `OK, BLOQUEADO -> …` para las operaciones que violan la integridad y muestra el efecto de las válidas. Las pruebas se revierten (ROLLBACK), por lo que el script se puede repetir.

### Solución de problemas

- *Error de certificado al conectar:* marcar *Trust server certificate* o usar `-C` en `sqlcmd`.
- *Acentos mal leídos:* abrir el archivo como UTF-8 (los scripts incluyen BOM).
- *No se puede borrar la base de datos:* hay conexiones abiertas; cambiar a `master` o ejecutar `ALTER DATABASE veterinaria SET SINGLE_USER WITH ROLLBACK IMMEDIATE;`.

## Datos de prueba

| Tabla | Filas |
|---|---|
| aplica | 4 |
| auxiliar | 1 |
| canino | 4 |
| cita | 8 |
| consulta | 7 |
| empleado | 5 |
| especie | 4 |
| exotico | 2 |
| factura | 6 |
| felino | 4 |
| gerente | 1 |
| lote_vacuna | 4 |
| mascota | 10 |
| medicamento | 5 |
| propietario | 6 |
| proveedor | 3 |
| raza | 7 |
| recepcionista | 1 |
| receta | 6 |
| suministra | 7 |
| telefono_propietario | 7 |
| vacuna | 3 |
| veterinario | 3 |
| veterinario_especialidad | 4 |
| veterinario_especialista | 1 |

## Consultas SELECT (Parte A)

| Consulta | Tema | Objetivo | Filas |
|---|---|---|---|
| C01 | SELECT básico | Todos los propietarios registrados. | 6 |
| C02 | WHERE con AND | Mascotas de tipo CANINO que pesan más de 10 kg. | 3 |
| C03 | WHERE con IS NULL | Propietarios que no tienen correo electrónico registrado. | 2 |
| C04 | WHERE con BETWEEN | Medicamentos con precio entre 100 y 200, del más caro al más barato. | 3 |
| C05 | WHERE con IN | Citas programadas o canceladas, en orden cronológico. | 4 |
| C06 | WHERE con LIKE y OR | Mascotas cuyo nombre empieza con M o con T. | 4 |
| C07 | ORDER BY múltiple | Mascotas ordenadas por tipo (ascendente) y peso (descendente). | 10 |
| C08 | Funciones de agregación | Conteo, suma, promedio, máximo y mínimo sobre el inventario de medicamentos. | 1 |
| C09 | GROUP BY | Número de mascotas, peso promedio y peso máximo por tipo. | 3 |
| C10 | GROUP BY + HAVING | Propietarios con dos o más mascotas. | 5 |
| C11 | INNER JOIN (3 tablas) | Consultas con el nombre de la mascota y del veterinario. | 7 |
| C12 | INNER JOIN (4 tablas) | Recetas emitidas: consulta, mascota, medicamento, dosis y duración. | 6 |
| C13 | LEFT JOIN + COUNT | Número de mascotas por propietario, incluidos los que no tienen ninguna. | 6 |
| C14 | LEFT JOIN (filas sin pareja) | Consultas que todavía no tienen factura. | 1 |
| C15 | JOIN + SUM + GROUP BY + HAVING | Total facturado por veterinario, solo si supera 500. | 3 |
| C16 | Subconsulta con AVG | Mascotas que pesan más que el promedio de todas. | 3 |
| C17 | CASE | Clasificación del inventario según su existencia. | 5 |

## Mantenimiento con UPDATE y DELETE (Parte B)

| Prueba | Tipo | Descripción | Resultado esperado |
|---|---|---|---|
| M01 | UPDATE | Aumentar 10 % el precio de la Amoxicilina. | OK, después = 132 |
| M02 | UPDATE | Descontar una unidad de existencia a los medicamentos recetados en la consulta 1 (2 filas). | OK, después = 78 |
| M03 | UPDATE | Actualizar el estado de una cita a un valor permitido. | OK, después = ATENDIDA |
| M04 | UPDATE | Violación de CHECK: existencia negativa. | Bloqueado (`ck_medicamento_existencia`) |
| M05 | UPDATE | Violación de CHECK: estado de cita fuera del dominio. | Bloqueado (`ck_cita_estado`) |
| M06 | UPDATE | Violación de integridad referencial: asignar un propietario inexistente. | Bloqueado (`fk_mascota_propietario`) |
| M07 | DELETE | Eliminar un propietario sin mascotas (permitido). | OK, después = 0 |
| M08 | DELETE | Eliminar un propietario que tiene mascotas (ON DELETE NO ACTION lo impide). | Bloqueado (`fk_mascota_propietario`) |
| M09 | DELETE | Eliminar un medicamento que ya fue recetado (lo impide la FK de receta). | Bloqueado (`fk_receta_medicamento`) |
| M10 | DELETE | Eliminar la consulta 7 (sin factura): sus recetas se borran en cascada. | OK, después = 0 |
| M11 | DELETE | Eliminar un empleado con rol de auxiliar: el rol se borra en cascada. | OK, después = 0 |
| M12 | DELETE | Eliminar una consulta que ya tiene factura (la FK de factura lo impide). | Bloqueado (`fk_factura_consulta`) |
| M13 | TRUNCATE | TRUNCATE sobre una tabla referenciada por una FK (no está permitido). | Bloqueado (`referenced by a FOREIGN KEY`) |

## Validación previa

El esquema, los datos, las consultas y las pruebas se ejecutaron en SQLite 3.45 con llaves foráneas activadas para comprobar la lógica de las restricciones. No sustituye la ejecución en SQL Server (los mensajes de error difieren; TRUNCATE solo existe en T-SQL).

## Referencias bibliográficas (APA)

- Beaulieu, A. (2020). *Learning SQL* (3rd ed.). O'Reilly Media.
- Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of database systems* (7th ed.). Pearson.
- Microsoft. (2025). *Transact-SQL reference (Database Engine)*. Microsoft Learn. https://learn.microsoft.com/sql/t-sql/
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7th ed.). McGraw-Hill Education.
