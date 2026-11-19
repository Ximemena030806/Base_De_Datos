# Esquema tabular: llaves primarias y foráneas

## PROPIETARIO
_Propietario. Origen E-R: Entidad fuerte; atributos compuestos nombre y dirección aplanados_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_propietario | d_id | INT | PK |
| nombre_pila | d_nombre | VARCHAR(60) | NOT NULL |
| ap_paterno | d_nombre | VARCHAR(60) | NOT NULL |
| ap_materno | d_nombre | VARCHAR(60) | — |
| calle | d_texto | VARCHAR(255) | NOT NULL |
| colonia | d_nombre | VARCHAR(60) | NOT NULL |
| cp | d_cp | CHAR(5) | NOT NULL |
| correo | d_correo | VARCHAR(100) | UNIQUE |


## TELEFONO_PROPIETARIO
_Teléfonos del propietario. Origen E-R: Atributo multivalorado {teléfono}_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_propietario | d_id | INT | PK; FK → PROPIETARIO.id_propietario |
| telefono | d_tel | VARCHAR(15) | PK |


## MASCOTA
_Mascota (superentidad). Origen E-R: Entidad fuerte; relación Posee (1:N) → FK id_propietario; /edad/ no se almacena_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_mascota | d_id | INT | PK |
| nombre | d_nombre | VARCHAR(60) | NOT NULL |
| especie | d_nombre | VARCHAR(60) | NOT NULL |
| raza | d_nombre | VARCHAR(60) | — |
| fecha_nacimiento | d_fecha | DATE | NOT NULL |
| peso | d_peso | DECIMAL(6,2) | — |
| tipo | d_tipo_mascota | VARCHAR(10) | NOT NULL |
| id_propietario | d_id | INT | FK → PROPIETARIO.id_propietario; NOT NULL |

- UNIQUE (id_mascota, tipo)

## CANINO
_Canino (subentidad de Mascota). Origen E-R: Especialización disjunta: tabla por subtipo con PK=FK y discriminador_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_mascota | d_id | INT | PK; FK → MASCOTA.id_mascota |
| tipo | d_tipo_mascota | VARCHAR(10) | FK → MASCOTA.tipo; NOT NULL; DEFAULT 'CANINO' |
| tamano | d_tamano | VARCHAR(10) | NOT NULL |
| nivel_adiestramiento | d_nombre | VARCHAR(60) | — |

- CHECK (tipo = 'CANINO')
- FK compuesta (id_mascota, tipo) → MASCOTA(id_mascota, tipo)

## FELINO
_Felino (subentidad de Mascota). Origen E-R: Especialización disjunta: tabla por subtipo con PK=FK y discriminador_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_mascota | d_id | INT | PK; FK → MASCOTA.id_mascota |
| tipo | d_tipo_mascota | VARCHAR(10) | FK → MASCOTA.tipo; NOT NULL; DEFAULT 'FELINO' |
| pelaje | d_nombre | VARCHAR(60) | — |
| esterilizado | d_bool | BOOLEAN | NOT NULL; DEFAULT FALSE |

- CHECK (tipo = 'FELINO')
- FK compuesta (id_mascota, tipo) → MASCOTA(id_mascota, tipo)

## EXOTICO
_Exótico (subentidad de Mascota). Origen E-R: Especialización disjunta: tabla por subtipo con PK=FK y discriminador_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_mascota | d_id | INT | PK; FK → MASCOTA.id_mascota |
| tipo | d_tipo_mascota | VARCHAR(10) | FK → MASCOTA.tipo; NOT NULL; DEFAULT 'EXOTICO' |
| tipo_habitat | d_nombre | VARCHAR(60) | — |
| requiere_permiso | d_bool | BOOLEAN | NOT NULL; DEFAULT FALSE |

- CHECK (tipo = 'EXOTICO')
- FK compuesta (id_mascota, tipo) → MASCOTA(id_mascota, tipo)

## EMPLEADO
_Empleado (superentidad). Origen E-R: Entidad fuerte; nombre compuesto aplanado; /antigüedad/ no se almacena_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK |
| nombre_pila | d_nombre | VARCHAR(60) | NOT NULL |
| ap_paterno | d_nombre | VARCHAR(60) | NOT NULL |
| ap_materno | d_nombre | VARCHAR(60) | — |
| rfc | d_rfc | VARCHAR(13) | NOT NULL; UNIQUE |
| fecha_ingreso | d_fecha | DATE | NOT NULL |


## VETERINARIO
_Veterinario (subentidad de Empleado). Origen E-R: Especialización solapada: tabla por rol con PK=FK_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK; FK → EMPLEADO.id_empleado |
| cedula_profesional | d_cedula | VARCHAR(15) | NOT NULL; UNIQUE |


## VETERINARIO_ESPECIALIDAD
_Especialidades del veterinario. Origen E-R: Atributo multivalorado {especialidad}_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK; FK → VETERINARIO.id_empleado |
| especialidad | d_nombre | VARCHAR(60) | PK |


