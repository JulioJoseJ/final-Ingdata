#!/usr/bin/env bash
# Ejecuta UNA sentencia SQL en el workgroup de Athena, descarga el resultado y registra la ejecución.
# Uso: bash scripts/ejecutar_consulta.sh <etapa> <archivo_sql> <archivo_resultado> [n_sentencia]
#   etapa: inicial | final      n_sentencia: posición de la sentencia en el archivo (separadas por ;), por defecto 1
set -euo pipefail
cd "$(dirname "$0")/.."

ETAPA="$1"; ARCHIVO_SQL="$2"; ARCHIVO_RESULTADO="$3"; N="${4:-1}"
REGION=$(terraform -chdir=infraestructura output -raw region)
WORKGROUP=$(terraform -chdir=infraestructura output -raw workgroup_athena)
BASE=$(terraform -chdir=infraestructura output -raw base_datos_glue)

# Toma la sentencia N (separador ;) y quita las líneas de comentario
SQL=$(awk -v n="$N" 'BEGIN{RS=";"} NR==n{print}' "$ARCHIVO_SQL" | { grep -v '^[[:space:]]*--' || true; } | sed '/^[[:space:]]*$/d')
[ -n "$SQL" ] || { echo "No se encontró la sentencia $N en $ARCHIVO_SQL" >&2; exit 1; }
echo ">> $ARCHIVO_SQL (sentencia $N) en workgroup $WORKGROUP"

ID=$(aws athena start-query-execution --region "$REGION" --work-group "$WORKGROUP" \
      --query-execution-context Database="$BASE" --query-string "$SQL" \
      --query QueryExecutionId --output text)

while true; do
  ESTADO=$(aws athena get-query-execution --region "$REGION" --query-execution-id "$ID" \
            --query QueryExecution.Status.State --output text)
  case "$ESTADO" in
    SUCCEEDED) break ;;
    FAILED|CANCELLED)
      aws athena get-query-execution --region "$REGION" --query-execution-id "$ID" \
        --query QueryExecution.Status.StateChangeReason --output text >&2
      exit 1 ;;
  esac
  sleep 1
done

UBICACION=$(aws athena get-query-execution --region "$REGION" --query-execution-id "$ID" \
             --query QueryExecution.ResultConfiguration.OutputLocation --output text)
mkdir -p "$(dirname "$ARCHIVO_RESULTADO")"
# Athena entrega el CSV con comillas en cada campo; se quitan para compararlo con las referencias
aws s3 cp --region "$REGION" "$UBICACION" - | sed 's/"//g' > "$ARCHIVO_RESULTADO"

EVIDENCIA=evidencias/ejecuciones_athena.csv
[ -f "$EVIDENCIA" ] || echo "etapa,archivo_sql,id_ejecucion,archivo_resultado" > "$EVIDENCIA"
echo "$ETAPA,$ARCHIVO_SQL,$ID,$ARCHIVO_RESULTADO" >> "$EVIDENCIA"

echo "   id_ejecucion: $ID  ->  $ARCHIVO_RESULTADO"
cat "$ARCHIVO_RESULTADO"
