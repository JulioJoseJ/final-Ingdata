# Punto 2 — Ventas diarias con control de actualidad (dbt + Airflow)

Repositorio base del enunciado: https://github.com/smm-0216/DE-Final-Ventas. Aquí están solo los tres archivos
modificados (en sus mismas rutas) y la evidencia de la demostración.

| Archivo | Cambio |
| --- | --- |
| `dbt/models/ventas_diarias.sql` | Resumen con una fila por `fecha_venta`: `count(*)`, `sum(cantidad)`, `sum(cantidad * precio_unitario)` desde `ref('stg_ventas')` |
| `dbt/models/sources.yml` | `loaded_at_field: _loaded_at` y `freshness` con `warn_after` 12 h y `error_after` 24 h (sintaxis dbt 1.9, fuera de `config`) |
| `airflow/dags/examen_ventas.py` | Tarea `comprobar_freshness` (`run_dbt(["source", "freshness"])`) antes de `construir_resumen`, con la regla `all_success` por defecto |

## Evidencia

| Escenario | Run ID | Freshness | Build |
| --- | --- | --- | --- |
| actualizada (≈2 h) | `manual__2026-11-12T11:31:31.556804+00:00` | success (PASS) | success (PASS=19) |
| desactualizada (≈30 h) | `manual__2026-11-12T11:47:57.399927+00:00` | failed (ERROR STALE, 108069 s) | upstream_failed, sin intento |

- `Entrega_Punto2_Ventas.pdf` / `.docx`: documento de entrega con código, capturas, logs, resumen antes/después y respuestas.
- `evidencias/logs/`: estados y runs de Airflow, logs de las tareas, log de dbt con `ERROR STALE` y `sources.json` (artefactos).
- `evidencias/resumen_antes.txt` y `evidencias/resumen_despues.txt`: idénticos; el bloqueo conservó el resumen.
- `respuestas_ventas.md`: preguntas conceptuales.