## VETERINARIO_ESPECIALISTA
_Veterinario especialista (nivel 3). Origen E-R: Jerarquía Empleado → Veterinario → Especialista_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK; FK → VETERINARIO.id_empleado |
| subespecialidad | d_nombre | VARCHAR(60) | NOT NULL |


## GERENTE
_Gerente (subentidad de Empleado). Origen E-R: Especialización solapada_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK; FK → EMPLEADO.id_empleado |
| departamento | d_nombre | VARCHAR(60) | NOT NULL |


## RECEPCIONISTA
_Recepcionista (subentidad de Empleado). Origen E-R: Especialización solapada_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK; FK → EMPLEADO.id_empleado |
| turno | d_turno | VARCHAR(12) | NOT NULL |


## AUXILIAR
_Auxiliar (subentidad de Empleado). Origen E-R: Especialización solapada_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_empleado | d_id | INT | PK; FK → EMPLEADO.id_empleado |
| area_asignada | d_nombre | VARCHAR(60) | NOT NULL |


## CITA
_Cita (relación Agenda, M:N). Origen E-R: Relación M:N con atributos → tabla propia; UNIQUE implementa la regla 6_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_cita | d_id | INT | PK |
| id_mascota | d_id | INT | FK → MASCOTA.id_mascota; NOT NULL |
| id_veterinario | d_id | INT | FK → VETERINARIO.id_empleado; NOT NULL |
| fecha_hora | d_fechahora | TIMESTAMP | NOT NULL |
| motivo | d_texto | VARCHAR(255) | — |
| estado | d_estado_cita | VARCHAR(12) | NOT NULL; DEFAULT 'PROGRAMADA' |

- UNIQUE (id_veterinario, fecha_hora)

## CONSULTA
_Consulta (relación Atiende, M:N; agregada). Origen E-R: Relación M:N agregada → tabla con PK propia (folio) que las demás relaciones referencian_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| folio | d_id | INT | PK |
| id_mascota | d_id | INT | FK → MASCOTA.id_mascota; NOT NULL |
| id_veterinario | d_id | INT | FK → VETERINARIO.id_empleado; NOT NULL |
| fecha | d_fecha | DATE | NOT NULL |
| diagnostico | d_texto | VARCHAR(255) | — |
| observaciones | d_texto | VARCHAR(255) | — |


## MEDICAMENTO
_Medicamento. Origen E-R: Entidad fuerte (regla 12: existencia ≥ 0 por dominio)_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_medicamento | d_id | INT | PK |
| nombre | d_nombre | VARCHAR(60) | NOT NULL |
| presentacion | d_nombre | VARCHAR(60) | — |
| existencia | d_cant | INT | NOT NULL |
| precio | d_dinero | DECIMAL(10,2) | NOT NULL |


## PROVEEDOR
_Proveedor. Origen E-R: Entidad fuerte_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_proveedor | d_id | INT | PK |
| razon_social | d_nombre | VARCHAR(60) | NOT NULL |
| contacto | d_texto | VARCHAR(255) | — |


## VACUNA
_Vacuna. Origen E-R: Entidad fuerte_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_vacuna | d_id | INT | PK |
| nombre | d_nombre | VARCHAR(60) | NOT NULL |
| enfermedad_prevenida | d_nombre | VARCHAR(60) | NOT NULL |


## RECETA
_Receta (relación M:N sobre la agregación). Origen E-R: Relación M:N con atributos: PK compuesta con las dos FK_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| folio | d_id | INT | PK; FK → CONSULTA.folio |
| id_medicamento | d_id | INT | PK; FK → MEDICAMENTO.id_medicamento |
| dosis | d_nombre | VARCHAR(60) | NOT NULL |
| duracion | d_nombre | VARCHAR(60) | NOT NULL |


## APLICA
_Aplica (relación M:N sobre la agregación). Origen E-R: Relación M:N con atributos_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| folio | d_id | INT | PK; FK → CONSULTA.folio |
| id_vacuna | d_id | INT | PK; FK → VACUNA.id_vacuna |
| lote | d_nombre | VARCHAR(60) | NOT NULL |
| caducidad | d_fecha | DATE | NOT NULL |


## SUMINISTRA
_Suministra (relación M:N). Origen E-R: Relación M:N sin atributos_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| id_medicamento | d_id | INT | PK; FK → MEDICAMENTO.id_medicamento |
| id_proveedor | d_id | INT | PK; FK → PROVEEDOR.id_proveedor |


## FACTURA
_Factura (relación Genera, 1:1). Origen E-R: Relación 1:1: FK única en Factura; /total/ no se almacena_

| Atributo | Dominio | Tipo SQL | Restricciones |
|---|---|---|---|
| no_factura | d_id | INT | PK |
| folio | d_id | INT | FK → CONSULTA.folio; NOT NULL; UNIQUE |
| fecha | d_fecha | DATE | NOT NULL |
| subtotal | d_dinero | DECIMAL(10,2) | NOT NULL |


