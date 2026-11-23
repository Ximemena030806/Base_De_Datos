# Catálogo de consultas en álgebra relacional

## Q1. Citas programadas (Básica)

**Requerimiento:** Listar las citas cuyo estado es PROGRAMADA.

**Álgebra relacional:** `σ_{estado='PROGRAMADA'}(cita)`

**SQL equivalente:**

```sql
SELECT id_cita,id_mascota,id_veterinario,fecha_hora,motivo,estado FROM cita WHERE estado='PROGRAMADA'
```

**R1 = `σ_{estado='PROGRAMADA'}(cita)`**

| id_cita | id_mascota | id_veterinario | fecha_hora | motivo | estado |
|---|---|---|---|---|---|
| 3 | 2 | 1 | 2026-11-12 09:00:00 | Vacunación | PROGRAMADA |

**Validación contra SQL:** coincide (1 fila(s)).

## Q2. Medicamentos caros (Básica)

**Requerimiento:** Mostrar el nombre y el precio de los medicamentos que cuestan más de 100.

**Álgebra relacional:** `π_{nombre, precio}(σ_{precio>100}(medicamento))`

**SQL equivalente:**

```sql
SELECT DISTINCT nombre,precio FROM medicamento WHERE precio>100
```

**R1 = `σ_{precio>100}(medicamento)`**

| id_medicamento | nombre | presentacion | existencia | precio |
|---|---|---|---|---|
| 1 | Amoxicilina | Tabletas 250 mg | 50 | 120 |
| 3 | Ivermectina | Inyectable 50 ml | 20 | 210 |

**R2 = `π_{nombre, precio}(R1)`**

| nombre | precio |
|---|---|
| Amoxicilina | 120 |
| Ivermectina | 210 |

**Validación contra SQL:** coincide (2 fila(s)).

## Q3. Mascotas con su propietario (reunión natural) (Intermedia)

**Requerimiento:** Mostrar el nombre de cada mascota junto con el nombre y apellido paterno de su propietario.

**Álgebra relacional:** `π_{nombre, nombre_pila, ap_paterno}( π_{nombre, id_propietario}(mascota) ⋈ π_{id_propietario, nombre_pila, ap_paterno}(propietario) )`

**SQL equivalente:**

```sql
SELECT DISTINCT m.nombre,p.nombre_pila,p.ap_paterno FROM mascota m JOIN propietario p ON p.id_propietario=m.id_propietario
```

**R1 = `π_{nombre, id_propietario}(mascota)`**

| nombre | id_propietario |
|---|---|
| Rex | 1 |
| Luna | 2 |
| Michi | 1 |
| Nala | 3 |
| Kiwi | 3 |

**R2 = `π_{id_propietario, nombre_pila, ap_paterno}(propietario)`**

| id_propietario | nombre_pila | ap_paterno |
|---|---|---|
| 1 | Laura | Gómez |
| 2 | Carlos | Ramírez |
| 3 | Ana | Treviño |

**R3 = `R1 ⋈ R2`**

| nombre | id_propietario | nombre_pila | ap_paterno |
|---|---|---|---|
| Rex | 1 | Laura | Gómez |
| Luna | 2 | Carlos | Ramírez |
| Michi | 1 | Laura | Gómez |
| Nala | 3 | Ana | Treviño |
| Kiwi | 3 | Ana | Treviño |

**R4 = `π_{nombre, nombre_pila, ap_paterno}(R3)`**

| nombre | nombre_pila | ap_paterno |
|---|---|---|
| Rex | Laura | Gómez |
| Luna | Carlos | Ramírez |
| Michi | Laura | Gómez |
| Nala | Ana | Treviño |
| Kiwi | Ana | Treviño |

**Validación contra SQL:** coincide (5 fila(s)).

## Q4. Consultas con mascota y veterinario (reunión de tres relaciones y renombramiento) (Intermedia)

**Requerimiento:** Listar el folio y la fecha de cada consulta con el nombre de la mascota atendida y el nombre del veterinario que la realizó.

**Álgebra relacional:** `π_{folio, fecha, nombre_mascota, veterinario}( π_{folio, fecha, id_mascota, id_veterinario}(consulta) ⋈ ρ_{nombre_mascota←nombre}(π_{id_mascota, nombre}(mascota)) ⋈ ρ_{id_veterinario←id_empleado, veterinario←nombre_pila}(π_{id_empleado, nombre_pila}(empleado)) )`

