#!/usr/bin/env bash
# Test: PostgreSQL is running, PostGIS available, H3 optional
set -e
echo "=== PostgreSQL connectivity test ==="
RESULT=$(podman exec data2-postgres psql -U dev -d devdb -t -c "SELECT 'pg_ok';" 2>&1)
echo "$RESULT"
echo "$RESULT" | grep -q "pg_ok" && echo "PASS: PostgreSQL connection" || { echo "FAIL: PostgreSQL connection"; exit 1; }

echo "=== PostGIS extension test ==="
POSTGIS=$(podman exec data2-postgres psql -U dev -d devdb -t -c "SELECT PostGIS_Version();" 2>&1)
echo "$POSTGIS"
echo "$POSTGIS" | grep -qE "[0-9]+\.[0-9]+" && echo "PASS: PostGIS" || { echo "FAIL: PostGIS"; exit 1; }

echo "=== H3 extension test (optional) ==="
H3=$(podman exec data2-postgres psql -U dev -d devdb -t -c "SELECT extname FROM pg_extension WHERE extname='h3';" 2>&1)
if echo "$H3" | grep -q "h3"; then
  echo "PASS: H3 extension loaded"
else
  echo "WARN: H3 extension not installed (optional — see data2/README.md Custom Image section)"
fi
