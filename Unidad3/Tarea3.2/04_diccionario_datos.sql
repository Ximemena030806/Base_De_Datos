-- Script 04: consultas que extraen el diccionario de datos desde el catálogo de SQL Server.
-- Ejecutar cada consulta (seleccionarla y F5) y tomar captura del resultado.
USE veterinaria;
GO

-- 4.1 Tablas creadas (deben ser 22) y número de columnas
SELECT t.name AS tabla, COUNT(c.column_id) AS columnas
FROM sys.tables t JOIN sys.columns c ON c.object_id = t.object_id
GROUP BY t.name ORDER BY t.name;

-- 4.2 Columnas: tipo, longitud, nulabilidad, identidad, valor por omisión y descripción
SELECT t.name AS tabla, c.column_id AS pos, c.name AS columna, ty.name AS tipo,
       c.max_length AS longitud, c.precision AS precision_, c.scale AS escala,
       CASE c.is_nullable WHEN 1 THEN 'SI' ELSE 'NO' END AS admite_null,
       c.is_identity AS identidad, dc.definition AS valor_default,
       CAST(ep.value AS NVARCHAR(400)) AS descripcion
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
LEFT JOIN sys.extended_properties ep ON ep.class = 1 AND ep.major_id = c.object_id
     AND ep.minor_id = c.column_id AND ep.name = 'MS_Description'
ORDER BY t.name, c.column_id;

-- 4.3 Llaves primarias y restricciones UNIQUE (el UNIQUE de propietario.correo es un índice único filtrado: ver 4.6)
SELECT OBJECT_NAME(parent_object_id) AS tabla, name AS restriccion, type_desc AS tipo
FROM sys.key_constraints ORDER BY 1, 3, 2;

-- 4.4 Restricciones CHECK
SELECT OBJECT_NAME(parent_object_id) AS tabla, name AS restriccion, definition
FROM sys.check_constraints ORDER BY 1, 2;

-- 4.5 Llaves foráneas con sus reglas de actualización y eliminación
SELECT fk.name AS fk, OBJECT_NAME(fk.parent_object_id) AS tabla_hija,
       OBJECT_NAME(fk.referenced_object_id) AS tabla_padre,
       fk.update_referential_action_desc AS on_update,
       fk.delete_referential_action_desc AS on_delete
FROM sys.foreign_keys fk ORDER BY 2, 1;

-- 4.6 Índices
SELECT t.name AS tabla, i.name AS indice, i.type_desc AS tipo, i.is_unique, i.is_primary_key
FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.name IS NOT NULL ORDER BY t.name, i.name;

-- 4.7 Resumen de restricciones por tipo
SELECT 'PRIMARY KEY' AS tipo, COUNT(*) AS total FROM sys.key_constraints WHERE type = 'PK'
UNION ALL SELECT 'UNIQUE (restricciones e indices unicos)', COUNT(*) FROM sys.indexes WHERE is_unique = 1 AND is_primary_key = 0 AND object_id IN (SELECT object_id FROM sys.tables)
UNION ALL SELECT 'FOREIGN KEY', COUNT(*) FROM sys.foreign_keys
UNION ALL SELECT 'CHECK', COUNT(*) FROM sys.check_constraints;

-- 4.8 Registros por tabla (después del script 02)
SELECT t.name AS tabla, SUM(p.rows) AS filas
FROM sys.tables t JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name ORDER BY t.name;
