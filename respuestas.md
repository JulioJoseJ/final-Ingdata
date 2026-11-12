# Respuestas

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?

Porque la tabla no depende de particiones registradas en el catálogo sino de **partition projection**. En las propiedades
de la tabla (definidas en `infraestructura/principal.tf`) Glue guarda una regla: `fecha` es de tipo `date`, con formato
`yyyy-MM-dd`, intervalo de un día y rango `2026-10-01,2026-10-03`, y la ubicación de cada valor sale de la plantilla
`s3://<bucket>/entregas/fecha=${fecha}/`. Al consultar, Athena calcula con esa regla las tres fechas posibles y sus prefijos
y lee lo que haya en S3. El 2026-10-03 ya estaba dentro del rango desde el despliegue inicial; antes de subir su archivo
el prefijo estaba vacío y por eso la etapa inicial mostró 12 registros. En cuanto el objeto
`entregas/fecha=2026-10-03/entregas.csv` existió, la siguiente consulta encontró sus 6 filas (18 en total, ver
`resultados/final/total_registros.csv` y `resultados/final/verificacion_tercer_dia.csv`) sin crawler, sin `MSCK REPAIR TABLE`,
sin `ALTER TABLE ADD PARTITION` y sin cambios en Terraform.

## 2. Si se sube un archivo del 4 de octubre con la configuración actual, ¿qué pasaría y qué habría que cambiar?

El archivo quedaría guardado en S3, pero **Athena no lo leería**: el 2026-10-04 está fuera de `projection.fecha.range`,
así que no forma parte de las particiones proyectadas. Las consultas seguirían devolviendo los 18 registros de los tres
primeros días, y un filtro `WHERE fecha = '2026-10-04'` devolvería cero filas, sin error. Con projection activa, Athena
tampoco usa particiones registradas manualmente, así que agregarla con `ALTER TABLE ADD PARTITION` no sirve.

Para incluirlo hay que ampliar el rango en la definición de la tabla y aplicar Terraform: cambiar `rango_fechas` a
`2026-10-01,2026-10-04` (o a un fin relativo como `2026-10-01,NOW`, para que cualquier fecha hasta hoy quede proyectada
sin volver a tocar la tabla) y ejecutar `terraform apply`. No hace falta crear particiones: solo cambia la regla.
