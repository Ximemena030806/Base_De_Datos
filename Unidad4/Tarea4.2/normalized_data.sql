-- normalized_data.sql: datos de prueba (los identificadores IDENTITY se generan solos: no se capturan)
USE veterinaria;
GO

INSERT INTO propietario (nombre_pila, ap_paterno, ap_materno, calle, colonia, cp, correo) VALUES
  ('Laura','Gómez','Pérez','Av. Hidalgo 120','Centro','25700','laura.gomez@mail.com'),
  ('Carlos','Ramírez',NULL,'Calle Juárez 45','Guadalupe','25750','carlos.ramirez@mail.com'),
  ('Ana','Treviño','Salas','Blvd. Harold R. Pape 800','Pape','25730',NULL);

INSERT INTO telefono_propietario (id_propietario, telefono) VALUES
  (1,'8661234567'),
  (1,'8669876543'),
  (2,'8665551122'),
  (3,'8664447788');

INSERT INTO especie (nombre, tipo) VALUES
  ('Perro','CANINO'),
  ('Gato','FELINO'),
  ('Ave','EXOTICO');

INSERT INTO raza (id_especie, nombre) VALUES
  (1,'Labrador'),
  (1,'Chihuahua'),
  (2,'Siamés'),
  (2,'Persa'),
  (3,'Perico australiano');

INSERT INTO mascota (nombre, id_especie, id_raza, fecha_nacimiento, peso, tipo, id_propietario) VALUES
  ('Rex',1,1,'2019-03-15',28.50,'CANINO',1),
  ('Luna',1,2,'2021-07-02',3.20,'CANINO',2),
  ('Michi',2,3,'2020-11-20',4.10,'FELINO',1),
  ('Nala',2,4,'2022-01-10',3.80,'FELINO',3),
  ('Kiwi',3,5,'2023-05-05',0.04,'EXOTICO',3);

INSERT INTO canino (id_mascota, tipo, tamano, nivel_adiestramiento) VALUES
  (1,'CANINO','GRANDE','Avanzado'),
  (2,'CANINO','PEQUENO',NULL);

INSERT INTO felino (id_mascota, tipo, pelaje, esterilizado) VALUES
  (3,'FELINO','Corto',1),
  (4,'FELINO','Largo',0);

INSERT INTO exotico (id_mascota, tipo, tipo_habitat, requiere_permiso) VALUES
  (5,'EXOTICO','Jaula amplia',0);

INSERT INTO empleado (nombre_pila, ap_paterno, ap_materno, rfc, fecha_ingreso) VALUES
  ('Miguel','Rojas','Díaz','ROD850101AB1','2015-02-01'),
  ('Sofía','Martínez','Lara','MALS900505CD2','2018-08-15'),
  ('Daniela','Cruz','Ibarra','CUID950710EF3','2020-01-10'),
  ('Jorge','Salinas','Vega','SAVJ000303GH4','2022-06-01');

INSERT INTO veterinario (id_empleado, cedula_profesional) VALUES
  (1,'CED1234567'),
  (2,'CED7654321');

INSERT INTO veterinario_especialidad (id_empleado, especialidad) VALUES
  (1,'Medicina general'),
  (1,'Cirugía'),
  (2,'Dermatología');

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
  ('Ivermectina','Inyectable 50 ml',20,210.00);

INSERT INTO proveedor (razon_social, contacto) VALUES
  ('Distribuidora Vet del Norte SA de CV','ventas@vetnorte.mx'),
  ('Farmacéutica Animal Monclova','866-555-0101');

INSERT INTO suministra (id_medicamento, id_proveedor) VALUES
  (1,1),
  (2,1),
  (2,2),
  (3,2);

INSERT INTO vacuna (nombre, enfermedad_prevenida) VALUES
  ('Rabia anual','Rabia'),
  ('Triple felina','Panleucopenia, rinotraqueitis y calicivirus');

INSERT INTO lote_vacuna (id_vacuna, codigo_lote, caducidad) VALUES
  (1,'LOTE-R-2026-A','2027-06-30'),
  (2,'LOTE-TF-2026-B','2027-03-31');

INSERT INTO cita (id_mascota, id_veterinario, fecha_hora, motivo, estado) VALUES
  (1,1,'2026-10-05 10:00:00','Revisión general','ATENDIDA'),
  (3,2,'2026-10-06 11:30:00','Problema de piel','ATENDIDA'),
  (2,1,'2026-11-12 09:00:00','Vacunación','PROGRAMADA');

INSERT INTO consulta (id_mascota, id_veterinario, fecha, diagnostico, observaciones) VALUES
  (1,1,'2026-10-05','Otitis leve','Limpieza y tratamiento tópico'),
  (3,2,'2026-10-06','Dermatitis alérgica','Revisión en 15 días'),
  (2,1,'2026-10-20','Control sano','Sin observaciones');

INSERT INTO receta (folio, id_medicamento, dosis, duracion) VALUES
  (1,1,'1 tableta cada 12 h','7 días'),
  (2,2,'0.1 ml/kg cada 24 h','5 días'),
  (3,3,'0.2 ml dosis única','1 día');

INSERT INTO aplica (folio, id_lote) VALUES
  (1,1),
  (2,2);

INSERT INTO factura (folio, fecha, subtotal) VALUES
  (1,'2026-10-05',450.00),
  (2,'2026-10-06',380.00);

GO
