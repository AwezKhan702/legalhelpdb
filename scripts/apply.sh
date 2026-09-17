#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SQL_ROOT="$ROOT/db"
CONTAINER="legalhelpdb"

if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT/.env"
  set +a
fi

POSTGRES_USER="${POSTGRES_USER:-legalhelp}"
POSTGRES_DB="${POSTGRES_DB:-legalhelpdb}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

mapfile -t files < <(
  find "$SQL_ROOT" -type f -name '*.sql' \
    ! -path '*/09_seeds/demo/*' \
    ! -path '*/10_rollback/*' \
    | sort
)

apply_file() {
  local file="$1"
  echo "Applying $file"
  if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
    local relative="${file#"$SQL_ROOT"/}"
    docker exec -i "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "/sql/${relative}"
  else
    PGPASSWORD="${POSTGRES_PASSWORD:-}" psql -v ON_ERROR_STOP=1 -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$file"
  fi
}

for file in "${files[@]}"; do
  apply_file "$file"
done

echo "Schema apply complete."
