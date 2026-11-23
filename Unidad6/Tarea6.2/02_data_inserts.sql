-- =====================================================================
-- 02_data_inserts.sql: FASE LMD (INSERT) · datos de prueba para pruebas de integridad referencial
-- Requiere haber ejecutado 01_schema_ddl.sql. Los identificadores (IDENTITY) se generan solos.
-- Orden: primero las tablas padre, después las hijas (respeta las llaves foráneas).
-- =====================================================================

USE veterinaria;
GO

INSERT INTO propietario (nombre_pila, ap_paterno, ap_materno, calle, colonia, cp, correo) VALUES
  ('Laura','Gómez','Pérez','Av. Hidalgo 120','Centro','25700','laura.gomez@mail.com'),
  ('Carlos','Ramírez',NULL,'Calle Juárez 45','Guadalupe','25750','carlos.ramirez@mail.com'),
  ('Ana','Treviño','Salas','Blvd. Harold R. Pape 800','Pape','25730',NULL),
  ('Jorge','Villarreal','Cano','Calle Morelos 310','Los Pinos','25720','jorge.villarreal@mail.com'),
  ('María','Fernández','Ruiz','Av. Universidad 77','Burócratas','25740','maria.fernandez@mail.com'),
  ('Luis','Herrera','Soto','Calle 5 de Mayo 12','Centro','25700',NULL);

INSERT INTO telefono_propietario (id_propietario, telefono) VALUES
  (1,'8661234567'),
  (1,'8669876543'),
  (2,'8665551122'),
  (3,'8664447788'),
  (4,'8662223344'),
  (5,'8661112233'),
  (5,'8665556677');

INSERT INTO especie (nombre, tipo) VALUES
  ('Perro','CANINO'),
  ('Gato','FELINO'),
  ('Ave','EXOTICO'),
  ('Conejo','EXOTICO');

INSERT INTO raza (id_especie, nombre) VALUES
  (1,'Labrador'),
  (1,'Chihuahua'),
  (1,'Pastor Alemán'),
  (2,'Siamés'),
  (2,'Persa'),
  (3,'Perico australiano'),
  (4,'Cabeza de león');

INSERT INTO mascota (nombre, id_especie, id_raza, fecha_nacimiento, peso, tipo, id_propietario) VALUES
  ('Rex',1,1,'2019-03-15',28.50,'CANINO',1),
  ('Luna',1,2,'2021-07-02',3.20,'CANINO',2),
  ('Michi',2,4,'2020-11-20',4.10,'FELINO',1),
  ('Nala',2,5,'2022-01-10',3.80,'FELINO',3),
  ('Kiwi',3,6,'2023-05-05',0.04,'EXOTICO',3),
  ('Thor',1,3,'2018-09-30',34.00,'CANINO',4),
  ('Misu',2,NULL,'2021-12-01',4.50,'FELINO',5),
  ('Bunny',4,7,'2022-04-18',1.80,'EXOTICO',5),
  ('Toby',1,NULL,'2024-02-10',12.00,'CANINO',4),
  ('Pelusa',2,5,'2019-06-25',5.20,'FELINO',2);

INSERT INTO canino (id_mascota, tipo, tamano, nivel_adiestramiento) VALUES
  (1,'CANINO','GRANDE','Avanzado'),
  (2,'CANINO','PEQUENO',NULL),
  (6,'CANINO','GRANDE','Intermedio'),
  (9,'CANINO','MEDIANO','Básico');

INSERT INTO felino (id_mascota, tipo, pelaje, esterilizado) VALUES
  (3,'FELINO','Corto',1),
  (4,'FELINO','Largo',0),
  (7,'FELINO','Corto',1),
  (10,'FELINO','Largo',1);

INSERT INTO exotico (id_mascota, tipo, tipo_habitat, requiere_permiso) VALUES
  (5,'EXOTICO','Jaula amplia',0),
  (8,'EXOTICO','Corral interior',0);

