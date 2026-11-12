# Respuestas — Ventas diarias con control de actualidad

## 1. ¿Por qué usar `_loaded_at` y no `fecha_venta`?

`fecha_venta` dice cuándo ocurrió la venta en el negocio; `_loaded_at` dice cuándo llegó el dato a raw. El riesgo que queremos detectar es que la **carga** se haya detenido o retrasado, así que hay que medir la última llegada (`max(_loaded_at)`). Con `fecha_venta` el control fallaría con datos sanos (una venta antigua cargada hoy, un día sin ventas) y pasaría con datos viejos si la última venta registrada fuera reciente aunque la carga lleve días detenida. En este ejercicio los datos de negocio son siempre los mismos (enero de 2026): por `fecha_venta` todos los escenarios se verían igual de "viejos"; solo `_loaded_at` distingue el escenario actualizado (2 h), el de advertencia (18 h) y el desactualizado (30 h).

## 2. ¿Por qué las pruebas de integridad no garantizan actualidad?

Las pruebas `unique`, `not_null`, `valores_ventas` y las del resumen validan la forma y la coherencia de las filas que existen: que no haya duplicados, nulos ni valores inválidos. No miran el reloj ni comparan con el momento actual. Una tabla cargada hace 30 horas sigue teniendo ids únicos y campos completos, así que `dbt build` termina en verde y reconstruye un resumen desactualizado. Por eso la actualidad se comprueba aparte con `dbt source freshness` y, como `dbt build` no la ejecuta, va como tarea previa en Airflow: con error (más de 24 h) la construcción queda `upstream_failed` y se conserva el resumen anterior.
