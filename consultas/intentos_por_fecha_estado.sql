-- Cantidad de intentos por fecha y estado (todos los estados y todo el rango proyectado)
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM entregas_db.entregas
WHERE fecha BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY fecha, estado
ORDER BY fecha ASC, estado ASC
