# Unidad 5 · Tarea 5.2: Resolución de consultas con álgebra relacional

**Materia:** Estructura de Datos
**Alumno:** Ximena Sánchez Lugo
**Docente:** Rubén Miguel Riojas Rodríguez
**Institución:** Instituto Tecnológico Superior de Monclova (ITSM)

## Contenido de la carpeta

| Archivo | Descripción |
|---|---|
| [`Tarea5.2_Consultas_Algebra_Relacional.pdf`](Tarea5.2_Consultas_Algebra_Relacional.pdf) | Reporte técnico: catálogo de 17 consultas con fórmulas, tablas intermedias y validaciones |
| [`simulador_algebra.py`](simulador_algebra.py) | Simulador de álgebra relacional en Python (σ, π, ρ, ×, ∪, ∩, −, ÷, ⋈, reuniones externas, G, π generalizada) |
| [`datos_veterinaria.json`](datos_veterinaria.json) | Datos de prueba del esquema normalizado (25 relaciones, 64 tuplas) |
| [`resultados_simulador.txt`](resultados_simulador.txt) | Salida completa del simulador (tablas intermedias y validación) |
| [`catalogo_consultas.md`](catalogo_consultas.md) | Catálogo en Markdown |
| [`consultas_algebra.sql`](consultas_algebra.sql) | SQL equivalente para SQL Server |
| [`relax_veterinaria.txt`](relax_veterinaria.txt) | Datos en formato de grupo para RelaX Calculator (formato sin probar) |

## Cómo ejecutar el simulador

Requiere Python 3.8 o superior (solo biblioteca estándar):

```bash
git clone <URL-DEL-REPOSITORIO>
cd Unidad5/Tarea5.2
python simulador_algebra.py
```

Imprime cada consulta, su fórmula, las tablas intermedias y la comparación contra la consulta SQL equivalente (ejecutada en SQLite). Resultado esperado: `Consultas validadas: 17/17`.

## Catálogo de consultas

| Consulta | Nivel | Requerimiento | Álgebra relacional | Filas | Validación |
|---|---|---|---|---|---|
| Q1 | Básica | Listar las citas cuyo estado es PROGRAMADA. | `σ_{estado='PROGRAMADA'}(cita)` | 1 | Coincide |
| Q2 | Básica | Mostrar el nombre y el precio de los medicamentos que cuestan más de 100. | `π_{nombre, precio}(σ_{precio>100}(medicamento))` | 2 | Coincide |
| Q3 | Intermedia | Mostrar el nombre de cada mascota junto con el nombre y apellido paterno de su propietario. | `π_{nombre, nombre_pila, ap_paterno}( π_{nombre, id_propietario}(mascota) ⋈ π_{id_propietario, nombre_pila, ap_paterno}(propietario) )` | 5 | Coincide |
| Q4 | Intermedia | Listar el folio y la fecha de cada consulta con el nombre de la mascota atendida y el nombre del veterinario que la realizó. | `π_{folio, fecha, nombre_mascota, veterinario}( π_{folio, fecha, id_mascota, id_veterinario}(consulta) ⋈ ρ_{nombre_mascota←nombre}(π_{id_mascota, nombre}(mascota)) ⋈ ρ_{id_veterinario←id_empleado, veterinario←nombre_pila}(π_{id_empleado, nombre_pila}(empleado)) )` | 3 | Coincide |
| Q5 | Intermedia | Obtener los pares (A, B) de medicamentos en los que A es más caro que B. | `π_{nombre_a, nombre_b}( ρ_{nombre_a←nombre, precio_a←precio}(π_{nombre, precio}(medicamento)) ⋈_{precio_a > precio_b} ρ_{nombre_b←nombre, precio_b←precio}(π_{nombre, precio}(medicamento)) )` | 3 | Coincide |
| Q6 | Intermedia | Listar los empleados que son gerentes o recepcionistas. | `π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(gerente) ∪ π_{id_empleado}(recepcionista) ) )` | 2 | Coincide |
| Q7 | Intermedia | Identificar a los empleados que son veterinarios y, al mismo tiempo, gerentes (especialización solapada). | `π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(veterinario) ∩ π_{id_empleado}(gerente) ) )` | 1 | Coincide |
| Q8 | Intermedia | Mostrar el nombre de las mascotas que nunca han tenido una consulta. | `π_{nombre}( mascota ⋈ ( π_{id_mascota}(mascota) − π_{id_mascota}(consulta) ) )` | 2 | Coincide |
| Q9 | Intermedia | Obtener los pares proveedor-medicamento posibles que todavía no existen en los suministros, con sus nombres. | `π_{razon_social, nombre}( ( ( π_{id_proveedor}(proveedor) × π_{id_medicamento}(medicamento) ) − π_{id_proveedor, id_medicamento}(suministra) ) ⋈ π_{id_proveedor, razon_social}(proveedor) ⋈ π_{id_medicamento, nombre}(medicamento) )` | 2 | Coincide |
| Q10 | Avanzada | Listar los propietarios que tienen al menos una mascota de cada una de las especies Perro y Gato. | `π_{nombre_pila, ap_paterno}( propietario ⋈ ( π_{id_propietario, id_especie}(mascota) ÷ π_{id_especie}(σ_{nombre='Perro' ∨ nombre='Gato'}(especie)) ) )` | 1 | Coincide |
| Q11 | Avanzada | Encontrar los medicamentos que son suministrados por todos los proveedores registrados. | `π_{nombre}( medicamento ⋈ ( π_{id_medicamento, id_proveedor}(suministra) ÷ π_{id_proveedor}(proveedor) ) )` | 1 | Coincide |
| Q12 | Avanzada | Contar cuántas consultas ha realizado cada veterinario, mostrando su nombre. | `π_{nombre_pila, num_consultas}( ρ_{id_veterinario←id_empleado}(π_{id_empleado, nombre_pila}(empleado)) ⋈ _{id_veterinario}G_{count(folio) → num_consultas}(consulta) )` | 2 | Coincide |
| Q13 | Avanzada | Obtener el número de medicamentos, su precio promedio y la existencia total. | `G_{count(id_medicamento) → num_medicamentos, avg(precio) → precio_promedio, sum(existencia) → existencia_total}(medicamento)` | 1 | Coincide |
| Q14 | Intermedia | Calcular el valor de inventario (existencia × precio) de cada medicamento. | `π_{nombre, existencia × precio → valor_inventario}(medicamento)` | 3 | Coincide |
| Q15 | Avanzada | Listar todas las mascotas con el folio de su consulta; las que no tienen consulta deben aparecer con folio nulo. | `π_{nombre, folio}( π_{id_mascota, nombre}(mascota) ⋈_L π_{id_mascota, folio}(consulta) )` | 5 | Coincide |
| Q16 | Avanzada | Mostrar, para cada empleado que es gerente o recepcionista, su departamento y su turno (nulos cuando no tiene ese rol). | `gerente ⋈_F recepcionista` | 2 | Coincide |
| Q17 | Avanzada | Mostrar a todos los gerentes con su turno de recepción, si también lo tienen. | `recepcionista ⋈_R gerente` | 1 | Coincide |

## Referencias bibliográficas (APA)

- Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377-387.
- Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of database systems* (7th ed.). Pearson.
- Garcia-Molina, H., Ullman, J. D., & Widom, J. (2009). *Database systems: The complete book* (2nd ed.). Pearson.
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7th ed.). McGraw-Hill Education.