**SQL equivalente:**

```sql
SELECT DISTINCT c.folio,c.fecha,m.nombre AS nombre_mascota,e.nombre_pila AS veterinario FROM consulta c JOIN mascota m ON m.id_mascota=c.id_mascota JOIN empleado e ON e.id_empleado=c.id_veterinario
```

**R1 = `π_{folio, fecha, id_mascota, id_veterinario}(consulta)`**

| folio | fecha | id_mascota | id_veterinario |
|---|---|---|---|
| 1 | 2026-10-05 | 1 | 1 |
| 2 | 2026-10-06 | 3 | 2 |
| 3 | 2026-10-20 | 2 | 1 |

**R2 = `ρ_{nombre_mascota←nombre}(π_{id_mascota, nombre}(mascota))`**

| id_mascota | nombre_mascota |
|---|---|
| 1 | Rex |
| 2 | Luna |
| 3 | Michi |
| 4 | Nala |
| 5 | Kiwi |

**R3 = `ρ_{id_veterinario←id_empleado, veterinario←nombre_pila}(π_{id_empleado, nombre_pila}(empleado))`**

| id_veterinario | veterinario |
|---|---|
| 1 | Miguel |
| 2 | Sofía |
| 3 | Daniela |
| 4 | Jorge |

**R4 = `R1 ⋈ R2`**

| folio | fecha | id_mascota | id_veterinario | nombre_mascota |
|---|---|---|---|---|
| 1 | 2026-10-05 | 1 | 1 | Rex |
| 2 | 2026-10-06 | 3 | 2 | Michi |
| 3 | 2026-10-20 | 2 | 1 | Luna |

**R5 = `R4 ⋈ R3`**

| folio | fecha | id_mascota | id_veterinario | nombre_mascota | veterinario |
|---|---|---|---|---|---|
| 1 | 2026-10-05 | 1 | 1 | Rex | Miguel |
| 2 | 2026-10-06 | 3 | 2 | Michi | Sofía |
| 3 | 2026-10-20 | 2 | 1 | Luna | Miguel |

**R6 = `π_{folio, fecha, nombre_mascota, veterinario}(R5)`**

| folio | fecha | nombre_mascota | veterinario |
|---|---|---|---|
| 1 | 2026-10-05 | Rex | Miguel |
| 2 | 2026-10-06 | Michi | Sofía |
| 3 | 2026-10-20 | Luna | Miguel |

**Validación contra SQL:** coincide (3 fila(s)).

## Q5. Pares de medicamentos por precio (θ-join) (Intermedia)

**Requerimiento:** Obtener los pares (A, B) de medicamentos en los que A es más caro que B.

**Álgebra relacional:** `π_{nombre_a, nombre_b}( ρ_{nombre_a←nombre, precio_a←precio}(π_{nombre, precio}(medicamento)) ⋈_{precio_a > precio_b} ρ_{nombre_b←nombre, precio_b←precio}(π_{nombre, precio}(medicamento)) )`

**SQL equivalente:**

```sql
SELECT DISTINCT a.nombre AS nombre_a,b.nombre AS nombre_b FROM medicamento a JOIN medicamento b ON a.precio>b.precio
```

**R1 = `ρ_{nombre_a←nombre, precio_a←precio}(π_{nombre, precio}(medicamento))`**

| nombre_a | precio_a |
|---|---|
| Amoxicilina | 120 |
| Meloxicam | 95.50 |
| Ivermectina | 210 |

**R2 = `ρ_{nombre_b←nombre, precio_b←precio}(π_{nombre, precio}(medicamento))`**

| nombre_b | precio_b |
|---|---|
| Amoxicilina | 120 |
| Meloxicam | 95.50 |
| Ivermectina | 210 |

**R3 = `R1 ⋈_{precio_a > precio_b} R2`**

| nombre_a | precio_a | nombre_b | precio_b |
|---|---|---|---|
| Amoxicilina | 120 | Meloxicam | 95.50 |
| Ivermectina | 210 | Amoxicilina | 120 |
| Ivermectina | 210 | Meloxicam | 95.50 |

