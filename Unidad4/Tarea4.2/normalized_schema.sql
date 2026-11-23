-- =====================================================================
-- Esquema NORMALIZADO (3FN/FNBC): Clínica Veterinaria
-- SGBD: Microsoft SQL Server (2019 o superior; probado para SQL Server 2025) · Herramienta: SSMS
-- normalized_schema.sql: DDL (base de datos, tablas, llaves, restricciones, índices, vistas y descripciones)
-- Ejecutar completo en una ventana de consulta (New Query). Es reejecutable.
-- =====================================================================

USE master;
GO
IF DB_ID(N'veterinaria') IS NULL CREATE DATABASE veterinaria;
GO
USE veterinaria;
GO

DROP VIEW IF EXISTS v_factura;
DROP VIEW IF EXISTS v_empleado;
DROP VIEW IF EXISTS v_mascota;
DROP TABLE IF EXISTS factura;
DROP TABLE IF EXISTS suministra;
DROP TABLE IF EXISTS aplica;
DROP TABLE IF EXISTS receta;
DROP TABLE IF EXISTS lote_vacuna;
DROP TABLE IF EXISTS vacuna;
DROP TABLE IF EXISTS proveedor;
DROP TABLE IF EXISTS medicamento;
DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS cita;
DROP TABLE IF EXISTS auxiliar;
DROP TABLE IF EXISTS recepcionista;
DROP TABLE IF EXISTS gerente;
DROP TABLE IF EXISTS veterinario_especialista;
DROP TABLE IF EXISTS veterinario_especialidad;
DROP TABLE IF EXISTS veterinario;
DROP TABLE IF EXISTS empleado;
DROP TABLE IF EXISTS exotico;
DROP TABLE IF EXISTS felino;
DROP TABLE IF EXISTS canino;
DROP TABLE IF EXISTS mascota;
DROP TABLE IF EXISTS raza;
DROP TABLE IF EXISTS especie;
DROP TABLE IF EXISTS telefono_propietario;
DROP TABLE IF EXISTS propietario;
GO

-- Propietario
CREATE TABLE propietario (
  id_propietario INT IDENTITY(1,1) NOT NULL,
  nombre_pila VARCHAR(60) NOT NULL,
  ap_paterno VARCHAR(60) NOT NULL,
  ap_materno VARCHAR(60) NULL,
  calle VARCHAR(255) NOT NULL,
  colonia VARCHAR(60) NOT NULL,
  cp CHAR(5) NOT NULL,
  correo VARCHAR(100) NULL,
  CONSTRAINT pk_propietario PRIMARY KEY (id_propietario),
  CONSTRAINT ck_propietario_cp CHECK (cp LIKE '[0-9][0-9][0-9][0-9][0-9]'),
  CONSTRAINT ck_propietario_correo CHECK (correo LIKE '%_@_%._%')
);
-- UNIQUE sobre columna que admite NULL: índice único filtrado (SQL Server solo permite un NULL en un UNIQUE normal)
CREATE UNIQUE INDEX uq_propietario_correo ON propietario (correo) WHERE correo IS NOT NULL;
GO