INSERT INTO empleado (nombre_pila, ap_paterno, ap_materno, rfc, fecha_ingreso) VALUES
  ('Miguel','Rojas','Díaz','ROD850101AB1','2015-02-01'),
  ('Sofía','Martínez','Lara','MALS900505CD2','2018-08-15'),
  ('Daniela','Cruz','Ibarra','CUID950710EF3','2020-01-10'),
  ('Jorge','Salinas','Vega','SAVJ000303GH4','2022-06-01'),
  ('Andrés','Pérez','Luna','PELA880820IJ5','2019-03-04');

INSERT INTO veterinario (id_empleado, cedula_profesional) VALUES
  (1,'CED1234567'),
  (2,'CED7654321'),
  (5,'CED5551234');

INSERT INTO veterinario_especialidad (id_empleado, especialidad) VALUES
  (1,'Medicina general'),
  (1,'Cirugía'),
  (2,'Dermatología'),
  (5,'Cardiología');

INSERT INTO veterinario_especialista (id_empleado, subespecialidad) VALUES
  (2,'Dermatología felina');

INSERT INTO gerente (id_empleado, departamento) VALUES
  (2,'Administración');

INSERT INTO recepcionista (id_empleado, turno) VALUES
  (3,'MATUTINO');

INSERT INTO auxiliar (id_empleado, area_asignada) VALUES
  (4,'Hospitalización');

INSERT INTO medicamento (nombre, presentacion, existencia, precio) VALUES
  ('Amoxicilina','Tabletas 250 mg',50,120.00),
  ('Meloxicam','Suspensión 10 ml',30,95.50),
  ('Ivermectina','Inyectable 50 ml',20,210.00),
  ('Carprofeno','Tabletas 75 mg',0,180.00),
  ('Enrofloxacina','Tabletas 50 mg',15,150.00);

INSERT INTO proveedor (razon_social, contacto) VALUES
  ('Distribuidora Vet del Norte SA de CV','ventas@vetnorte.mx'),
  ('Farmacéutica Animal Monclova','866-555-0101'),
  ('Laboratorios Canina SA','contacto@labcanina.mx');

INSERT INTO suministra (id_medicamento, id_proveedor) VALUES
  (1,1),
  (2,1),
  (2,2),
  (3,2),
  (4,3),
  (5,1),
  (5,3);

INSERT INTO vacuna (nombre, enfermedad_prevenida) VALUES
  ('Rabia anual','Rabia'),
  ('Triple felina','Panleucopenia, rinotraqueitis y calicivirus'),
  ('Parvovirus','Parvovirosis canina');

INSERT INTO lote_vacuna (id_vacuna, codigo_lote, caducidad) VALUES
  (1,'LOTE-R-2026-A','2027-06-30'),
  (1,'LOTE-R-2025-Z','2026-01-31'),
  (2,'LOTE-TF-2026-B','2027-03-31'),
  (3,'LOTE-P-2026-C','2027-09-15');

INSERT INTO cita (id_mascota, id_veterinario, fecha_hora, motivo, estado) VALUES
  (1,1,'2026-10-05 10:00:00','Revisión general','ATENDIDA'),
  (3,2,'2026-10-06 11:30:00','Problema de piel','ATENDIDA'),
  (2,1,'2026-11-12 09:00:00','Vacunación','PROGRAMADA'),
  (6,5,'2026-10-15 16:00:00','Chequeo cardiaco','ATENDIDA'),
  (7,2,'2026-10-20 12:00:00','Control de peso','ATENDIDA'),
  (8,1,'2026-11-18 10:30:00','Revisión dental','PROGRAMADA'),
  (4,2,'2026-10-25 09:30:00','Vacunación','CANCELADA'),
  (9,5,'2026-11-20 15:00:00','Primera vacuna','PROGRAMADA');

