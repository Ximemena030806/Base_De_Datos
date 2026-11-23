# Dependencias funcionales de la hoja de consulta

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
