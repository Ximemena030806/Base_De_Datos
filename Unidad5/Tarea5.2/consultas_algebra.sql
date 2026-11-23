-- consultas_algebra.sql: SQL equivalente de cada expresión de álgebra relacional (SQL Server / T-SQL)
-- Ejecutar sobre la base 'veterinaria' recién creada (normalized_schema.sql + normalized_data.sql), ANTES de normalized_tests.sql
USE veterinaria;
GO

-- Q1 [Básica] Citas programadas
-- Requerimiento: Listar las citas cuyo estado es PROGRAMADA.
-- Álgebra: σ_{estado='PROGRAMADA'}(cita)
SELECT id_cita,id_mascota,id_veterinario,fecha_hora,motivo,estado FROM cita WHERE estado='PROGRAMADA';
GO

-- Q2 [Básica] Medicamentos caros
-- Requerimiento: Mostrar el nombre y el precio de los medicamentos que cuestan más de 100.
-- Álgebra: π_{nombre, precio}(σ_{precio>100}(medicamento))
SELECT DISTINCT nombre,precio FROM medicamento WHERE precio>100;
GO

-- Q3 [Intermedia] Mascotas con su propietario (reunión natural)
-- Requerimiento: Mostrar el nombre de cada mascota junto con el nombre y apellido paterno de su propietario.
-- Álgebra: π_{nombre, nombre_pila, ap_paterno}( π_{nombre, id_propietario}(mascota) ⋈ π_{id_propietario, nombre_pila, ap_paterno}(propietario) )
SELECT DISTINCT m.nombre,p.nombre_pila,p.ap_paterno FROM mascota m JOIN propietario p ON p.id_propietario=m.id_propietario;
GO

-- Q4 [Intermedia] Consultas con mascota y veterinario (reunión de tres relaciones y renombramiento)
-- Requerimiento: Listar el folio y la fecha de cada consulta con el nombre de la mascota atendida y el nombre del veterinario que la realizó.
-- Álgebra: π_{folio, fecha, nombre_mascota, veterinario}( π_{folio, fecha, id_mascota, id_veterinario}(consulta) ⋈ ρ_{nombre_mascota←nombre}(π_{id_mascota, nombre}(mascota)) ⋈ ρ_{id_veterinario←id_empleado, veterinario←nombre_pila}(π_{id_empleado, nombre_pila}(empleado)) )
SELECT DISTINCT c.folio,c.fecha,m.nombre AS nombre_mascota,e.nombre_pila AS veterinario FROM consulta c JOIN mascota m ON m.id_mascota=c.id_mascota JOIN empleado e ON e.id_empleado=c.id_veterinario;
GO

-- Q5 [Intermedia] Pares de medicamentos por precio (θ-join)
-- Requerimiento: Obtener los pares (A, B) de medicamentos en los que A es más caro que B.
-- Álgebra: π_{nombre_a, nombre_b}( ρ_{nombre_a←nombre, precio_a←precio}(π_{nombre, precio}(medicamento)) ⋈_{precio_a > precio_b} ρ_{nombre_b←nombre, precio_b←precio}(π_{nombre, precio}(medicamento)) )
SELECT DISTINCT a.nombre AS nombre_a,b.nombre AS nombre_b FROM medicamento a JOIN medicamento b ON a.precio>b.precio;
GO

-- Q6 [Intermedia] Empleados con rol de gerente o recepcionista (unión)
-- Requerimiento: Listar los empleados que son gerentes o recepcionistas.
-- Álgebra: π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(gerente) ∪ π_{id_empleado}(recepcionista) ) )
SELECT e.id_empleado,e.nombre_pila,e.ap_paterno FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM gerente UNION SELECT id_empleado FROM recepcionista);
GO

-- Q7 [Intermedia] Veterinarios que también son gerentes (intersección)
-- Requerimiento: Identificar a los empleados que son veterinarios y, al mismo tiempo, gerentes (especialización solapada).
-- Álgebra: π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(veterinario) ∩ π_{id_empleado}(gerente) ) )
SELECT e.id_empleado,e.nombre_pila,e.ap_paterno FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM veterinario INTERSECT SELECT id_empleado FROM gerente);
GO

-- Q8 [Intermedia] Mascotas sin consultas (diferencia)
-- Requerimiento: Mostrar el nombre de las mascotas que nunca han tenido una consulta.
-- Álgebra: π_{nombre}( mascota ⋈ ( π_{id_mascota}(mascota) − π_{id_mascota}(consulta) ) )
SELECT DISTINCT m.nombre FROM mascota m WHERE m.id_mascota NOT IN (SELECT id_mascota FROM consulta);
GO

