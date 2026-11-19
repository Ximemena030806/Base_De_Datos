# Diccionario de datos: esquema físico (SQL Server)

Notación: PK = llave primaria, FK = llave foránea, UQ = única, NO = NOT NULL.

## propietario
_Propietario_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_propietario` | INT | NO | PK | IDENTITY | Identificador del propietario |
| 2 | `nombre_pila` | VARCHAR(60) | NO | — | — | Nombre(s) de pila |
| 3 | `ap_paterno` | VARCHAR(60) | NO | — | — | Apellido paterno |
| 4 | `ap_materno` | VARCHAR(60) | SÍ | — | — | Apellido materno |
| 5 | `calle` | VARCHAR(255) | NO | — | — | Calle y número del domicilio |
| 6 | `colonia` | VARCHAR(60) | NO | — | — | Colonia |
| 7 | `cp` | CHAR(5) | NO | — | CHECK cp LIKE '[0-9][0-9][0-9][0-9][0-9]' | Código postal (5 dígitos) |
| 8 | `correo` | VARCHAR(100) | SÍ | UQ | CHECK correo LIKE '%_@_%._%' | Correo electrónico de contacto (único) |


## telefono_propietario
_Teléfonos del propietario_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_propietario` | INT | NO | PK,FK | FK→propietario.id_propietario (DELETE CASCADE) | Propietario dueño del teléfono |
| 2 | `telefono` | VARCHAR(15) | NO | PK | CHECK LEN(telefono) BETWEEN 7 AND 15 AND telefono NOT LIKE '%[^0-9+() -]%' | Teléfono de contacto (multivalorado) |


## mascota
_Mascota (superentidad)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_mascota` | INT | NO | PK | IDENTITY | Identificador de la mascota |
| 2 | `nombre` | VARCHAR(60) | NO | — | — | Nombre de la mascota |
| 3 | `especie` | VARCHAR(60) | NO | — | — | Especie del animal |
| 4 | `raza` | VARCHAR(60) | SÍ | — | — | Raza |
| 5 | `fecha_nacimiento` | DATE | NO | — | — | Fecha de nacimiento (base de la edad derivada) |
| 6 | `peso` | DECIMAL(6,2) | SÍ | — | CHECK peso > 0 | Peso en kilogramos (mayor que 0) |
| 7 | `tipo` | VARCHAR(10) | NO | — | CHECK tipo IN ('CANINO','FELINO','EXOTICO') | Discriminador de la especialización: CANINO, FELINO o EXOTICO |
| 8 | `id_propietario` | INT | NO | FK | FK→propietario.id_propietario (DELETE NO ACTION) | Propietario responsable de la mascota |

- UNIQUE compuesta `uq_mascota_id_mascota_tipo` (id_mascota, tipo)

## canino
_Canino (subentidad de Mascota)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_mascota` | INT | NO | PK,FK | FK→mascota.id_mascota (DELETE CASCADE) | Mascota a la que corresponde el subtipo (PK y FK) |
| 2 | `tipo` | VARCHAR(10) | NO | FK | FK→mascota.tipo (DELETE CASCADE); CHECK tipo IN ('CANINO','FELINO','EXOTICO'); DEFAULT 'CANINO' | Discriminador fijo 'CANINO' (garantiza la disyunción) |
| 3 | `tamano` | VARCHAR(10) | NO | — | CHECK tamano IN ('PEQUENO','MEDIANO','GRANDE') | Tamaño: PEQUENO, MEDIANO o GRANDE |
| 4 | `nivel_adiestramiento` | VARCHAR(60) | SÍ | — | — | Nivel de adiestramiento |

- FK compuesta `fk_canino_mascota` (id_mascota, tipo) → mascota(id_mascota, tipo)
- CHECK `ck_canino_discriminador`: `tipo = 'CANINO'`

