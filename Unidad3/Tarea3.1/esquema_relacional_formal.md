# Esquema relacional formal

Notación: **negrita subrayada no disponible en Markdown**, por eso la PK se marca con `PK` y las llaves foráneas con `FK`.

**PROPIETARIO**(__id_propietario__, nombre_pila, ap_paterno, ap_materno, calle, colonia, cp, correo)  
- PK: (id_propietario)
- UNIQUE: (correo)

**TELEFONO_PROPIETARIO**(__id_propietario__, __telefono__)  
- PK: (id_propietario, telefono)
- FK: (id_propietario) → PROPIETARIO(id_propietario) · ON DELETE CASCADE

**MASCOTA**(__id_mascota__, nombre, especie, raza, fecha_nacimiento, peso, tipo, *id_propietario*)  
- PK: (id_mascota)
- FK: (id_propietario) → PROPIETARIO(id_propietario) · ON DELETE RESTRICT
- UNIQUE: (id_mascota, tipo)

**CANINO**(__id_mascota__, *tipo*, tamano, nivel_adiestramiento)  
- PK: (id_mascota)
- FK: (id_mascota, tipo) → MASCOTA(id_mascota, tipo) · ON DELETE CASCADE

**FELINO**(__id_mascota__, *tipo*, pelaje, esterilizado)  
- PK: (id_mascota)
- FK: (id_mascota, tipo) → MASCOTA(id_mascota, tipo) · ON DELETE CASCADE

**EXOTICO**(__id_mascota__, *tipo*, tipo_habitat, requiere_permiso)  
- PK: (id_mascota)
- FK: (id_mascota, tipo) → MASCOTA(id_mascota, tipo) · ON DELETE CASCADE

**EMPLEADO**(__id_empleado__, nombre_pila, ap_paterno, ap_materno, rfc, fecha_ingreso)  
- PK: (id_empleado)
- UNIQUE: (rfc)

**VETERINARIO**(__id_empleado__, cedula_profesional)  
- PK: (id_empleado)
- FK: (id_empleado) → EMPLEADO(id_empleado) · ON DELETE CASCADE
- UNIQUE: (cedula_profesional)

**VETERINARIO_ESPECIALIDAD**(__id_empleado__, __especialidad__)  
- PK: (id_empleado, especialidad)
- FK: (id_empleado) → VETERINARIO(id_empleado) · ON DELETE CASCADE

**VETERINARIO_ESPECIALISTA**(__id_empleado__, subespecialidad)  
- PK: (id_empleado)
- FK: (id_empleado) → VETERINARIO(id_empleado) · ON DELETE CASCADE

**GERENTE**(__id_empleado__, departamento)  
- PK: (id_empleado)
- FK: (id_empleado) → EMPLEADO(id_empleado) · ON DELETE CASCADE

**RECEPCIONISTA**(__id_empleado__, turno)  
- PK: (id_empleado)
- FK: (id_empleado) → EMPLEADO(id_empleado) · ON DELETE CASCADE

**AUXILIAR**(__id_empleado__, area_asignada)  
- PK: (id_empleado)
- FK: (id_empleado) → EMPLEADO(id_empleado) · ON DELETE CASCADE

**CITA**(__id_cita__, *id_mascota*, *id_veterinario*, fecha_hora, motivo, estado)  
- PK: (id_cita)
- FK: (id_mascota) → MASCOTA(id_mascota) · ON DELETE RESTRICT
- FK: (id_veterinario) → VETERINARIO(id_empleado) · ON DELETE RESTRICT
- UNIQUE: (id_veterinario, fecha_hora)

**CONSULTA**(__folio__, *id_mascota*, *id_veterinario*, fecha, diagnostico, observaciones)  
- PK: (folio)
- FK: (id_mascota) → MASCOTA(id_mascota) · ON DELETE RESTRICT
- FK: (id_veterinario) → VETERINARIO(id_empleado) · ON DELETE RESTRICT

**MEDICAMENTO**(__id_medicamento__, nombre, presentacion, existencia, precio)  
- PK: (id_medicamento)

**PROVEEDOR**(__id_proveedor__, razon_social, contacto)  
- PK: (id_proveedor)

**VACUNA**(__id_vacuna__, nombre, enfermedad_prevenida)  
- PK: (id_vacuna)

**RECETA**(__folio__, __id_medicamento__, dosis, duracion)  
- PK: (folio, id_medicamento)
- FK: (folio) → CONSULTA(folio) · ON DELETE CASCADE
- FK: (id_medicamento) → MEDICAMENTO(id_medicamento) · ON DELETE RESTRICT

**APLICA**(__folio__, __id_vacuna__, lote, caducidad)  
- PK: (folio, id_vacuna)
- FK: (folio) → CONSULTA(folio) · ON DELETE CASCADE
- FK: (id_vacuna) → VACUNA(id_vacuna) · ON DELETE RESTRICT

**SUMINISTRA**(__id_medicamento__, __id_proveedor__)  
- PK: (id_medicamento, id_proveedor)
- FK: (id_medicamento) → MEDICAMENTO(id_medicamento) · ON DELETE CASCADE
- FK: (id_proveedor) → PROVEEDOR(id_proveedor) · ON DELETE RESTRICT

**FACTURA**(__no_factura__, *folio*, fecha, subtotal)  
- PK: (no_factura)
- FK: (folio) → CONSULTA(folio) · ON DELETE RESTRICT
- UNIQUE: (folio)

