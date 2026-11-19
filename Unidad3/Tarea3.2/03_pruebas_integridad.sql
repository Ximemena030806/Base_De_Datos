-- Script 03: pruebas de integridad. Cada prueba imprime un mensaje (pestaña Messages de SSMS).
-- «OK bloqueado» = el SGBD rechazó la operación inválida; «OK» = la operación válida produjo el efecto esperado.
-- Ejecutar UNA sola vez después del script 02 (si se repite, volver a ejecutar 01 y 02).

USE veterinaria;
GO

-- T01: Entidad: llave primaria duplicada (teléfono repetido para el mismo propietario)
BEGIN TRY
  INSERT INTO telefono_propietario (id_propietario, telefono) VALUES (1,'8661234567');
  PRINT 'T01 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T01 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T02: NOT NULL: propietario sin nombre_pila
BEGIN TRY
  INSERT INTO propietario (ap_paterno, calle, colonia, cp) VALUES ('Prueba','Calle 1','Centro','25700');
  PRINT 'T02 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T02 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T03: Referencial: mascota con propietario inexistente
BEGIN TRY
  INSERT INTO mascota (nombre, especie, fecha_nacimiento, tipo, id_propietario) VALUES ('Fantasma','Perro','2020-01-01','CANINO',999);
  PRINT 'T03 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T03 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T04: CHECK: peso menor o igual a cero
BEGIN TRY
  INSERT INTO mascota (nombre, especie, fecha_nacimiento, peso, tipo, id_propietario) VALUES ('Pesada','Perro','2020-01-01',-5,'CANINO',1);
  PRINT 'T04 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T04 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T05: CHECK: existencia negativa de medicamento
BEGIN TRY
  UPDATE medicamento SET existencia = -1 WHERE id_medicamento = 1;
  PRINT 'T05 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T05 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T06: CHECK: estado de cita fuera del dominio
BEGIN TRY
  UPDATE cita SET estado = 'BORRADA' WHERE id_cita = 1;
  PRINT 'T06 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T06 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T07: CHECK: código postal con formato inválido
BEGIN TRY
  INSERT INTO propietario (nombre_pila, ap_paterno, calle, colonia, cp) VALUES ('Luis','Prueba','Calle 2','Centro','ABCDE');
  PRINT 'T07 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T07 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T08: CHECK: tipo de mascota fuera del dominio
BEGIN TRY
  INSERT INTO mascota (nombre, especie, fecha_nacimiento, tipo, id_propietario) VALUES ('Pez','Pez','2020-01-01','ACUATICO',1);
  PRINT 'T08 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T08 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T09: UNIQUE: RFC de empleado repetido
BEGIN TRY
  INSERT INTO empleado (nombre_pila, ap_paterno, rfc, fecha_ingreso) VALUES ('Otro','Empleado','ROD850101AB1','2024-01-01');
  PRINT 'T09 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T09 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T10: UNIQUE: veterinario con dos citas a la misma hora (regla 6)
BEGIN TRY
  INSERT INTO cita (id_mascota, id_veterinario, fecha_hora, motivo) VALUES (2,1,'2026-10-05 10:00:00','Empalme');
  PRINT 'T10 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T10 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T11: UNIQUE: segunda factura para la misma consulta (relación 1:1)
BEGIN TRY
  INSERT INTO factura (folio, fecha, subtotal) VALUES (1,'2026-10-07',100);
  PRINT 'T11 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T11 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T12: Disyunción: la mascota 1 es CANINO y se intenta registrar como FELINO
BEGIN TRY
  INSERT INTO felino (id_mascota, tipo, pelaje, esterilizado) VALUES (1,'FELINO','Corto',0);
  PRINT 'T12 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T12 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T13: CHECK de subtipo: fila de CANINO con discriminador distinto
BEGIN TRY
  INSERT INTO canino (id_mascota, tipo, tamano) VALUES (4,'FELINO','GRANDE');
  PRINT 'T13 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T13 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T14: Jerarquía: especialista asignado a un empleado que no es veterinario
BEGIN TRY
  INSERT INTO veterinario_especialista (id_empleado, subespecialidad) VALUES (3,'Cardiología');
  PRINT 'T14 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T14 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T15: RESTRICT: borrar un propietario que tiene mascotas