-- Q9 [Intermedia] Pares proveedor-medicamento que no se suministran (producto cartesiano y diferencia)
-- Requerimiento: Obtener los pares proveedor-medicamento posibles que todavía no existen en los suministros, con sus nombres.
-- Álgebra: π_{razon_social, nombre}( ( ( π_{id_proveedor}(proveedor) × π_{id_medicamento}(medicamento) ) − π_{id_proveedor, id_medicamento}(suministra) ) ⋈ π_{id_proveedor, razon_social}(proveedor) ⋈ π_{id_medicamento, nombre}(medicamento) )
SELECT DISTINCT pr.razon_social,md.nombre FROM proveedor pr CROSS JOIN medicamento md WHERE NOT EXISTS (SELECT 1 FROM suministra s WHERE s.id_proveedor=pr.id_proveedor AND s.id_medicamento=md.id_medicamento);
GO

-- Q10 [Avanzada] Propietarios con mascotas de todas las especies dadas (división)
-- Requerimiento: Listar los propietarios que tienen al menos una mascota de cada una de las especies Perro y Gato.
-- Álgebra: π_{nombre_pila, ap_paterno}( propietario ⋈ ( π_{id_propietario, id_especie}(mascota) ÷ π_{id_especie}(σ_{nombre='Perro' ∨ nombre='Gato'}(especie)) ) )
SELECT p.nombre_pila,p.ap_paterno FROM propietario p WHERE NOT EXISTS (SELECT 1 FROM especie e WHERE e.nombre IN ('Perro','Gato') AND NOT EXISTS (SELECT 1 FROM mascota m WHERE m.id_propietario=p.id_propietario AND m.id_especie=e.id_especie));
GO

-- Q11 [Avanzada] Medicamentos surtidos por todos los proveedores (división)
-- Requerimiento: Encontrar los medicamentos que son suministrados por todos los proveedores registrados.
-- Álgebra: π_{nombre}( medicamento ⋈ ( π_{id_medicamento, id_proveedor}(suministra) ÷ π_{id_proveedor}(proveedor) ) )
SELECT md.nombre FROM medicamento md WHERE NOT EXISTS (SELECT 1 FROM proveedor pr WHERE NOT EXISTS (SELECT 1 FROM suministra s WHERE s.id_medicamento=md.id_medicamento AND s.id_proveedor=pr.id_proveedor));
GO

-- Q12 [Avanzada] Número de consultas por veterinario (agregación con agrupación)
-- Requerimiento: Contar cuántas consultas ha realizado cada veterinario, mostrando su nombre.
-- Álgebra: π_{nombre_pila, num_consultas}( ρ_{id_veterinario←id_empleado}(π_{id_empleado, nombre_pila}(empleado)) ⋈ _{id_veterinario}G_{count(folio) → num_consultas}(consulta) )
SELECT e.nombre_pila,COUNT(c.folio) AS num_consultas FROM consulta c JOIN empleado e ON e.id_empleado=c.id_veterinario GROUP BY c.id_veterinario,e.nombre_pila;
GO

-- Q13 [Avanzada] Estadísticas del inventario (agregación sin agrupación)
-- Requerimiento: Obtener el número de medicamentos, su precio promedio y la existencia total.
-- Álgebra: G_{count(id_medicamento) → num_medicamentos, avg(precio) → precio_promedio, sum(existencia) → existencia_total}(medicamento)
SELECT COUNT(id_medicamento) AS num_medicamentos,AVG(precio) AS precio_promedio,SUM(existencia) AS existencia_total FROM medicamento;
GO

-- Q14 [Intermedia] Valor del inventario por medicamento (proyección generalizada)
-- Requerimiento: Calcular el valor de inventario (existencia × precio) de cada medicamento.
-- Álgebra: π_{nombre, existencia × precio → valor_inventario}(medicamento)
SELECT DISTINCT nombre,existencia*precio AS valor_inventario FROM medicamento;
GO

-- Q15 [Avanzada] Mascotas con su consulta, incluso sin ninguna (reunión externa izquierda)
-- Requerimiento: Listar todas las mascotas con el folio de su consulta; las que no tienen consulta deben aparecer con folio nulo.
-- Álgebra: π_{nombre, folio}( π_{id_mascota, nombre}(mascota) ⋈_L π_{id_mascota, folio}(consulta) )
SELECT DISTINCT m.nombre,c.folio FROM mascota m LEFT JOIN consulta c ON c.id_mascota=m.id_mascota;
GO

-- Q16 [Avanzada] Roles administrativos de los empleados (reunión externa completa)
-- Requerimiento: Mostrar, para cada empleado que es gerente o recepcionista, su departamento y su turno (nulos cuando no tiene ese rol).
-- Álgebra: gerente ⋈_F recepcionista
SELECT COALESCE(g.id_empleado,r.id_empleado) AS id_empleado,g.departamento,r.turno FROM gerente g FULL OUTER JOIN recepcionista r ON r.id_empleado=g.id_empleado;
GO

-- Q17 [Avanzada] Gerentes y su turno de recepción (reunión externa derecha)
-- Requerimiento: Mostrar a todos los gerentes con su turno de recepción, si también lo tienen.
-- Álgebra: recepcionista ⋈_R gerente
SELECT g.id_empleado,r.turno,g.departamento FROM recepcionista r RIGHT JOIN gerente g ON g.id_empleado=r.id_empleado;
GO

