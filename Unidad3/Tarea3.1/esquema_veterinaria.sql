-- Esquema relacional: Clínica Veterinaria (PostgreSQL)
-- Unidad 2 -> Unidad 3, Tarea 3.1

-- ===== DOMINIOS (integridad de dominio) =====
CREATE DOMAIN d_id AS INT CHECK (VALUE > 0);
CREATE DOMAIN d_nombre AS VARCHAR(60);
CREATE DOMAIN d_texto AS VARCHAR(255);
CREATE DOMAIN d_correo AS VARCHAR(100) CHECK (VALUE LIKE '%_@_%._%');
CREATE DOMAIN d_tel AS VARCHAR(15) CHECK (VALUE ~ '^[0-9+() -]{7,15}$');
CREATE DOMAIN d_cp AS CHAR(5) CHECK (VALUE ~ '^[0-9]{5}$');
CREATE DOMAIN d_rfc AS VARCHAR(13) CHECK (LENGTH(VALUE) BETWEEN 12 AND 13);
CREATE DOMAIN d_cedula AS VARCHAR(15);
CREATE DOMAIN d_fecha AS DATE;
CREATE DOMAIN d_fechahora AS TIMESTAMP;
CREATE DOMAIN d_dinero AS DECIMAL(10,2) CHECK (VALUE >= 0);
CREATE DOMAIN d_cant AS INT CHECK (VALUE >= 0);
CREATE DOMAIN d_peso AS DECIMAL(6,2) CHECK (VALUE > 0);
CREATE DOMAIN d_bool AS BOOLEAN;
CREATE DOMAIN d_tipo_mascota AS VARCHAR(10) CHECK (VALUE IN ('CANINO','FELINO','EXOTICO'));
CREATE DOMAIN d_estado_cita AS VARCHAR(12) CHECK (VALUE IN ('PROGRAMADA','ATENDIDA','CANCELADA','NO_ASISTIO'));
CREATE DOMAIN d_turno AS VARCHAR(12) CHECK (VALUE IN ('MATUTINO','VESPERTINO','NOCTURNO'));
CREATE DOMAIN d_tamano AS VARCHAR(10) CHECK (VALUE IN ('PEQUENO','MEDIANO','GRANDE'));

-- ===== TABLAS =====
CREATE TABLE propietario (
  id_propietario d_id NOT NULL,
  nombre_pila d_nombre NOT NULL,
  ap_paterno d_nombre NOT NULL,
  ap_materno d_nombre,
  calle d_texto NOT NULL,
  colonia d_nombre NOT NULL,
  cp d_cp NOT NULL,
  correo d_correo,
  PRIMARY KEY (id_propietario),
  UNIQUE (correo)
);

