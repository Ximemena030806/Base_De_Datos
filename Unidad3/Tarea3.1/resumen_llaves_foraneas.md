# Resumen de llaves foráneas y acciones referenciales

| # | Tabla hija | FK | Tabla padre | ON DELETE |
|---|---|---|---|---|
| 1 | TELEFONO_PROPIETARIO | id_propietario | PROPIETARIO(id_propietario) | CASCADE |
| 2 | MASCOTA | id_propietario | PROPIETARIO(id_propietario) | RESTRICT |
| 3 | CANINO | id_mascota, tipo | MASCOTA(id_mascota, tipo) | CASCADE |
| 4 | FELINO | id_mascota, tipo | MASCOTA(id_mascota, tipo) | CASCADE |
| 5 | EXOTICO | id_mascota, tipo | MASCOTA(id_mascota, tipo) | CASCADE |
| 6 | VETERINARIO | id_empleado | EMPLEADO(id_empleado) | CASCADE |
| 7 | VETERINARIO_ESPECIALIDAD | id_empleado | VETERINARIO(id_empleado) | CASCADE |
| 8 | VETERINARIO_ESPECIALISTA | id_empleado | VETERINARIO(id_empleado) | CASCADE |
| 9 | GERENTE | id_empleado | EMPLEADO(id_empleado) | CASCADE |
| 10 | RECEPCIONISTA | id_empleado | EMPLEADO(id_empleado) | CASCADE |
| 11 | AUXILIAR | id_empleado | EMPLEADO(id_empleado) | CASCADE |
| 12 | CITA | id_mascota | MASCOTA(id_mascota) | RESTRICT |
| 13 | CITA | id_veterinario | VETERINARIO(id_empleado) | RESTRICT |
| 14 | CONSULTA | id_mascota | MASCOTA(id_mascota) | RESTRICT |
| 15 | CONSULTA | id_veterinario | VETERINARIO(id_empleado) | RESTRICT |
| 16 | RECETA | folio | CONSULTA(folio) | CASCADE |
| 17 | RECETA | id_medicamento | MEDICAMENTO(id_medicamento) | RESTRICT |
| 18 | APLICA | folio | CONSULTA(folio) | CASCADE |
| 19 | APLICA | id_vacuna | VACUNA(id_vacuna) | RESTRICT |
| 20 | SUMINISTRA | id_medicamento | MEDICAMENTO(id_medicamento) | CASCADE |
| 21 | SUMINISTRA | id_proveedor | PROVEEDOR(id_proveedor) | RESTRICT |
| 22 | FACTURA | folio | CONSULTA(folio) | RESTRICT |
