output "region" {
  description = "Región del despliegue"
  value       = var.region
}

output "bucket_s3" {
  description = "Bucket privado del ejercicio"
  value       = aws_s3_bucket.datos.bucket
}

output "ruta_entregas" {
  description = "Prefijo de los datos de entrada"
  value       = local.ubicacion_tabla
}

output "ruta_resultados_athena" {
  description = "Prefijo donde Athena escribe los resultados"
  value       = local.ubicacion_athena
}

output "base_datos_glue" {
  description = "Base de datos de Glue Data Catalog"
  value       = aws_glue_catalog_database.entregas.name
}

output "tabla_glue" {
  description = "Tabla externa con partition projection"
  value       = aws_glue_catalog_table.entregas.name
}

output "workgroup_athena" {
  description = "Workgroup de Athena para ejecutar las consultas"
  value       = aws_athena_workgroup.entregas.name
}
