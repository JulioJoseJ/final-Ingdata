-- Sentencia 1: los seis registros de 2026-10-03 -> resultados/final/verificacion_tercer_dia.csv
SELECT
    fecha,
    id_envio,
    ciudad,
    transportadora,
    estado,
    duracion_minutos
FROM entregas_db.entregas
WHERE fecha = '2026-10-03'
ORDER BY id_envio;

-- Sentencia 2: total de registros de la tabla (18 tras cargar el día 3) -> resultados/final/total_registros.csv
SELECT COUNT(*) AS total_registros
FROM entregas_db.entregas;

-- Sentencia 3: registros por fecha (6 por día) -> resultados/final/registros_por_fecha.csv
SELECT
    fecha,
    COUNT(*) AS total_registros
FROM entregas_db.entregas
GROUP BY fecha
ORDER BY fecha;

-- Sentencia 4: conteos por estado del tercer día -> resultados/final/conteos_estado_tercer_dia.csv
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM entregas_db.entregas
WHERE fecha = '2026-10-03'
GROUP BY fecha, estado
ORDER BY estado;
