#!/usr/bin/env bash
# Run all data2 service tests
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

for test in "$DIR"/test_neo4j.sh "$DIR"/test_postgres.sh "$DIR"/test_mariadb.sh "$DIR"/test_redis.sh "$DIR"/test_memcached.sh "$DIR"/test_dragonfly.sh "$DIR"/test_geospatial.sh "$DIR"/test_sqlite.sh; do
  echo ""
  echo "================================================================"
  echo "Running: $(basename "$test")"
  echo "================================================================"
  if bash "$test"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "================================================================"
echo "data2 results: $PASS passed, $FAIL failed"
echo "================================================================"
[ "$FAIL" -eq 0 ] || exit 1