-- Teléfonos del propietario
CREATE TABLE telefono_propietario (
  id_propietario INT NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  CONSTRAINT pk_telefono_propietario PRIMARY KEY (id_propietario, telefono),
  CONSTRAINT ck_telefono_propietario_telefono CHECK (LEN(telefono) BETWEEN 7 AND 15 AND telefono NOT LIKE '%[^0-9+() -]%'),
  CONSTRAINT fk_telefono_propietario_propietario FOREIGN KEY (id_propietario) REFERENCES propietario (id_propietario)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Catálogo de especies
CREATE TABLE especie (
  id_especie INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  tipo VARCHAR(10) NOT NULL,
  CONSTRAINT pk_especie PRIMARY KEY (id_especie),
  CONSTRAINT uq_especie_nombre UNIQUE (nombre),
  CONSTRAINT uq_especie_id_especie_tipo UNIQUE (id_especie, tipo),
  CONSTRAINT ck_especie_tipo CHECK (tipo IN ('CANINO','FELINO','EXOTICO'))
);
GO

-- Catálogo de razas
CREATE TABLE raza (
  id_raza INT IDENTITY(1,1) NOT NULL,
  id_especie INT NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  CONSTRAINT pk_raza PRIMARY KEY (id_raza),
  CONSTRAINT uq_raza_id_especie_nombre UNIQUE (id_especie, nombre),
  CONSTRAINT uq_raza_id_raza_id_especie UNIQUE (id_raza, id_especie),
  CONSTRAINT fk_raza_especie FOREIGN KEY (id_especie) REFERENCES especie (id_especie)
    ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Mascota (superentidad)
CREATE TABLE mascota (
  id_mascota INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  id_especie INT NOT NULL,
  id_raza INT NULL,
  fecha_nacimiento DATE NOT NULL,
  peso DECIMAL(6,2) NULL,
  tipo VARCHAR(10) NOT NULL,
  id_propietario INT NOT NULL,
  CONSTRAINT pk_mascota PRIMARY KEY (id_mascota),
  CONSTRAINT uq_mascota_id_mascota_tipo UNIQUE (id_mascota, tipo),
  CONSTRAINT ck_mascota_peso CHECK (peso > 0),
  CONSTRAINT ck_mascota_tipo CHECK (tipo IN ('CANINO','FELINO','EXOTICO')),
  CONSTRAINT fk_mascota_propietario FOREIGN KEY (id_propietario) REFERENCES propietario (id_propietario)
    ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_mascota_especie FOREIGN KEY (id_especie, tipo) REFERENCES especie (id_especie, tipo)
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_mascota_raza FOREIGN KEY (id_raza, id_especie) REFERENCES raza (id_raza, id_especie)
    ON UPDATE NO ACTION ON DELETE NO ACTION
);
GO

-- Canino (subentidad de Mascota)
CREATE TABLE canino (
  id_mascota INT NOT NULL,
  tipo VARCHAR(10) NOT NULL CONSTRAINT df_canino_tipo DEFAULT 'CANINO',
  tamano VARCHAR(10) NOT NULL,
  nivel_adiestramiento VARCHAR(60) NULL,
  CONSTRAINT pk_canino PRIMARY KEY (id_mascota),
  CONSTRAINT ck_canino_tipo CHECK (tipo IN ('CANINO','FELINO','EXOTICO')),
  CONSTRAINT ck_canino_tamano CHECK (tamano IN ('PEQUENO','MEDIANO','GRANDE')),
  CONSTRAINT ck_canino_discriminador CHECK (tipo = 'CANINO'),
  CONSTRAINT fk_canino_mascota FOREIGN KEY (id_mascota, tipo) REFERENCES mascota (id_mascota, tipo)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Felino (subentidad de Mascota)
CREATE TABLE felino (
  id_mascota INT NOT NULL,
  tipo VARCHAR(10) NOT NULL CONSTRAINT df_felino_tipo DEFAULT 'FELINO',
  pelaje VARCHAR(60) NULL,
  esterilizado BIT NOT NULL CONSTRAINT df_felino_esterilizado DEFAULT 0,
  CONSTRAINT pk_felino PRIMARY KEY (id_mascota),
  CONSTRAINT ck_felino_tipo CHECK (tipo IN ('CANINO','FELINO','EXOTICO')),
  CONSTRAINT ck_felino_discriminador CHECK (tipo = 'FELINO'),
  CONSTRAINT fk_felino_mascota FOREIGN KEY (id_mascota, tipo) REFERENCES mascota (id_mascota, tipo)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Exótico (subentidad de Mascota)
CREATE TABLE exotico (
  id_mascota INT NOT NULL,
  tipo VARCHAR(10) NOT NULL CONSTRAINT df_exotico_tipo DEFAULT 'EXOTICO',
  tipo_habitat VARCHAR(60) NULL,
  requiere_permiso BIT NOT NULL CONSTRAINT df_exotico_requiere_permiso DEFAULT 0,
  CONSTRAINT pk_exotico PRIMARY KEY (id_mascota),
  CONSTRAINT ck_exotico_tipo CHECK (tipo IN ('CANINO','FELINO','EXOTICO')),
  CONSTRAINT ck_exotico_discriminador CHECK (tipo = 'EXOTICO'),
  CONSTRAINT fk_exotico_mascota FOREIGN KEY (id_mascota, tipo) REFERENCES mascota (id_mascota, tipo)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Empleado (superentidad)
CREATE TABLE empleado (
  id_empleado INT IDENTITY(1,1) NOT NULL,
  nombre_pila VARCHAR(60) NOT NULL,
  ap_paterno VARCHAR(60) NOT NULL,
  ap_materno VARCHAR(60) NULL,
  rfc VARCHAR(13) NOT NULL,
  fecha_ingreso DATE NOT NULL,
  CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
  CONSTRAINT uq_empleado_rfc UNIQUE (rfc),
  CONSTRAINT ck_empleado_rfc CHECK (LEN(rfc) BETWEEN 12 AND 13)
);
GO

-- Veterinario (subentidad de Empleado)
CREATE TABLE veterinario (
  id_empleado INT NOT NULL,
  cedula_profesional VARCHAR(15) NOT NULL,
  CONSTRAINT pk_veterinario PRIMARY KEY (id_empleado),
  CONSTRAINT uq_veterinario_cedula_profesional UNIQUE (cedula_profesional),
  CONSTRAINT fk_veterinario_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Especialidades del veterinario
CREATE TABLE veterinario_especialidad (
  id_empleado INT NOT NULL,
  especialidad VARCHAR(60) NOT NULL,
  CONSTRAINT pk_veterinario_especialidad PRIMARY KEY (id_empleado, especialidad),
  CONSTRAINT fk_veterinario_especialidad_veterinario FOREIGN KEY (id_empleado) REFERENCES veterinario (id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Veterinario especialista (nivel 3)
CREATE TABLE veterinario_especialista (
  id_empleado INT NOT NULL,
  subespecialidad VARCHAR(60) NOT NULL,
  CONSTRAINT pk_veterinario_especialista PRIMARY KEY (id_empleado),
  CONSTRAINT fk_veterinario_especialista_veterinario FOREIGN KEY (id_empleado) REFERENCES veterinario (id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Gerente (subentidad de Empleado)
CREATE TABLE gerente (
  id_empleado INT NOT NULL,
  departamento VARCHAR(60) NOT NULL,
  CONSTRAINT pk_gerente PRIMARY KEY (id_empleado),
  CONSTRAINT fk_gerente_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Recepcionista (subentidad de Empleado)
CREATE TABLE recepcionista (
  id_empleado INT NOT NULL,
  turno VARCHAR(12) NOT NULL,
  CONSTRAINT pk_recepcionista PRIMARY KEY (id_empleado),
  CONSTRAINT ck_recepcionista_turno CHECK (turno IN ('MATUTINO','VESPERTINO','NOCTURNO')),
  CONSTRAINT fk_recepcionista_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Auxiliar (subentidad de Empleado)
CREATE TABLE auxiliar (
  id_empleado INT NOT NULL,
  area_asignada VARCHAR(60) NOT NULL,
  CONSTRAINT pk_auxiliar PRIMARY KEY (id_empleado),
  CONSTRAINT fk_auxiliar_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- Cita (relación Agenda, M:N)
CREATE TABLE cita (
  id_cita INT IDENTITY(1,1) NOT NULL,
  id_mascota INT NOT NULL,
  id_veterinario INT NOT NULL,
  fecha_hora DATETIME2(0) NOT NULL,
  motivo VARCHAR(255) NULL,
  estado VARCHAR(12) NOT NULL CONSTRAINT df_cita_estado DEFAULT 'PROGRAMADA',
  CONSTRAINT pk_cita PRIMARY KEY (id_cita),
  CONSTRAINT uq_cita_id_veterinario_fecha_hora UNIQUE (id_veterinario, fecha_hora),
  CONSTRAINT ck_cita_estado CHECK (estado IN ('PROGRAMADA','ATENDIDA','CANCELADA','NO_ASISTIO')),
  CONSTRAINT fk_cita_mascota FOREIGN KEY (id_mascota) REFERENCES mascota (id_mascota)
    ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_cita_veterinario FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_empleado)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Consulta (relación Atiende, M:N; agregada)
CREATE TABLE consulta (
  folio INT IDENTITY(1,1) NOT NULL,
  id_mascota INT NOT NULL,
  id_veterinario INT NOT NULL,
  fecha DATE NOT NULL,
  diagnostico VARCHAR(255) NULL,
  observaciones VARCHAR(255) NULL,
  CONSTRAINT pk_consulta PRIMARY KEY (folio),
  CONSTRAINT fk_consulta_mascota FOREIGN KEY (id_mascota) REFERENCES mascota (id_mascota)
    ON UPDATE CASCADE ON DELETE NO ACTION,
  CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_empleado)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Medicamento
CREATE TABLE medicamento (
  id_medicamento INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  presentacion VARCHAR(60) NULL,
  existencia INT NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_medicamento PRIMARY KEY (id_medicamento),
  CONSTRAINT ck_medicamento_existencia CHECK (existencia >= 0),
  CONSTRAINT ck_medicamento_precio CHECK (precio >= 0)
);
GO

-- Proveedor
CREATE TABLE proveedor (
  id_proveedor INT IDENTITY(1,1) NOT NULL,
  razon_social VARCHAR(60) NOT NULL,
  contacto VARCHAR(255) NULL,
  CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
);
GO

-- Vacuna
CREATE TABLE vacuna (
  id_vacuna INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  enfermedad_prevenida VARCHAR(60) NOT NULL,
  CONSTRAINT pk_vacuna PRIMARY KEY (id_vacuna)
);
GO

-- Lote de vacuna
CREATE TABLE lote_vacuna (
  id_lote INT IDENTITY(1,1) NOT NULL,
  id_vacuna INT NOT NULL,
  codigo_lote VARCHAR(60) NOT NULL,
  caducidad DATE NOT NULL,
  CONSTRAINT pk_lote_vacuna PRIMARY KEY (id_lote),
  CONSTRAINT uq_lote_vacuna_id_vacuna_codigo_lote UNIQUE (id_vacuna, codigo_lote),
  CONSTRAINT fk_lote_vacuna_vacuna FOREIGN KEY (id_vacuna) REFERENCES vacuna (id_vacuna)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Receta (relación M:N sobre la agregación)
CREATE TABLE receta (
  folio INT NOT NULL,
  id_medicamento INT NOT NULL,
  dosis VARCHAR(60) NOT NULL,
  duracion VARCHAR(60) NOT NULL,
  CONSTRAINT pk_receta PRIMARY KEY (folio, id_medicamento),
  CONSTRAINT fk_receta_consulta FOREIGN KEY (folio) REFERENCES consulta (folio)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_receta_medicamento FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Aplica (relación M:N sobre la agregación)
CREATE TABLE aplica (
  folio INT NOT NULL,
  id_lote INT NOT NULL,
  CONSTRAINT pk_aplica PRIMARY KEY (folio, id_lote),
  CONSTRAINT fk_aplica_consulta FOREIGN KEY (folio) REFERENCES consulta (folio)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_aplica_lote_vacuna FOREIGN KEY (id_lote) REFERENCES lote_vacuna (id_lote)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Suministra (relación M:N)
CREATE TABLE suministra (
  id_medicamento INT NOT NULL,
  id_proveedor INT NOT NULL,
  CONSTRAINT pk_suministra PRIMARY KEY (id_medicamento, id_proveedor),
  CONSTRAINT fk_suministra_medicamento FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_suministra_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor (id_proveedor)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- Factura (relación Genera, 1:1)
CREATE TABLE factura (
  no_factura INT IDENTITY(1,1) NOT NULL,
  folio INT NOT NULL,
  fecha DATE NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_factura PRIMARY KEY (no_factura),
  CONSTRAINT uq_factura_folio UNIQUE (folio),
  CONSTRAINT ck_factura_subtotal CHECK (subtotal >= 0),
  CONSTRAINT fk_factura_consulta FOREIGN KEY (folio) REFERENCES consulta (folio)
    ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- ===== Índices sobre llaves foráneas (SQL Server no los crea automáticamente) =====
CREATE INDEX idx_mascota_id_propietario ON mascota (id_propietario);
CREATE INDEX idx_mascota_id_especie_tipo ON mascota (id_especie, tipo);
CREATE INDEX idx_mascota_id_raza_id_especie ON mascota (id_raza, id_especie);
CREATE INDEX idx_canino_id_mascota_tipo ON canino (id_mascota, tipo);
CREATE INDEX idx_felino_id_mascota_tipo ON felino (id_mascota, tipo);
CREATE INDEX idx_exotico_id_mascota_tipo ON exotico (id_mascota, tipo);
CREATE INDEX idx_cita_id_mascota ON cita (id_mascota);
CREATE INDEX idx_consulta_id_mascota ON consulta (id_mascota);
CREATE INDEX idx_consulta_id_veterinario ON consulta (id_veterinario);
CREATE INDEX idx_receta_id_medicamento ON receta (id_medicamento);
CREATE INDEX idx_aplica_id_lote ON aplica (id_lote);
CREATE INDEX idx_suministra_id_proveedor ON suministra (id_proveedor);
GO

-- ===== Vistas: atributos derivados =====
CREATE VIEW v_mascota AS
SELECT m.*,
       DATEDIFF(YEAR, m.fecha_nacimiento, GETDATE())
       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.fecha_nacimiento, GETDATE()), m.fecha_nacimiento) > CAST(GETDATE() AS DATE)
              THEN 1 ELSE 0 END AS edad
FROM mascota m;
GO

CREATE VIEW v_empleado AS
SELECT e.*,
       DATEDIFF(YEAR, e.fecha_ingreso, GETDATE())
       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, e.fecha_ingreso, GETDATE()), e.fecha_ingreso) > CAST(GETDATE() AS DATE)
              THEN 1 ELSE 0 END AS antiguedad
FROM empleado e;
GO

-- total = subtotal de servicios + precio de los medicamentos recetados en la consulta
CREATE VIEW v_factura AS
SELECT f.*, f.subtotal + COALESCE((SELECT SUM(md.precio)
                                    FROM receta rc
                                    JOIN medicamento md ON md.id_medicamento = rc.id_medicamento
                                   WHERE rc.folio = f.folio), 0) AS total
FROM factura f;
GO

-- ===== Descripciones (propiedad extendida MS_Description = diccionario dentro del SGBD) =====
EXEC sys.sp_addextendedproperty N'MS_Description', N'Propietario',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador del propietario',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'id_propietario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre(s) de pila',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'nombre_pila';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Apellido paterno',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'ap_paterno';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Apellido materno',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'ap_materno';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Calle y número del domicilio',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'calle';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Colonia',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'colonia';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Código postal (5 dígitos)',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'cp';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Correo electrónico de contacto (único)',
     N'SCHEMA', N'dbo', N'TABLE', N'propietario', N'COLUMN', N'correo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfonos del propietario',
     N'SCHEMA', N'dbo', N'TABLE', N'telefono_propietario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Propietario dueño del teléfono',
     N'SCHEMA', N'dbo', N'TABLE', N'telefono_propietario', N'COLUMN', N'id_propietario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de contacto (multivalorado)',
     N'SCHEMA', N'dbo', N'TABLE', N'telefono_propietario', N'COLUMN', N'telefono';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Catálogo de especies',
     N'SCHEMA', N'dbo', N'TABLE', N'especie';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de la especie',
     N'SCHEMA', N'dbo', N'TABLE', N'especie', N'COLUMN', N'id_especie';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la especie (único)',
     N'SCHEMA', N'dbo', N'TABLE', N'especie', N'COLUMN', N'nombre';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Categoría de la especialización: CANINO, FELINO o EXOTICO',
     N'SCHEMA', N'dbo', N'TABLE', N'especie', N'COLUMN', N'tipo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Catálogo de razas',
     N'SCHEMA', N'dbo', N'TABLE', N'raza';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de la raza',
     N'SCHEMA', N'dbo', N'TABLE', N'raza', N'COLUMN', N'id_raza';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Especie a la que pertenece la raza',
     N'SCHEMA', N'dbo', N'TABLE', N'raza', N'COLUMN', N'id_especie';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la raza',
     N'SCHEMA', N'dbo', N'TABLE', N'raza', N'COLUMN', N'nombre';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Mascota (superentidad)',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de la mascota',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'id_mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la mascota',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'nombre';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Especie del animal (catálogo)',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'id_especie';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Raza (opcional); debe pertenecer a la especie',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'id_raza';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de nacimiento (base de la edad derivada)',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'fecha_nacimiento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Peso en kilogramos (mayor que 0)',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'peso';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Discriminador de la especialización: CANINO, FELINO o EXOTICO',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'tipo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Propietario responsable de la mascota',
     N'SCHEMA', N'dbo', N'TABLE', N'mascota', N'COLUMN', N'id_propietario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Canino (subentidad de Mascota)',
     N'SCHEMA', N'dbo', N'TABLE', N'canino';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Mascota a la que corresponde el subtipo (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'canino', N'COLUMN', N'id_mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Discriminador fijo ''CANINO'' (garantiza la disyunción)',
     N'SCHEMA', N'dbo', N'TABLE', N'canino', N'COLUMN', N'tipo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Tamaño: PEQUENO, MEDIANO o GRANDE',
     N'SCHEMA', N'dbo', N'TABLE', N'canino', N'COLUMN', N'tamano';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nivel de adiestramiento',
     N'SCHEMA', N'dbo', N'TABLE', N'canino', N'COLUMN', N'nivel_adiestramiento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Felino (subentidad de Mascota)',
     N'SCHEMA', N'dbo', N'TABLE', N'felino';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Mascota a la que corresponde el subtipo (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'felino', N'COLUMN', N'id_mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Discriminador fijo ''FELINO'' (garantiza la disyunción)',
     N'SCHEMA', N'dbo', N'TABLE', N'felino', N'COLUMN', N'tipo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de pelaje',
     N'SCHEMA', N'dbo', N'TABLE', N'felino', N'COLUMN', N'pelaje';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si el felino está esterilizado',
     N'SCHEMA', N'dbo', N'TABLE', N'felino', N'COLUMN', N'esterilizado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Exótico (subentidad de Mascota)',
     N'SCHEMA', N'dbo', N'TABLE', N'exotico';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Mascota a la que corresponde el subtipo (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'exotico', N'COLUMN', N'id_mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Discriminador fijo ''EXOTICO'' (garantiza la disyunción)',
     N'SCHEMA', N'dbo', N'TABLE', N'exotico', N'COLUMN', N'tipo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de hábitat requerido',
     N'SCHEMA', N'dbo', N'TABLE', N'exotico', N'COLUMN', N'tipo_habitat';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si la especie requiere permiso legal',
     N'SCHEMA', N'dbo', N'TABLE', N'exotico', N'COLUMN', N'requiere_permiso';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Empleado (superentidad)',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador del empleado',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre(s) de pila',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado', N'COLUMN', N'nombre_pila';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Apellido paterno',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado', N'COLUMN', N'ap_paterno';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Apellido materno',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado', N'COLUMN', N'ap_materno';
EXEC sys.sp_addextendedproperty N'MS_Description', N'RFC del empleado (único)',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado', N'COLUMN', N'rfc';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de ingreso (base de la antigüedad derivada)',
     N'SCHEMA', N'dbo', N'TABLE', N'empleado', N'COLUMN', N'fecha_ingreso';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Veterinario (subentidad de Empleado)',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Empleado al que corresponde el rol (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Cédula profesional (única)',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario', N'COLUMN', N'cedula_profesional';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Especialidades del veterinario',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario_especialidad';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Veterinario al que pertenece la especialidad',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario_especialidad', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Especialidad (multivalorado)',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario_especialidad', N'COLUMN', N'especialidad';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Veterinario especialista (nivel 3)',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario_especialista';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Empleado al que corresponde el rol (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario_especialista', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Subespecialidad del veterinario especialista',
     N'SCHEMA', N'dbo', N'TABLE', N'veterinario_especialista', N'COLUMN', N'subespecialidad';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Gerente (subentidad de Empleado)',
     N'SCHEMA', N'dbo', N'TABLE', N'gerente';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Empleado al que corresponde el rol (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'gerente', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Departamento administrativo a cargo',
     N'SCHEMA', N'dbo', N'TABLE', N'gerente', N'COLUMN', N'departamento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Recepcionista (subentidad de Empleado)',
     N'SCHEMA', N'dbo', N'TABLE', N'recepcionista';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Empleado al que corresponde el rol (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'recepcionista', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Turno: MATUTINO, VESPERTINO o NOCTURNO',
     N'SCHEMA', N'dbo', N'TABLE', N'recepcionista', N'COLUMN', N'turno';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Auxiliar (subentidad de Empleado)',
     N'SCHEMA', N'dbo', N'TABLE', N'auxiliar';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Empleado al que corresponde el rol (PK y FK)',
     N'SCHEMA', N'dbo', N'TABLE', N'auxiliar', N'COLUMN', N'id_empleado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Área en la que trabaja el auxiliar',
     N'SCHEMA', N'dbo', N'TABLE', N'auxiliar', N'COLUMN', N'area_asignada';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Cita (relación Agenda, M:N)',
     N'SCHEMA', N'dbo', N'TABLE', N'cita';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de la cita',
     N'SCHEMA', N'dbo', N'TABLE', N'cita', N'COLUMN', N'id_cita';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Mascota para la que se agenda la cita',
     N'SCHEMA', N'dbo', N'TABLE', N'cita', N'COLUMN', N'id_mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Veterinario (empleado) asignado',
     N'SCHEMA', N'dbo', N'TABLE', N'cita', N'COLUMN', N'id_veterinario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha y hora programadas de la cita',
     N'SCHEMA', N'dbo', N'TABLE', N'cita', N'COLUMN', N'fecha_hora';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Motivo de la cita',
     N'SCHEMA', N'dbo', N'TABLE', N'cita', N'COLUMN', N'motivo';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado: PROGRAMADA, ATENDIDA, CANCELADA o NO_ASISTIO',
     N'SCHEMA', N'dbo', N'TABLE', N'cita', N'COLUMN', N'estado';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Consulta (relación Atiende, M:N; agregada)',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Folio de la consulta',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta', N'COLUMN', N'folio';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Mascota atendida',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta', N'COLUMN', N'id_mascota';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Veterinario que realizó la atención',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta', N'COLUMN', N'id_veterinario';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de la atención',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta', N'COLUMN', N'fecha';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Diagnóstico del veterinario',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta', N'COLUMN', N'diagnostico';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Observaciones de la atención',
     N'SCHEMA', N'dbo', N'TABLE', N'consulta', N'COLUMN', N'observaciones';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Medicamento',
     N'SCHEMA', N'dbo', N'TABLE', N'medicamento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador del medicamento',
     N'SCHEMA', N'dbo', N'TABLE', N'medicamento', N'COLUMN', N'id_medicamento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del medicamento',
     N'SCHEMA', N'dbo', N'TABLE', N'medicamento', N'COLUMN', N'nombre';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Presentación comercial',
     N'SCHEMA', N'dbo', N'TABLE', N'medicamento', N'COLUMN', N'presentacion';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Unidades en existencia (no negativa)',
     N'SCHEMA', N'dbo', N'TABLE', N'medicamento', N'COLUMN', N'existencia';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Precio unitario (no negativo)',
     N'SCHEMA', N'dbo', N'TABLE', N'medicamento', N'COLUMN', N'precio';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Proveedor',
     N'SCHEMA', N'dbo', N'TABLE', N'proveedor';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador del proveedor',
     N'SCHEMA', N'dbo', N'TABLE', N'proveedor', N'COLUMN', N'id_proveedor';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Razón social del proveedor',
     N'SCHEMA', N'dbo', N'TABLE', N'proveedor', N'COLUMN', N'razon_social';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Datos de contacto',
     N'SCHEMA', N'dbo', N'TABLE', N'proveedor', N'COLUMN', N'contacto';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Vacuna',
     N'SCHEMA', N'dbo', N'TABLE', N'vacuna';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de la vacuna',
     N'SCHEMA', N'dbo', N'TABLE', N'vacuna', N'COLUMN', N'id_vacuna';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la vacuna',
     N'SCHEMA', N'dbo', N'TABLE', N'vacuna', N'COLUMN', N'nombre';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Enfermedad que previene',
     N'SCHEMA', N'dbo', N'TABLE', N'vacuna', N'COLUMN', N'enfermedad_prevenida';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Lote de vacuna',
     N'SCHEMA', N'dbo', N'TABLE', N'lote_vacuna';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador del lote de vacuna',
     N'SCHEMA', N'dbo', N'TABLE', N'lote_vacuna', N'COLUMN', N'id_lote';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Vacuna a la que pertenece el lote',
     N'SCHEMA', N'dbo', N'TABLE', N'lote_vacuna', N'COLUMN', N'id_vacuna';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del lote impreso en el envase',
     N'SCHEMA', N'dbo', N'TABLE', N'lote_vacuna', N'COLUMN', N'codigo_lote';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de caducidad del lote (se guarda una sola vez)',
     N'SCHEMA', N'dbo', N'TABLE', N'lote_vacuna', N'COLUMN', N'caducidad';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Receta (relación M:N sobre la agregación)',
     N'SCHEMA', N'dbo', N'TABLE', N'receta';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Consulta en la que se receta',
     N'SCHEMA', N'dbo', N'TABLE', N'receta', N'COLUMN', N'folio';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Medicamento recetado',
     N'SCHEMA', N'dbo', N'TABLE', N'receta', N'COLUMN', N'id_medicamento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Dosis indicada',
     N'SCHEMA', N'dbo', N'TABLE', N'receta', N'COLUMN', N'dosis';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Duración del tratamiento',
     N'SCHEMA', N'dbo', N'TABLE', N'receta', N'COLUMN', N'duracion';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Aplica (relación M:N sobre la agregación)',
     N'SCHEMA', N'dbo', N'TABLE', N'aplica';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Consulta en la que se aplica la vacuna',
     N'SCHEMA', N'dbo', N'TABLE', N'aplica', N'COLUMN', N'folio';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Lote aplicado (determina vacuna y caducidad)',
     N'SCHEMA', N'dbo', N'TABLE', N'aplica', N'COLUMN', N'id_lote';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Suministra (relación M:N)',
     N'SCHEMA', N'dbo', N'TABLE', N'suministra';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Medicamento suministrado',
     N'SCHEMA', N'dbo', N'TABLE', N'suministra', N'COLUMN', N'id_medicamento';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Proveedor que lo suministra',
     N'SCHEMA', N'dbo', N'TABLE', N'suministra', N'COLUMN', N'id_proveedor';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Factura (relación Genera, 1:1)',
     N'SCHEMA', N'dbo', N'TABLE', N'factura';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de factura',
     N'SCHEMA', N'dbo', N'TABLE', N'factura', N'COLUMN', N'no_factura';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Consulta que originó la factura (relación 1:1)',
     N'SCHEMA', N'dbo', N'TABLE', N'factura', N'COLUMN', N'folio';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de emisión de la factura',
     N'SCHEMA', N'dbo', N'TABLE', N'factura', N'COLUMN', N'fecha';
EXEC sys.sp_addextendedproperty N'MS_Description', N'Subtotal de servicios (no negativo)',
     N'SCHEMA', N'dbo', N'TABLE', N'factura', N'COLUMN', N'subtotal';
GO

SELECT @@VERSION AS version_del_servidor;
