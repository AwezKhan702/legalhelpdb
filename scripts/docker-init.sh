#!/bin/bash
(
  set -euo pipefail

  echo "Initializing legalhelpdb schema..."

  while IFS= read -r file; do
    echo "  applying ${file}"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$file"
  done < <(
    find /sql -type f -name '*.sql' \
      ! -path '*/09_seeds/demo/*' \
      ! -path '*/10_rollback/*' \
      | sort
  )

  echo "legalhelpdb schema applied."
)
