variable "region" {
  description = "Región de AWS donde se despliegan los recursos"
  type        = string
  default     = "us-east-1"
}

variable "prefijo_bucket" {
  description = "Prefijo del bucket; se le agrega el id de la cuenta para que el nombre sea único"
  type        = string
  default     = "de-final-entregas"
}

variable "nombre_base_datos" {
  description = "Nombre de la base de datos de Glue Data Catalog"
  type        = string
  default     = "entregas_db"
}

variable "nombre_tabla" {
  description = "Nombre de la tabla externa de entregas"
  type        = string
  default     = "entregas"
}

variable "nombre_workgroup" {
  description = "Nombre del workgroup de Athena"
  type        = string
  default     = "wg_entregas_final"
}

variable "rango_fechas" {
  description = "Rango proyectado de la partición fecha (inicio,fin), ambos incluidos, formato yyyy-MM-dd"
  type        = string
  default     = "2026-10-01,2026-10-03"
}
