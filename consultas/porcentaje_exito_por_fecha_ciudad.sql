-- Porcentaje de entregas exitosas por fecha y ciudad: 100 x exitosas / total de intentos del grupo
-- CAST a DOUBLE evita la división entera; el resultado se redondea y se presenta con dos decimales
SELECT
    fecha,
    ciudad,
    CAST(
        ROUND(100 * CAST(SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) AS DOUBLE) / COUNT(*), 2)
        AS DECIMAL(5, 2)
    ) AS porcentaje_exito
FROM entregas_db.entregas
WHERE fecha BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY fecha, ciudad
ORDER BY fecha ASC, ciudad ASC