## felino
_Felino (subentidad de Mascota)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_mascota` | INT | NO | PK,FK | FK→mascota.id_mascota (DELETE CASCADE) | Mascota a la que corresponde el subtipo (PK y FK) |
| 2 | `tipo` | VARCHAR(10) | NO | FK | FK→mascota.tipo (DELETE CASCADE); CHECK tipo IN ('CANINO','FELINO','EXOTICO'); DEFAULT 'FELINO' | Discriminador fijo 'FELINO' (garantiza la disyunción) |
| 3 | `pelaje` | VARCHAR(60) | SÍ | — | — | Tipo de pelaje |
| 4 | `esterilizado` | BIT | NO | — | DEFAULT 0 | Indica si el felino está esterilizado |

- FK compuesta `fk_felino_mascota` (id_mascota, tipo) → mascota(id_mascota, tipo)
- CHECK `ck_felino_discriminador`: `tipo = 'FELINO'`

## exotico
_Exótico (subentidad de Mascota)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_mascota` | INT | NO | PK,FK | FK→mascota.id_mascota (DELETE CASCADE) | Mascota a la que corresponde el subtipo (PK y FK) |
| 2 | `tipo` | VARCHAR(10) | NO | FK | FK→mascota.tipo (DELETE CASCADE); CHECK tipo IN ('CANINO','FELINO','EXOTICO'); DEFAULT 'EXOTICO' | Discriminador fijo 'EXOTICO' (garantiza la disyunción) |
| 3 | `tipo_habitat` | VARCHAR(60) | SÍ | — | — | Tipo de hábitat requerido |
| 4 | `requiere_permiso` | BIT | NO | — | DEFAULT 0 | Indica si la especie requiere permiso legal |

- FK compuesta `fk_exotico_mascota` (id_mascota, tipo) → mascota(id_mascota, tipo)
- CHECK `ck_exotico_discriminador`: `tipo = 'EXOTICO'`

## empleado
_Empleado (superentidad)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK | IDENTITY | Identificador del empleado |
| 2 | `nombre_pila` | VARCHAR(60) | NO | — | — | Nombre(s) de pila |
| 3 | `ap_paterno` | VARCHAR(60) | NO | — | — | Apellido paterno |
| 4 | `ap_materno` | VARCHAR(60) | SÍ | — | — | Apellido materno |
| 5 | `rfc` | VARCHAR(13) | NO | UQ | CHECK LEN(rfc) BETWEEN 12 AND 13 | RFC del empleado (único) |
| 6 | `fecha_ingreso` | DATE | NO | — | — | Fecha de ingreso (base de la antigüedad derivada) |


## veterinario
_Veterinario (subentidad de Empleado)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK,FK | FK→empleado.id_empleado (DELETE CASCADE) | Empleado al que corresponde el rol (PK y FK) |
| 2 | `cedula_profesional` | VARCHAR(15) | NO | UQ | — | Cédula profesional (única) |


## veterinario_especialidad
_Especialidades del veterinario_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK,FK | FK→veterinario.id_empleado (DELETE CASCADE) | Veterinario al que pertenece la especialidad |
| 2 | `especialidad` | VARCHAR(60) | NO | PK | — | Especialidad (multivalorado) |


## veterinario_especialista
_Veterinario especialista (nivel 3)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK,FK | FK→veterinario.id_empleado (DELETE CASCADE) | Empleado al que corresponde el rol (PK y FK) |
| 2 | `subespecialidad` | VARCHAR(60) | NO | — | — | Subespecialidad del veterinario especialista |


## gerente
_Gerente (subentidad de Empleado)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK,FK | FK→empleado.id_empleado (DELETE CASCADE) | Empleado al que corresponde el rol (PK y FK) |
| 2 | `departamento` | VARCHAR(60) | NO | — | — | Departamento administrativo a cargo |


## recepcionista
_Recepcionista (subentidad de Empleado)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK,FK | FK→empleado.id_empleado (DELETE CASCADE) | Empleado al que corresponde el rol (PK y FK) |
| 2 | `turno` | VARCHAR(12) | NO | — | CHECK turno IN ('MATUTINO','VESPERTINO','NOCTURNO') | Turno: MATUTINO, VESPERTINO o NOCTURNO |


## auxiliar
_Auxiliar (subentidad de Empleado)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_empleado` | INT | NO | PK,FK | FK→empleado.id_empleado (DELETE CASCADE) | Empleado al que corresponde el rol (PK y FK) |
| 2 | `area_asignada` | VARCHAR(60) | NO | — | — | Área en la que trabaja el auxiliar |


## cita
_Cita (relación Agenda, M:N)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_cita` | INT | NO | PK | IDENTITY | Identificador de la cita |
| 2 | `id_mascota` | INT | NO | FK | FK→mascota.id_mascota (DELETE NO ACTION) | Mascota para la que se agenda la cita |
| 3 | `id_veterinario` | INT | NO | FK | FK→veterinario.id_empleado (DELETE NO ACTION) | Veterinario (empleado) asignado |
| 4 | `fecha_hora` | DATETIME2(0) | NO | — | — | Fecha y hora programadas de la cita |
| 5 | `motivo` | VARCHAR(255) | SÍ | — | — | Motivo de la cita |
| 6 | `estado` | VARCHAR(12) | NO | — | CHECK estado IN ('PROGRAMADA','ATENDIDA','CANCELADA','NO_ASISTIO'); DEFAULT 'PROGRAMADA' | Estado: PROGRAMADA, ATENDIDA, CANCELADA o NO_ASISTIO |

- UNIQUE compuesta `uq_cita_id_veterinario_fecha_hora` (id_veterinario, fecha_hora)

## consulta
_Consulta (relación Atiende, M:N; agregada)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `folio` | INT | NO | PK | IDENTITY | Folio de la consulta |
| 2 | `id_mascota` | INT | NO | FK | FK→mascota.id_mascota (DELETE NO ACTION) | Mascota atendida |
| 3 | `id_veterinario` | INT | NO | FK | FK→veterinario.id_empleado (DELETE NO ACTION) | Veterinario que realizó la atención |
| 4 | `fecha` | DATE | NO | — | — | Fecha de la atención |
| 5 | `diagnostico` | VARCHAR(255) | SÍ | — | — | Diagnóstico del veterinario |
| 6 | `observaciones` | VARCHAR(255) | SÍ | — | — | Observaciones de la atención |


## medicamento
_Medicamento_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_medicamento` | INT | NO | PK | IDENTITY | Identificador del medicamento |
| 2 | `nombre` | VARCHAR(60) | NO | — | — | Nombre del medicamento |
| 3 | `presentacion` | VARCHAR(60) | SÍ | — | — | Presentación comercial |
| 4 | `existencia` | INT | NO | — | CHECK existencia >= 0 | Unidades en existencia (no negativa) |
| 5 | `precio` | DECIMAL(10,2) | NO | — | CHECK precio >= 0 | Precio unitario (no negativo) |


## proveedor
_Proveedor_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_proveedor` | INT | NO | PK | IDENTITY | Identificador del proveedor |
| 2 | `razon_social` | VARCHAR(60) | NO | — | — | Razón social del proveedor |
| 3 | `contacto` | VARCHAR(255) | SÍ | — | — | Datos de contacto |


## vacuna
_Vacuna_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_vacuna` | INT | NO | PK | IDENTITY | Identificador de la vacuna |
| 2 | `nombre` | VARCHAR(60) | NO | — | — | Nombre de la vacuna |
| 3 | `enfermedad_prevenida` | VARCHAR(60) | NO | — | — | Enfermedad que previene |


## receta
_Receta (relación M:N sobre la agregación)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `folio` | INT | NO | PK,FK | FK→consulta.folio (DELETE CASCADE) | Consulta en la que se receta |
| 2 | `id_medicamento` | INT | NO | PK,FK | FK→medicamento.id_medicamento (DELETE NO ACTION) | Medicamento recetado |
| 3 | `dosis` | VARCHAR(60) | NO | — | — | Dosis indicada |
| 4 | `duracion` | VARCHAR(60) | NO | — | — | Duración del tratamiento |


## aplica
_Aplica (relación M:N sobre la agregación)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `folio` | INT | NO | PK,FK | FK→consulta.folio (DELETE CASCADE) | Consulta en la que se aplica la vacuna |
| 2 | `id_vacuna` | INT | NO | PK,FK | FK→vacuna.id_vacuna (DELETE NO ACTION) | Vacuna aplicada |
| 3 | `lote` | VARCHAR(60) | NO | — | — | Lote de la vacuna aplicada |
| 4 | `caducidad` | DATE | NO | — | — | Fecha de caducidad del lote |


## suministra
_Suministra (relación M:N)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `id_medicamento` | INT | NO | PK,FK | FK→medicamento.id_medicamento (DELETE CASCADE) | Medicamento suministrado |
| 2 | `id_proveedor` | INT | NO | PK,FK | FK→proveedor.id_proveedor (DELETE NO ACTION) | Proveedor que lo suministra |


## factura
_Factura (relación Genera, 1:1)_

| # | Columna | Tipo | Nulo | Llave | Restricciones / default | Descripción |
|---|---|---|---|---|---|---|
| 1 | `no_factura` | INT | NO | PK | IDENTITY | Número de factura |
| 2 | `folio` | INT | NO | FK,UQ | FK→consulta.folio (DELETE NO ACTION) | Consulta que originó la factura (relación 1:1) |
| 3 | `fecha` | DATE | NO | — | — | Fecha de emisión de la factura |
| 4 | `subtotal` | DECIMAL(10,2) | NO | — | CHECK subtotal >= 0 | Subtotal de servicios (no negativo) |