**R4 = `π_{nombre_a, nombre_b}(R3)`**

| nombre_a | nombre_b |
|---|---|
| Amoxicilina | Meloxicam |
| Ivermectina | Amoxicilina |
| Ivermectina | Meloxicam |

**Validación contra SQL:** coincide (3 fila(s)).

## Q6. Empleados con rol de gerente o recepcionista (unión) (Intermedia)

**Requerimiento:** Listar los empleados que son gerentes o recepcionistas.

**Álgebra relacional:** `π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(gerente) ∪ π_{id_empleado}(recepcionista) ) )`

**SQL equivalente:**

```sql
SELECT e.id_empleado,e.nombre_pila,e.ap_paterno FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM gerente UNION SELECT id_empleado FROM recepcionista)
```

**R1 = `π_{id_empleado}(gerente)`**

| id_empleado |
|---|
| 2 |

**R2 = `π_{id_empleado}(recepcionista)`**

| id_empleado |
|---|
| 3 |

**R3 = `R1 ∪ R2`**

| id_empleado |
|---|
| 2 |
| 3 |

**R4 = `empleado ⋈ R3`**

| id_empleado | nombre_pila | ap_paterno | ap_materno | rfc | fecha_ingreso |
|---|---|---|---|---|---|
| 2 | Sofía | Martínez | Lara | MALS900505CD2 | 2018-08-15 |
| 3 | Daniela | Cruz | Ibarra | CUID950710EF3 | 2020-01-10 |

**R5 = `π_{id_empleado, nombre_pila, ap_paterno}(R4)`**

| id_empleado | nombre_pila | ap_paterno |
|---|---|---|
| 2 | Sofía | Martínez |
| 3 | Daniela | Cruz |

**Validación contra SQL:** coincide (2 fila(s)).

## Q7. Veterinarios que también son gerentes (intersección) (Intermedia)

**Requerimiento:** Identificar a los empleados que son veterinarios y, al mismo tiempo, gerentes (especialización solapada).

**Álgebra relacional:** `π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(veterinario) ∩ π_{id_empleado}(gerente) ) )`

**SQL equivalente:**

```sql
SELECT e.id_empleado,e.nombre_pila,e.ap_paterno FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM veterinario INTERSECT SELECT id_empleado FROM gerente)
```

**R1 = `π_{id_empleado}(veterinario)`**

| id_empleado |
|---|
| 1 |
| 2 |

**R2 = `π_{id_empleado}(gerente)`**

| id_empleado |
|---|
| 2 |

**R3 = `R1 ∩ R2`**

| id_empleado |
|---|
| 2 |

**R4 = `empleado ⋈ R3`**

| id_empleado | nombre_pila | ap_paterno | ap_materno | rfc | fecha_ingreso |
|---|---|---|---|---|---|
| 2 | Sofía | Martínez | Lara | MALS900505CD2 | 2018-08-15 |

**R5 = `π_{id_empleado, nombre_pila, ap_paterno}(R4)`**

| id_empleado | nombre_pila | ap_paterno |
|---|---|---|
| 2 | Sofía | Martínez |

**Validación contra SQL:** coincide (1 fila(s)).

## Q8. Mascotas sin consultas (diferencia) (Intermedia)

**Requerimiento:** Mostrar el nombre de las mascotas que nunca han tenido una consulta.

**Álgebra relacional:** `π_{nombre}( mascota ⋈ ( π_{id_mascota}(mascota) − π_{id_mascota}(consulta) ) )`

**SQL equivalente:**

```sql
SELECT DISTINCT m.nombre FROM mascota m WHERE m.id_mascota NOT IN (SELECT id_mascota FROM consulta)
```

**R1 = `π_{id_mascota}(mascota)`**

| id_mascota |
|---|
| 1 |
| 2 |
| 3 |
| 4 |
| 5 |

**R2 = `π_{id_mascota}(consulta)`**

| id_mascota |
|---|
| 1 |
| 3 |
| 2 |

**R3 = `R1 − R2`**

| id_mascota |
|---|
| 4 |
| 5 |

**R4 = `mascota ⋈ R3`**