INSERT INTO consulta (id_mascota, id_veterinario, fecha, diagnostico, observaciones) VALUES
  (1,1,'2026-10-05','Otitis leve','Limpieza y tratamiento tópico'),
  (3,2,'2026-10-06','Dermatitis alérgica','Revisión en 15 días'),
  (6,5,'2026-10-15','Soplo cardiaco leve','Seguimiento en 3 meses'),
  (7,2,'2026-10-20','Sobrepeso','Dieta controlada'),
  (1,1,'2026-10-28','Control de otitis','Sin observaciones'),
  (2,1,'2026-10-30','Control sano','Sin observaciones'),
  (3,2,'2026-11-03','Dermatitis resuelta','Alta');

INSERT INTO receta (folio, id_medicamento, dosis, duracion) VALUES
  (1,1,'1 tableta cada 12 h','7 días'),
  (1,2,'0.1 ml/kg cada 24 h','3 días'),
  (2,2,'0.1 ml/kg cada 24 h','5 días'),
  (3,5,'1 tableta cada 24 h','30 días'),
  (5,1,'1 tableta cada 12 h','5 días'),
  (7,2,'0.1 ml/kg cada 24 h','2 días');

INSERT INTO aplica (folio, id_lote) VALUES
  (1,1),
  (2,3),
  (3,1),
  (6,4);

INSERT INTO factura (folio, fecha, subtotal) VALUES
  (1,'2026-10-05',450.00),
  (2,'2026-10-06',380.00),
  (3,'2026-10-15',620.00),
  (4,'2026-10-20',300.00),
  (5,'2026-10-28',250.00),
  (6,'2026-10-30',200.00);

GO

-- Verificación: filas por tabla
SELECT 'propietario' AS tabla, COUNT(*) AS filas FROM propietario
UNION ALL
SELECT 'telefono_propietario' AS tabla, COUNT(*) AS filas FROM telefono_propietario
UNION ALL
SELECT 'especie' AS tabla, COUNT(*) AS filas FROM especie
UNION ALL
SELECT 'raza' AS tabla, COUNT(*) AS filas FROM raza
UNION ALL
SELECT 'mascota' AS tabla, COUNT(*) AS filas FROM mascota
UNION ALL
SELECT 'canino' AS tabla, COUNT(*) AS filas FROM canino
UNION ALL
SELECT 'felino' AS tabla, COUNT(*) AS filas FROM felino
UNION ALL
SELECT 'exotico' AS tabla, COUNT(*) AS filas FROM exotico
UNION ALL
SELECT 'empleado' AS tabla, COUNT(*) AS filas FROM empleado
UNION ALL
SELECT 'veterinario' AS tabla, COUNT(*) AS filas FROM veterinario
UNION ALL
SELECT 'veterinario_especialidad' AS tabla, COUNT(*) AS filas FROM veterinario_especialidad
UNION ALL
SELECT 'veterinario_especialista' AS tabla, COUNT(*) AS filas FROM veterinario_especialista
UNION ALL
SELECT 'gerente' AS tabla, COUNT(*) AS filas FROM gerente
UNION ALL
SELECT 'recepcionista' AS tabla, COUNT(*) AS filas FROM recepcionista
UNION ALL
SELECT 'auxiliar' AS tabla, COUNT(*) AS filas FROM auxiliar
UNION ALL
SELECT 'cita' AS tabla, COUNT(*) AS filas FROM cita
UNION ALL
SELECT 'consulta' AS tabla, COUNT(*) AS filas FROM consulta
UNION ALL
SELECT 'medicamento' AS tabla, COUNT(*) AS filas FROM medicamento
UNION ALL
SELECT 'proveedor' AS tabla, COUNT(*) AS filas FROM proveedor
UNION ALL
SELECT 'vacuna' AS tabla, COUNT(*) AS filas FROM vacuna
UNION ALL
SELECT 'lote_vacuna' AS tabla, COUNT(*) AS filas FROM lote_vacuna
UNION ALL
SELECT 'receta' AS tabla, COUNT(*) AS filas FROM receta
UNION ALL
SELECT 'aplica' AS tabla, COUNT(*) AS filas FROM aplica
UNION ALL
SELECT 'suministra' AS tabla, COUNT(*) AS filas FROM suministra
UNION ALL
SELECT 'factura' AS tabla, COUNT(*) AS filas FROM factura
ORDER BY tabla;
GO
