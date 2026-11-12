terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "actual" {}

locals {
  # Nombre único: prefijo + id de la cuenta (los nombres de bucket son globales)
  nombre_bucket    = "${var.prefijo_bucket}-${data.aws_caller_identity.actual.account_id}"
  prefijo_datos    = "entregas/"
  prefijo_athena   = "resultados-athena/"
  ubicacion_tabla  = "s3://${local.nombre_bucket}/${local.prefijo_datos}"
  ubicacion_athena = "s3://${local.nombre_bucket}/${local.prefijo_athena}"
}

# 1. Bucket S3 privado con bloqueo de acceso público
resource "aws_s3_bucket" "datos" {
  bucket        = local.nombre_bucket
  force_destroy = true # permite que terraform destroy vacíe el bucket (datos y resultados de Athena)

  tags = {
    Proyecto = "DE-Final-Entregas"
  }
}

resource "aws_s3_bucket_public_access_block" "datos" {
  bucket                  = aws_s3_bucket.datos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "datos" {
  bucket = aws_s3_bucket.datos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. Los prefijos entregas/ y resultados-athena/ son parte de las claves de los objetos:
#    no se crean directorios. La tabla lee de entregas/ y el workgroup escribe en resultados-athena/.

# 3. Base de datos de Glue Data Catalog
resource "aws_glue_catalog_database" "entregas" {
  name        = var.nombre_base_datos
  description = "Intentos de entrega de paquetes (examen final Ingeniería de Datos)"
}

# 4. Tabla externa CSV con partition projection por fecha
resource "aws_glue_catalog_table" "entregas" {
  name          = var.nombre_tabla
  database_name = aws_glue_catalog_database.entregas.name
  table_type    = "EXTERNAL_TABLE"
  description   = "Un registro por intento de entrega; fecha proviene de la carpeta fecha=yyyy-MM-dd"

  parameters = {
    "EXTERNAL"               = "TRUE"
    "classification"         = "csv"
    "skip.header.line.count" = "1"

    # Partition projection: Athena calcula las particiones al consultar, sin registrarlas
    "projection.enabled"             = "true"
    "projection.fecha.type"          = "date"
    "projection.fecha.format"        = "yyyy-MM-dd"
    "projection.fecha.range"         = var.rango_fechas
    "projection.fecha.interval"      = "1"
    "projection.fecha.interval.unit" = "DAYS"
    # $${fecha} escapa la interpolación de Terraform: en Glue queda literal ${fecha}
    "storage.location.template" = "${local.ubicacion_tabla}fecha=$${fecha}/"
  }

  partition_keys {
    name    = "fecha"
    type    = "string"
    comment = "Fecha del archivo, tomada de la carpeta fecha=yyyy-MM-dd"
  }

  storage_descriptor {
    location      = local.ubicacion_tabla
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "csv"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim"          = ","
        "serialization.format" = ","
      }
    }

    columns {
      name = "id_envio"
      type = "string"
    }
    columns {
      name = "ciudad"
      type = "string"
    }
    columns {
      name = "transportadora"
      type = "string"
    }
    columns {
      name = "estado"
      type = "string"
    }
    columns {
      name = "duracion_minutos"
      type = "int"
    }
  }
}

# 5. Workgroup de Athena con resultados en resultados-athena/
resource "aws_athena_workgroup" "entregas" {
  name          = var.nombre_workgroup
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = local.ubicacion_athena

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}
