#!/usr/bin/env bash
# Compara un resultado obtenido con su referencia. Uso: bash scripts/comparar.sh <obtenido> <esperado>
set -uo pipefail
cd "$(dirname "$0")/.."
if diff <(tr -d '\r' < "$1") <(tr -d '\r' < "$2"); then
  echo "OK  $1 == $2"
else
  echo "DIFERENTE  $1 vs $2" ; exit 1
fi
