# Reglas de conversión E-R → relacional aplicadas

| Construcción E-R / E-RE | Regla de conversión | Aplicación en el proyecto |
|---|---|---|
| Entidad fuerte | Una tabla; atributos simples = columnas; identificador = PK | PROPIETARIO, MASCOTA, EMPLEADO, MEDICAMENTO, PROVEEDOR, VACUNA |
| Atributo compuesto | Se incluyen solo sus componentes (aplanado) | nombre → nombre_pila, ap_paterno, ap_materno; dirección → calle, colonia, cp |
| Atributo multivalorado | Tabla aparte con FK al dueño; PK = (FK, valor) | TELEFONO_PROPIETARIO; VETERINARIO_ESPECIALIDAD |
| Atributo derivado | No se almacena; se calcula con una vista | v_mascota.edad, v_empleado.antiguedad, v_factura.total |
| Relación 1:N | La PK del lado 1 se propaga como FK al lado N | Posee: MASCOTA.id_propietario |
| Relación 1:1 | FK con UNIQUE en una de las tablas | Genera: FACTURA.folio UNIQUE → CONSULTA |
| Relación N:M | Tabla propia con las PK de ambas entidades como FK y los atributos de la relación | SUMINISTRA, CITA (Agenda), CONSULTA (Atiende), RECETA, APLICA |
| Especialización disjunta | Tabla por subtipo (PK = FK) con discriminador | CANINO, FELINO, EXOTICO con MASCOTA.tipo |
| Especialización solapada | Tabla por rol sin discriminador exclusivo | VETERINARIO, GERENTE, RECEPCIONISTA, AUXILIAR |
| Jerarquía multinivel | Cadena de FK entre niveles | EMPLEADO ← VETERINARIO ← VETERINARIO_ESPECIALISTA |
| Agregación | La relación agregada se vuelve tabla con PK propia, que las demás relaciones referencian | CONSULTA(folio) referenciada por RECETA, APLICA y FACTURA |