BEGIN TRY
  DELETE FROM propietario WHERE id_propietario = 1;
  PRINT 'T15 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T15 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T16: RESTRICT: borrar un medicamento que ya fue recetado
BEGIN TRY
  DELETE FROM medicamento WHERE id_medicamento = 1;
  PRINT 'T16 FALLO: la operacion se acepto y debia rechazarse';
END TRY
BEGIN CATCH
  PRINT 'T16 OK bloqueado -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T17: Vista v_factura: total = subtotal + medicamentos recetados (450 + 120)
BEGIN TRY
  DECLARE @v NVARCHAR(50) = CAST((SELECT total FROM v_factura WHERE no_factura = 1) AS NVARCHAR(50));
  IF @v = '570.00' PRINT 'T17 OK -> resultado ' + @v;
  ELSE PRINT 'T17 FALLO -> se esperaba 570.00 y se obtuvo ' + ISNULL(@v, 'NULL');
END TRY
BEGIN CATCH
  PRINT 'T17 FALLO -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T18: ON DELETE CASCADE: al borrar la consulta 3 se borran sus recetas
BEGIN TRY
  DELETE FROM consulta WHERE folio = 3;
  DECLARE @v NVARCHAR(50) = CAST((SELECT COUNT(*) FROM receta WHERE folio = 3) AS NVARCHAR(50));
  IF @v = '0' PRINT 'T18 OK -> resultado ' + @v;
  ELSE PRINT 'T18 FALLO -> se esperaba 0 y se obtuvo ' + ISNULL(@v, 'NULL');
END TRY
BEGIN CATCH
  PRINT 'T18 FALLO -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T19: ON DELETE CASCADE: al borrar un empleado se borra su rol de auxiliar
BEGIN TRY
  DELETE FROM empleado WHERE id_empleado = 4;
  DECLARE @v NVARCHAR(50) = CAST((SELECT COUNT(*) FROM auxiliar WHERE id_empleado = 4) AS NVARCHAR(50));
  IF @v = '0' PRINT 'T19 OK -> resultado ' + @v;
  ELSE PRINT 'T19 FALLO -> se esperaba 0 y se obtuvo ' + ISNULL(@v, 'NULL');
END TRY
BEGIN CATCH
  PRINT 'T19 FALLO -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T20: ON DELETE CASCADE: al borrar un propietario sin mascotas se borran sus teléfonos
BEGIN TRY
  INSERT INTO propietario (nombre_pila, ap_paterno, calle, colonia, cp, correo) VALUES ('Temporal','Prueba','Calle 3','Centro','25700','tmp@mail.com');
  INSERT INTO telefono_propietario (id_propietario, telefono) SELECT id_propietario, '8660000000' FROM propietario WHERE correo = 'tmp@mail.com';
  DELETE FROM propietario WHERE correo = 'tmp@mail.com';
  DECLARE @v NVARCHAR(50) = CAST((SELECT COUNT(*) FROM telefono_propietario WHERE telefono = '8660000000') AS NVARCHAR(50));
  IF @v = '0' PRINT 'T20 OK -> resultado ' + @v;
  ELSE PRINT 'T20 FALLO -> se esperaba 0 y se obtuvo ' + ISNULL(@v, 'NULL');
END TRY
BEGIN CATCH
  PRINT 'T20 FALLO -> ' + ERROR_MESSAGE();
END CATCH;
GO

-- T21: ON UPDATE CASCADE: al cambiar la llave de un veterinario se actualizan sus especialidades
BEGIN TRY
  UPDATE veterinario SET id_empleado = 3 WHERE id_empleado = 2;
  DECLARE @v NVARCHAR(50) = CAST((SELECT COUNT(*) FROM veterinario_especialidad WHERE id_empleado = 3) AS NVARCHAR(50));
  IF @v = '1' PRINT 'T21 OK -> resultado ' + @v;
  ELSE PRINT 'T21 FALLO -> se esperaba 1 y se obtuvo ' + ISNULL(@v, 'NULL');
END TRY
BEGIN CATCH
  PRINT 'T21 FALLO -> ' + ERROR_MESSAGE();
END CATCH;
GO
