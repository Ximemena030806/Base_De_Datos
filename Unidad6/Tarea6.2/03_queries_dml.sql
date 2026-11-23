-- =====================================================================
-- 03_queries_dml.sql: FASE LMD (SELECT) y operaciones de mantenimiento (UPDATE / DELETE)
-- Requiere 01_schema_ddl.sql y 02_data_inserts.sql. Las pruebas de la Parte B se ejecutan dentro de
-- una transacción y se revierten (ROLLBACK): los datos de prueba no cambian.
-- =====================================================================

USE veterinaria;
GO

-- ############################  PARTE A: CONSULTAS SELECT  ############################

-- C01 · SELECT básico: Todos los propietarios registrados.
SELECT id_propietario, nombre_pila, ap_paterno, ap_materno, colonia, cp, correo
FROM propietario
ORDER BY id_propietario;
GO

-- C02 · WHERE con AND: Mascotas de tipo CANINO que pesan más de 10 kg.
SELECT id_mascota, nombre, tipo, peso
FROM mascota
WHERE tipo = 'CANINO' AND peso > 10
ORDER BY id_mascota;
GO

-- C03 · WHERE con IS NULL: Propietarios que no tienen correo electrónico registrado.
SELECT id_propietario, nombre_pila, ap_paterno
FROM propietario
WHERE correo IS NULL
ORDER BY id_propietario;
GO

-- C04 · WHERE con BETWEEN: Medicamentos con precio entre 100 y 200, del más caro al más barato.
SELECT id_medicamento, nombre, precio
FROM medicamento
WHERE precio BETWEEN 100 AND 200
ORDER BY precio DESC;
GO

-- C05 · WHERE con IN: Citas programadas o canceladas, en orden cronológico.
SELECT id_cita, id_mascota, fecha_hora, estado
FROM cita
WHERE estado IN ('PROGRAMADA', 'CANCELADA')
ORDER BY fecha_hora;
GO

-- C06 · WHERE con LIKE y OR: Mascotas cuyo nombre empieza con M o con T.
SELECT id_mascota, nombre, peso
FROM mascota
WHERE nombre LIKE 'M%' OR nombre LIKE 'T%'
ORDER BY nombre;
GO

-- C07 · ORDER BY múltiple: Mascotas ordenadas por tipo (ascendente) y peso (descendente).
SELECT nombre, tipo, peso
FROM mascota
ORDER BY tipo ASC, peso DESC;
GO

-- C08 · Funciones de agregación: Conteo, suma, promedio, máximo y mínimo sobre el inventario de medicamentos.
SELECT COUNT(*) AS total_medicamentos,
       SUM(existencia) AS existencia_total,
       AVG(precio) AS precio_promedio,
       MAX(precio) AS precio_maximo,
       MIN(precio) AS precio_minimo
FROM medicamento;
GO

-- C09 · GROUP BY: Número de mascotas, peso promedio y peso máximo por tipo.
SELECT tipo, COUNT(*) AS num_mascotas, AVG(peso) AS peso_promedio, MAX(peso) AS peso_maximo
FROM mascota
GROUP BY tipo
ORDER BY tipo;
GO

-- C10 · GROUP BY + HAVING: Propietarios con dos o más mascotas.
SELECT p.id_propietario, p.nombre_pila, p.ap_paterno, COUNT(m.id_mascota) AS num_mascotas
FROM propietario p
INNER JOIN mascota m ON m.id_propietario = p.id_propietario
GROUP BY p.id_propietario, p.nombre_pila, p.ap_paterno
HAVING COUNT(m.id_mascota) >= 2
ORDER BY num_mascotas DESC, p.id_propietario;
GO

-- C11 · INNER JOIN (3 tablas): Consultas con el nombre de la mascota y del veterinario.
SELECT c.folio, c.fecha, m.nombre AS mascota, e.nombre_pila AS veterinario, c.diagnostico
FROM consulta c
INNER JOIN mascota m ON m.id_mascota = c.id_mascota
INNER JOIN empleado e ON e.id_empleado = c.id_veterinario
ORDER BY c.fecha, c.folio;
GO

-- C12 · INNER JOIN (4 tablas): Recetas emitidas: consulta, mascota, medicamento, dosis y duración.
SELECT c.folio, m.nombre AS mascota, md.nombre AS medicamento, r.dosis, r.duracion
FROM receta r
INNER JOIN consulta c ON c.folio = r.folio
INNER JOIN mascota m ON m.id_mascota = c.id_mascota
INNER JOIN medicamento md ON md.id_medicamento = r.id_medicamento
ORDER BY c.folio, md.nombre;
GO

-- C13 · LEFT JOIN + COUNT: Número de mascotas por propietario, incluidos los que no tienen ninguna.
SELECT p.id_propietario, p.nombre_pila, COUNT(m.id_mascota) AS num_mascotas
FROM propietario p
LEFT JOIN mascota m ON m.id_propietario = p.id_propietario
GROUP BY p.id_propietario, p.nombre_pila
ORDER BY p.id_propietario;
GO

-- C14 · LEFT JOIN (filas sin pareja): Consultas que todavía no tienen factura.
SELECT c.folio, c.fecha, c.diagnostico
FROM consulta c
LEFT JOIN factura f ON f.folio = c.folio
WHERE f.no_factura IS NULL
ORDER BY c.folio;
GO