| id_mascota | nombre | id_especie | id_raza | fecha_nacimiento | peso | tipo | id_propietario |
|---|---|---|---|---|---|---|---|
| 4 | Nala | 2 | 4 | 2022-01-10 | 3.80 | FELINO | 3 |
| 5 | Kiwi | 3 | 5 | 2023-05-05 | 0.04 | EXOTICO | 3 |

**R5 = `π_{nombre}(R4)`**

| nombre |
|---|
| Nala |
| Kiwi |

**Validación contra SQL:** coincide (2 fila(s)).

## Q9. Pares proveedor-medicamento que no se suministran (producto cartesiano y diferencia) (Intermedia)

**Requerimiento:** Obtener los pares proveedor-medicamento posibles que todavía no existen en los suministros, con sus nombres.

**Álgebra relacional:** `π_{razon_social, nombre}( ( ( π_{id_proveedor}(proveedor) × π_{id_medicamento}(medicamento) ) − π_{id_proveedor, id_medicamento}(suministra) ) ⋈ π_{id_proveedor, razon_social}(proveedor) ⋈ π_{id_medicamento, nombre}(medicamento) )`

**SQL equivalente:**

```sql
SELECT DISTINCT pr.razon_social,md.nombre FROM proveedor pr CROSS JOIN medicamento md WHERE NOT EXISTS (SELECT 1 FROM suministra s WHERE s.id_proveedor=pr.id_proveedor AND s.id_medicamento=md.id_medicamento)
```

**R1 = `π_{id_proveedor}(proveedor)`**

| id_proveedor |
|---|
| 1 |
| 2 |

**R2 = `π_{id_medicamento}(medicamento)`**

| id_medicamento |
|---|
| 1 |
| 2 |
| 3 |

**R3 = `R1 × R2`**

| id_proveedor | id_medicamento |
|---|---|
| 1 | 1 |
| 1 | 2 |
| 1 | 3 |
| 2 | 1 |
| 2 | 2 |
| 2 | 3 |

**R4 = `π_{id_proveedor, id_medicamento}(suministra)`**

| id_proveedor | id_medicamento |
|---|---|
| 1 | 1 |
| 1 | 2 |
| 2 | 2 |
| 2 | 3 |

**R5 = `R3 − R4`**

| id_proveedor | id_medicamento |
|---|---|
| 1 | 3 |
| 2 | 1 |

**R6 = `R5 ⋈ π_{id_proveedor, razon_social}(proveedor) ⋈ π_{id_medicamento, nombre}(medicamento)`**

| id_proveedor | id_medicamento | razon_social | nombre |
|---|---|---|---|
| 1 | 3 | Distribuidora Vet del Norte SA de CV | Ivermectina |
| 2 | 1 | Farmacéutica Animal Monclova | Amoxicilina |

**R7 = `π_{razon_social, nombre}(R6)`**

| razon_social | nombre |
|---|---|
| Distribuidora Vet del Norte SA de CV | Ivermectina |
| Farmacéutica Animal Monclova | Amoxicilina |

**Validación contra SQL:** coincide (2 fila(s)).

## Q10. Propietarios con mascotas de todas las especies dadas (división) (Avanzada)

**Requerimiento:** Listar los propietarios que tienen al menos una mascota de cada una de las especies Perro y Gato.

**Álgebra relacional:** `π_{nombre_pila, ap_paterno}( propietario ⋈ ( π_{id_propietario, id_especie}(mascota) ÷ π_{id_especie}(σ_{nombre='Perro' ∨ nombre='Gato'}(especie)) ) )`

**SQL equivalente:**

```sql
SELECT p.nombre_pila,p.ap_paterno FROM propietario p WHERE NOT EXISTS (SELECT 1 FROM especie e WHERE e.nombre IN ('Perro','Gato') AND NOT EXISTS (SELECT 1 FROM mascota m WHERE m.id_propietario=p.id_propietario AND m.id_especie=e.id_especie))
```

**R1 = `π_{id_propietario, id_especie}(mascota)`**

| id_propietario | id_especie |
|---|---|
| 1 | 1 |
| 2 | 1 |
| 1 | 2 |
| 3 | 2 |
| 3 | 3 |

**R2 = `π_{id_especie}(σ_{nombre='Perro' ∨ nombre='Gato'}(especie))`**

| id_especie |
|---|
| 1 |
| 2 |

**R3 = `R1 ÷ R2`**

| id_propietario |
|---|
| 1 |

**R4 = `propietario ⋈ R3`**

| id_propietario | nombre_pila | ap_paterno | ap_materno | calle | colonia | cp | correo |
|---|---|---|---|---|---|---|---|
| 1 | Laura | Gómez | Pérez | Av. Hidalgo 120 | Centro | 25700 | laura.gomez@mail.com |

**R5 = `π_{nombre_pila, ap_paterno}(R4)`**

| nombre_pila | ap_paterno |
|---|---|
| Laura | Gómez |

**Validación contra SQL:** coincide (1 fila(s)).

## Q11. Medicamentos surtidos por todos los proveedores (división) (Avanzada)

**Requerimiento:** Encontrar los medicamentos que son suministrados por todos los proveedores registrados.

**Álgebra relacional:** `π_{nombre}( medicamento ⋈ ( π_{id_medicamento, id_proveedor}(suministra) ÷ π_{id_proveedor}(proveedor) ) )`

**SQL equivalente:**

```sql
SELECT md.nombre FROM medicamento md WHERE NOT EXISTS (SELECT 1 FROM proveedor pr WHERE NOT EXISTS (SELECT 1 FROM suministra s WHERE s.id_medicamento=md.id_medicamento AND s.id_proveedor=pr.id_proveedor))
```

**R1 = `π_{id_medicamento, id_proveedor}(suministra)`**

| id_medicamento | id_proveedor |
|---|---|
| 1 | 1 |
| 2 | 1 |
| 2 | 2 |
| 3 | 2 |

**R2 = `π_{id_proveedor}(proveedor)`**

| id_proveedor |
|---|
| 1 |
| 2 |

**R3 = `R1 ÷ R2`**

| id_medicamento |
|---|
| 2 |

**R4 = `medicamento ⋈ R3`**

| id_medicamento | nombre | presentacion | existencia | precio |
|---|---|---|---|---|
| 2 | Meloxicam | Suspensión 10 ml | 30 | 95.50 |

**R5 = `π_{nombre}(R4)`**

| nombre |
|---|
| Meloxicam |

**Validación contra SQL:** coincide (1 fila(s)).

## Q12. Número de consultas por veterinario (agregación con agrupación) (Avanzada)

**Requerimiento:** Contar cuántas consultas ha realizado cada veterinario, mostrando su nombre.

**Álgebra relacional:** `π_{nombre_pila, num_consultas}( ρ_{id_veterinario←id_empleado}(π_{id_empleado, nombre_pila}(empleado)) ⋈ _{id_veterinario}G_{count(folio) → num_consultas}(consulta) )`

**SQL equivalente:**

```sql
SELECT e.nombre_pila,COUNT(c.folio) AS num_consultas FROM consulta c JOIN empleado e ON e.id_empleado=c.id_veterinario GROUP BY c.id_veterinario,e.nombre_pila
```

**R1 = `_{id_veterinario}G_{count(folio) → num_consultas}(consulta)`**

| id_veterinario | num_consultas |
|---|---|
| 1 | 2 |
| 2 | 1 |

**R2 = `ρ_{id_veterinario←id_empleado}(π_{id_empleado, nombre_pila}(empleado))`**

| id_veterinario | nombre_pila |
|---|---|
| 1 | Miguel |
| 2 | Sofía |
| 3 | Daniela |
| 4 | Jorge |

**R3 = `R2 ⋈ R1`**

| id_veterinario | nombre_pila | num_consultas |
|---|---|---|
| 1 | Miguel | 2 |
| 2 | Sofía | 1 |

**R4 = `π_{nombre_pila, num_consultas}(R3)`**

| nombre_pila | num_consultas |
|---|---|
| Miguel | 2 |
| Sofía | 1 |

**Validación contra SQL:** coincide (2 fila(s)).

## Q13. Estadísticas del inventario (agregación sin agrupación) (Avanzada)

**Requerimiento:** Obtener el número de medicamentos, su precio promedio y la existencia total.

**Álgebra relacional:** `G_{count(id_medicamento) → num_medicamentos, avg(precio) → precio_promedio, sum(existencia) → existencia_total}(medicamento)`

**SQL equivalente:**

