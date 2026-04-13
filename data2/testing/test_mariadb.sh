#!/usr/bin/env bash
# Test: MariaDB is running and accepts queries
set -e
echo "=== MariaDB connectivity test ==="
RESULT=$(podman exec data2-mariadb mariadb -u dev -pdevpassword devdb -e "SELECT 'mariadb_ok' AS status;" 2>&1)
echo "$RESULT"
echo "$RESULT" | grep -q "mariadb_ok" && echo "PASS: MariaDB connection" || { echo "FAIL: MariaDB connection"; exit 1; }

echo "=== MariaDB spatial test ==="
SPATIAL=$(podman exec data2-mariadb mariadb -u dev -pdevpassword devdb -e "SELECT ST_AsText(ST_GeomFromText('POINT(40.7128 -74.0060)', 4326)) AS pt;" 2>&1)
echo "$SPATIAL"
echo "$SPATIAL" | grep -q "POINT" && echo "PASS: MariaDB spatial" || { echo "FAIL: MariaDB spatial"; exit 1; }

echo "=== MariaDB sample_locations table test ==="
TABLE=$(podman exec data2-mariadb mariadb -u dev -pdevpassword devdb -e "DESCRIBE sample_locations;" 2>&1)
echo "$TABLE"
echo "$TABLE" | grep -q "entity_id" && echo "PASS: MariaDB sample_locations table" || { echo "FAIL: MariaDB sample_locations table"; exit 1; }