-- C15 · JOIN + SUM + GROUP BY + HAVING: Total facturado por veterinario, solo si supera 500.
SELECT e.nombre_pila AS veterinario, COUNT(f.no_factura) AS facturas, SUM(f.subtotal) AS total_facturado
FROM factura f
INNER JOIN consulta c ON c.folio = f.folio
INNER JOIN empleado e ON e.id_empleado = c.id_veterinario
GROUP BY e.id_empleado, e.nombre_pila
HAVING SUM(f.subtotal) > 500
ORDER BY total_facturado DESC;
GO

-- C16 · Subconsulta con AVG: Mascotas que pesan más que el promedio de todas.
SELECT nombre, peso
FROM mascota
WHERE peso > (SELECT AVG(peso) FROM mascota)
ORDER BY peso DESC;
GO

-- C17 · CASE: Clasificación del inventario según su existencia.
SELECT nombre, existencia,
       CASE WHEN existencia = 0 THEN 'Agotado'
            WHEN existencia < 20 THEN 'Bajo'
            ELSE 'Suficiente' END AS nivel
FROM medicamento
ORDER BY existencia, nombre;
GO

-- ####################  PARTE B: MANTENIMIENTO CON UPDATE Y DELETE  ####################
-- OK = operación válida (se muestra su efecto y se revierte); BLOQUEADO = el SGBD protege la integridad.
SET NOCOUNT OFF;
GO

-- M01 · UPDATE: Aumentar 10 % el precio de la Amoxicilina.
BEGIN TRANSACTION;
    UPDATE medicamento SET precio = precio * 1.10 WHERE id_medicamento = 1;
    SELECT (SELECT precio FROM medicamento WHERE id_medicamento = 1) AS resultado_despues;   -- esperado: 132
ROLLBACK TRANSACTION;   -- se revierte: los datos quedan intactos
GO

-- M02 · UPDATE: Descontar una unidad de existencia a los medicamentos recetados en la consulta 1 (2 filas).
BEGIN TRANSACTION;
    UPDATE medicamento SET existencia = existencia - 1 WHERE id_medicamento IN (SELECT id_medicamento FROM receta WHERE folio = 1);
    SELECT (SELECT SUM(existencia) FROM medicamento WHERE id_medicamento IN (1,2)) AS resultado_despues;   -- esperado: 78
ROLLBACK TRANSACTION;   -- se revierte: los datos quedan intactos
GO

-- M03 · UPDATE: Actualizar el estado de una cita a un valor permitido.
BEGIN TRANSACTION;
    UPDATE cita SET estado = 'ATENDIDA' WHERE id_cita = 3;
    SELECT (SELECT estado FROM cita WHERE id_cita = 3) AS resultado_despues;   -- esperado: ATENDIDA
ROLLBACK TRANSACTION;   -- se revierte: los datos quedan intactos
GO

-- M04 · UPDATE: Violación de CHECK: existencia negativa.
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE medicamento SET existencia = -5 WHERE id_medicamento = 2;
    PRINT 'M04 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M04 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- M05 · UPDATE: Violación de CHECK: estado de cita fuera del dominio.
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE cita SET estado = 'BORRADA' WHERE id_cita = 1;
    PRINT 'M05 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M05 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- M06 · UPDATE: Violación de integridad referencial: asignar un propietario inexistente.
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE mascota SET id_propietario = 999 WHERE id_mascota = 1;
    PRINT 'M06 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M06 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- M07 · DELETE: Eliminar un propietario sin mascotas (permitido).
BEGIN TRANSACTION;
    DELETE FROM propietario WHERE id_propietario = 6;
    SELECT (SELECT COUNT(*) FROM propietario WHERE id_propietario = 6) AS resultado_despues;   -- esperado: 0
ROLLBACK TRANSACTION;   -- se revierte: los datos quedan intactos
GO

-- M08 · DELETE: Eliminar un propietario que tiene mascotas (ON DELETE NO ACTION lo impide).
BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM propietario WHERE id_propietario = 1;
    PRINT 'M08 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M08 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- M09 · DELETE: Eliminar un medicamento que ya fue recetado (lo impide la FK de receta).
BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM medicamento WHERE id_medicamento = 1;
    PRINT 'M09 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M09 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- M10 · DELETE: Eliminar la consulta 7 (sin factura): sus recetas se borran en cascada.
BEGIN TRANSACTION;
    DELETE FROM consulta WHERE folio = 7;
    SELECT (SELECT COUNT(*) FROM receta WHERE folio = 7) AS resultado_despues;   -- esperado: 0
ROLLBACK TRANSACTION;   -- se revierte: los datos quedan intactos
GO

-- M11 · DELETE: Eliminar un empleado con rol de auxiliar: el rol se borra en cascada.
BEGIN TRANSACTION;
    DELETE FROM empleado WHERE id_empleado = 4;
    SELECT (SELECT COUNT(*) FROM auxiliar WHERE id_empleado = 4) AS resultado_despues;   -- esperado: 0
ROLLBACK TRANSACTION;   -- se revierte: los datos quedan intactos
GO

-- M12 · DELETE: Eliminar una consulta que ya tiene factura (la FK de factura lo impide).
BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM consulta WHERE folio = 1;
    PRINT 'M12 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M12 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- M13 · TRUNCATE: TRUNCATE sobre una tabla referenciada por una FK (no está permitido).
BEGIN TRANSACTION;
BEGIN TRY
    TRUNCATE TABLE medicamento;
    PRINT 'M13 FALLO: la operación se aceptó y debía rechazarse';
END TRY
BEGIN CATCH
    PRINT 'M13 OK, BLOQUEADO -> ' + ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO
