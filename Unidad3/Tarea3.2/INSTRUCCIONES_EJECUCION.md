# Guía de ejecución en SQL Server con SSMS (para tomar las evidencias)

Requisitos: SQL Server (2019 o superior) y SQL Server Management Studio (SSMS).

## 1. Conectarte (captura E1, parte 1)
Abre SSMS. En *Server name* escribe `localhost` (o `localhost\SQLEXPRESS` si instalaste Express), autenticación de Windows, y si pide certificado marca *Trust server certificate*. Pulsa *Connect*.

## 2. Ejecutar el DDL (capturas E1 y E2)
*File → Open → File…* y abre `scripts/01_ddl_veterinaria.sql`. Pulsa **Execute (F5)** con el script completo.
- El script crea la base de datos `veterinaria`, las 22 tablas, índices, vistas y descripciones.
- En la pestaña *Messages* debe verse «Commands completed successfully» sin errores rojos.
- Al final aparece un resultado con `@@VERSION` (versión del servidor): esa es la captura E1.

## 3. Verificar las tablas (captura E3)
En *Object Explorer* pulsa *Refresh* sobre *Databases* y expande `veterinaria → Tables`: deben verse 22 tablas. También sirve la consulta 4.1 del script 04.

## 4. Diagrama de base de datos (captura E4)
Expande `veterinaria`, clic derecho en *Database Diagrams* → *New Database Diagram*.
- Si pregunta si deseas crear los objetos de soporte para diagramas, responde **Yes**.
- Si marca error de «no valid owner», abre una consulta nueva y ejecuta: `ALTER AUTHORIZATION ON DATABASE::veterinaria TO sa;` y repite.
- Selecciona todas las tablas (Shift+clic), pulsa *Add* y luego *Close*. Acomoda las tablas y captura el diagrama.
- Si tu versión de SSMS no muestra *Database Diagrams*, avísame y usamos otra herramienta.

## 5. Datos de prueba (captura E5)
Abre y ejecuta `scripts/02_datos_prueba.sql`. Luego consulta, por ejemplo, `SELECT COUNT(*) FROM mascota;` o el resultado 4.8 del script 04.

## 6. Restricciones (captura E6)
Abre `scripts/04_diccionario_datos.sql`. Selecciona cada consulta 4.3 a 4.7 y ejecútala (F5). Captura los resultados.

## 7. Pruebas de integridad (captura E7)
Abre y ejecuta `scripts/03_pruebas_integridad.sql` **una sola vez** después del 02. En la pestaña *Messages* deben aparecer T01 a T21 con «OK».
Para repetirlo: vuelve a ejecutar 01 y 02.

Guarda las capturas en la carpeta `evidencias/` y pásalas para incluirlas en el reporte PDF.
