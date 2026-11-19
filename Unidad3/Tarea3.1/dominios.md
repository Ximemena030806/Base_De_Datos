# Dominios definidos

| Dominio | Tipo SQL | Condición | Descripción |
|---|---|---|---|
| `d_id` | INT | `VALUE > 0` | Entero positivo (identificadores) |
| `d_nombre` | VARCHAR(60) | — | Cadena de hasta 60 caracteres |
| `d_texto` | VARCHAR(255) | — | Texto libre de hasta 255 caracteres |
| `d_correo` | VARCHAR(100) | `VALUE LIKE '%_@_%._%'` | Correo electrónico con formato válido |
| `d_tel` | VARCHAR(15) | `VALUE ~ '^[0-9+() -]{7,15}$'` | Teléfono de 7 a 15 símbolos numéricos |
| `d_cp` | CHAR(5) | `VALUE ~ '^[0-9]{5}$'` | Código postal de 5 dígitos |
| `d_rfc` | VARCHAR(13) | `LENGTH(VALUE) BETWEEN 12 AND 13` | RFC de 12 o 13 caracteres |
| `d_cedula` | VARCHAR(15) | — | Cédula profesional |
| `d_fecha` | DATE | — | Fecha calendario |
| `d_fechahora` | TIMESTAMP | — | Fecha y hora |
| `d_dinero` | DECIMAL(10,2) | `VALUE >= 0` | Monto monetario no negativo |
| `d_cant` | INT | `VALUE >= 0` | Cantidad entera no negativa |
| `d_peso` | DECIMAL(6,2) | `VALUE > 0` | Peso en kg, positivo |
| `d_bool` | BOOLEAN | — | Verdadero o falso |
| `d_tipo_mascota` | VARCHAR(10) | `VALUE IN ('CANINO','FELINO','EXOTICO')` | {CANINO, FELINO, EXOTICO} |
| `d_estado_cita` | VARCHAR(12) | `VALUE IN ('PROGRAMADA','ATENDIDA','CANCELADA','NO_ASISTIO')` | {PROGRAMADA, ATENDIDA, CANCELADA, NO_ASISTIO} |
| `d_turno` | VARCHAR(12) | `VALUE IN ('MATUTINO','VESPERTINO','NOCTURNO')` | {MATUTINO, VESPERTINO, NOCTURNO} |
| `d_tamano` | VARCHAR(10) | `VALUE IN ('PEQUENO','MEDIANO','GRANDE')` | {PEQUENO, MEDIANO, GRANDE} |
