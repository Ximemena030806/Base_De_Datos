# Formas normales: resumen

| Forma normal | Condición | Elimina | Descomposición típica |
|---|---|---|---|
| **1FN** | Atributos atómicos, sin grupos repetitivos, con llave primaria | Listas y grupos repetitivos | Nueva tabla por cada grupo |
| **2FN** | 1FN + todo atributo no primo depende de **toda** la llave | Dependencias parciales | Separar por cada parte de la llave |
| **3FN** | 2FN + sin dependencias transitivas | Dependencias transitivas | Separar la entidad determinada |
| **FNBC** | Todo determinante es superclave | Determinantes que no son llave | Separar determinante y dependiente |
| **4FN** | FNBC + sin dependencias multivaluadas no triviales | MVD independientes | Una relación por cada hecho multivaluado |
| **5FN** | 4FN + sin dependencias de reunión no implicadas por las llaves | Dependencias de reunión | Proyecciones reunibles sin pérdida |