CREATE TABLE telefono_propietario (
  id_propietario d_id NOT NULL,
  telefono d_tel NOT NULL,
  PRIMARY KEY (id_propietario, telefono),
  FOREIGN KEY (id_propietario) REFERENCES propietario (id_propietario) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE mascota (
  id_mascota d_id NOT NULL,
  nombre d_nombre NOT NULL,
  especie d_nombre NOT NULL,
  raza d_nombre,
  fecha_nacimiento d_fecha NOT NULL,
  peso d_peso,
  tipo d_tipo_mascota NOT NULL,
  id_propietario d_id NOT NULL,
  PRIMARY KEY (id_mascota),
  UNIQUE (id_mascota, tipo),
  FOREIGN KEY (id_propietario) REFERENCES propietario (id_propietario) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE canino (
  id_mascota d_id NOT NULL,
  tipo d_tipo_mascota NOT NULL DEFAULT 'CANINO',
  tamano d_tamano NOT NULL,
  nivel_adiestramiento d_nombre,
  PRIMARY KEY (id_mascota),
  CHECK (tipo = 'CANINO'),
  FOREIGN KEY (id_mascota, tipo) REFERENCES mascota (id_mascota, tipo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE felino (
  id_mascota d_id NOT NULL,
  tipo d_tipo_mascota NOT NULL DEFAULT 'FELINO',
  pelaje d_nombre,
  esterilizado d_bool NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id_mascota),
  CHECK (tipo = 'FELINO'),
  FOREIGN KEY (id_mascota, tipo) REFERENCES mascota (id_mascota, tipo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE exotico (
  id_mascota d_id NOT NULL,
  tipo d_tipo_mascota NOT NULL DEFAULT 'EXOTICO',
  tipo_habitat d_nombre,
  requiere_permiso d_bool NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id_mascota),
  CHECK (tipo = 'EXOTICO'),
  FOREIGN KEY (id_mascota, tipo) REFERENCES mascota (id_mascota, tipo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE empleado (
  id_empleado d_id NOT NULL,
  nombre_pila d_nombre NOT NULL,
  ap_paterno d_nombre NOT NULL,
  ap_materno d_nombre,
  rfc d_rfc NOT NULL,
  fecha_ingreso d_fecha NOT NULL,
  PRIMARY KEY (id_empleado),
  UNIQUE (rfc)
);

CREATE TABLE veterinario (
  id_empleado d_id NOT NULL,
  cedula_profesional d_cedula NOT NULL,
  PRIMARY KEY (id_empleado),
  UNIQUE (cedula_profesional),
  FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE veterinario_especialidad (
  id_empleado d_id NOT NULL,
  especialidad d_nombre NOT NULL,
  PRIMARY KEY (id_empleado, especialidad),
  FOREIGN KEY (id_empleado) REFERENCES veterinario (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE veterinario_especialista (
  id_empleado d_id NOT NULL,
  subespecialidad d_nombre NOT NULL,
  PRIMARY KEY (id_empleado),
  FOREIGN KEY (id_empleado) REFERENCES veterinario (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE gerente (
  id_empleado d_id NOT NULL,
  departamento d_nombre NOT NULL,
  PRIMARY KEY (id_empleado),
  FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE recepcionista (
  id_empleado d_id NOT NULL,
  turno d_turno NOT NULL,
  PRIMARY KEY (id_empleado),
  FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE auxiliar (
  id_empleado d_id NOT NULL,
  area_asignada d_nombre NOT NULL,
  PRIMARY KEY (id_empleado),
  FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE cita (
  id_cita d_id NOT NULL,
  id_mascota d_id NOT NULL,
  id_veterinario d_id NOT NULL,
  fecha_hora d_fechahora NOT NULL,
  motivo d_texto,
  estado d_estado_cita NOT NULL DEFAULT 'PROGRAMADA',
  PRIMARY KEY (id_cita),
  UNIQUE (id_veterinario, fecha_hora),
  FOREIGN KEY (id_mascota) REFERENCES mascota (id_mascota) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE consulta (
  folio d_id NOT NULL,
  id_mascota d_id NOT NULL,
  id_veterinario d_id NOT NULL,
  fecha d_fecha NOT NULL,
  diagnostico d_texto,
  observaciones d_texto,
  PRIMARY KEY (folio),
  FOREIGN KEY (id_mascota) REFERENCES mascota (id_mascota) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE medicamento (
  id_medicamento d_id NOT NULL,
  nombre d_nombre NOT NULL,
  presentacion d_nombre,
  existencia d_cant NOT NULL,
  precio d_dinero NOT NULL,
  PRIMARY KEY (id_medicamento)
);

CREATE TABLE proveedor (
  id_proveedor d_id NOT NULL,
  razon_social d_nombre NOT NULL,
  contacto d_texto,
  PRIMARY KEY (id_proveedor)
);

CREATE TABLE vacuna (
  id_vacuna d_id NOT NULL,
  nombre d_nombre NOT NULL,
  enfermedad_prevenida d_nombre NOT NULL,
  PRIMARY KEY (id_vacuna)
);

CREATE TABLE receta (
  folio d_id NOT NULL,
  id_medicamento d_id NOT NULL,
  dosis d_nombre NOT NULL,
  duracion d_nombre NOT NULL,
  PRIMARY KEY (folio, id_medicamento),
  FOREIGN KEY (folio) REFERENCES consulta (folio) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE aplica (
  folio d_id NOT NULL,
  id_vacuna d_id NOT NULL,
  lote d_nombre NOT NULL,
  caducidad d_fecha NOT NULL,
  PRIMARY KEY (folio, id_vacuna),
  FOREIGN KEY (folio) REFERENCES consulta (folio) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_vacuna) REFERENCES vacuna (id_vacuna) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE suministra (
  id_medicamento d_id NOT NULL,
  id_proveedor d_id NOT NULL,
  PRIMARY KEY (id_medicamento, id_proveedor),
  FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (id_proveedor) REFERENCES proveedor (id_proveedor) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE factura (
  no_factura d_id NOT NULL,
  folio d_id NOT NULL,
  fecha d_fecha NOT NULL,
  subtotal d_dinero NOT NULL,
  PRIMARY KEY (no_factura),
  UNIQUE (folio),
  FOREIGN KEY (folio) REFERENCES consulta (folio) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ===== VISTAS (atributos derivados: no se almacenan) =====
CREATE VIEW v_mascota AS
SELECT m.*, EXTRACT(YEAR FROM AGE(CURRENT_DATE, m.fecha_nacimiento))::INT AS edad FROM mascota m;

CREATE VIEW v_empleado AS
SELECT e.*, EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.fecha_ingreso))::INT AS antiguedad FROM empleado e;

-- total = subtotal de servicios + precio de los medicamentos recetados en la consulta
CREATE VIEW v_factura AS
SELECT f.*, f.subtotal + COALESCE((SELECT SUM(md.precio) FROM receta r
        JOIN medicamento md ON md.id_medicamento = r.id_medicamento
        WHERE r.folio = f.folio), 0) AS total
FROM factura f;

-- ===== RESTRICCIONES QUE NO SE EXPRESAN CON PK/FK/CHECK =====
-- (a) Especialización TOTAL de Mascota: toda mascota debe tener su fila en el subtipo
--     que indica 'tipo'. Se verifica con un trigger diferido (CONSTRAINT TRIGGER ... DEFERRABLE).
-- (b) Participación TOTAL de Medicamento en Suministra: todo medicamento debe tener
--     al menos un proveedor (trigger diferido).
-- (c) Participación TOTAL de Consulta en Genera: toda consulta debe tener su factura (trigger diferido).
