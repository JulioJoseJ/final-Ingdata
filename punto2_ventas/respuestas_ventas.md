# Respuestas — Ventas diarias con control de actualidad

## 1. ¿Por qué usar `_loaded_at` y no `fecha_venta` para este control?

Fecha_venta dice cuando ocurrio la venta mientras que loaded_at dice cuando llego ese dato. Para el control se quiere determinar si se detiene la carga o se retrasa por lo que se mide la ultima llegada de los datos. Con fecha_venta el control podría fallar aunque la carga esté al día (por ejemplo, si llega hoy una venta antigua) o pasar aunque la carga esté detenida, si la última venta registrada es reciente . Por lo que se usa loaded_at.

Evidencia de esto son las ventas en enero 2026 son las mismas pero freshness distingue por 2h y falla con 30h

## 2. ¿Por qué las pruebas de integridad no garantizan actualidad?

Porque los datos viejos pueden pasar las pruebas de integridad pese a ser viejos, actualidad se debe comparar por fecha de carga o freshness antes de asegurar integridad algo que puede ser saltado en un flujo. Por defecto dbt no ejecuta freshness a no ser especificado en un parametro. Evidencia de esto es el escenario desactualizado que habian datos validos pero freshnes detecto ~30h haciendo up_stream failed para conservar el resumen