```sql
SELECT COUNT(id_medicamento) AS num_medicamentos,AVG(precio) AS precio_promedio,SUM(existencia) AS existencia_total FROM medicamento
```

**R1 = `G_{count(id_medicamento) → num_medicamentos, avg(precio) → precio_promedio, sum(existencia) → existencia_total}(medicamento)`**

| num_medicamentos | precio_promedio | existencia_total |
|---|---|---|
| 3 | 141.83 | 100 |

**Validación contra SQL:** coincide (1 fila(s)).

## Q14. Valor del inventario por medicamento (proyección generalizada) (Intermedia)

**Requerimiento:** Calcular el valor de inventario (existencia × precio) de cada medicamento.

**Álgebra relacional:** `π_{nombre, existencia × precio → valor_inventario}(medicamento)`

**SQL equivalente:**

```sql
SELECT DISTINCT nombre,existencia*precio AS valor_inventario FROM medicamento
```

**R1 = `π_{nombre, existencia × precio → valor_inventario}(medicamento)`**

| nombre | valor_inventario |
|---|---|
| Amoxicilina | 6000 |
| Meloxicam | 2865.00 |
| Ivermectina | 4200 |

**Validación contra SQL:** coincide (3 fila(s)).

## Q15. Mascotas con su consulta, incluso sin ninguna (reunión externa izquierda) (Avanzada)

**Requerimiento:** Listar todas las mascotas con el folio de su consulta; las que no tienen consulta deben aparecer con folio nulo.

**Álgebra relacional:** `π_{nombre, folio}( π_{id_mascota, nombre}(mascota) ⋈_L π_{id_mascota, folio}(consulta) )`

**SQL equivalente:**

```sql
SELECT DISTINCT m.nombre,c.folio FROM mascota m LEFT JOIN consulta c ON c.id_mascota=m.id_mascota
```

**R1 = `π_{id_mascota, nombre}(mascota)`**

| id_mascota | nombre |
|---|---|
| 1 | Rex |
| 2 | Luna |
| 3 | Michi |
| 4 | Nala |
| 5 | Kiwi |

**R2 = `π_{id_mascota, folio}(consulta)`**

| id_mascota | folio |
|---|---|
| 1 | 1 |
| 3 | 2 |
| 2 | 3 |

**R3 = `R1 ⋈_L R2`**

| id_mascota | nombre | folio |
|---|---|---|
| 1 | Rex | 1 |
| 2 | Luna | 3 |
| 3 | Michi | 2 |
| 4 | Nala | NULL |
| 5 | Kiwi | NULL |

**R4 = `π_{nombre, folio}(R3)`**

| nombre | folio |
|---|---|
| Rex | 1 |
| Luna | 3 |
| Michi | 2 |
| Nala | NULL |
| Kiwi | NULL |

**Validación contra SQL:** coincide (5 fila(s)).

## Q16. Roles administrativos de los empleados (reunión externa completa) (Avanzada)

**Requerimiento:** Mostrar, para cada empleado que es gerente o recepcionista, su departamento y su turno (nulos cuando no tiene ese rol).

**Álgebra relacional:** `gerente ⋈_F recepcionista`

**SQL equivalente:**

```sql
SELECT COALESCE(g.id_empleado,r.id_empleado) AS id_empleado,g.departamento,r.turno FROM gerente g FULL OUTER JOIN recepcionista r ON r.id_empleado=g.id_empleado
```

**R1 = `gerente ⋈_F recepcionista`**

| id_empleado | departamento | turno |
|---|---|---|
| 2 | Administración | NULL |
| 3 | NULL | MATUTINO |

**Validación contra SQL:** coincide (2 fila(s)).

## Q17. Gerentes y su turno de recepción (reunión externa derecha) (Avanzada)

**Requerimiento:** Mostrar a todos los gerentes con su turno de recepción, si también lo tienen.

**Álgebra relacional:** `recepcionista ⋈_R gerente`

**SQL equivalente:**

```sql
SELECT g.id_empleado,r.turno,g.departamento FROM recepcionista r RIGHT JOIN gerente g ON g.id_empleado=r.id_empleado
```

**R1 = `recepcionista ⋈_R gerente`**

| id_empleado | turno | departamento |
|---|---|---|
| 2 | NULL | Administración |

**Validación contra SQL:** coincide (1 fila(s)).

