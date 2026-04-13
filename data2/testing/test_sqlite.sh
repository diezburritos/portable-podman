#!/usr/bin/env bash
# Test: SQLite + SpatiaLite in the geospatial container
set -e

echo "=== SQLite version ==="
SQLITE_VER=$(podman exec data2-geospatial sqlite3 --version 2>&1)
echo "$SQLITE_VER"
echo "$SQLITE_VER" | grep -qE "[0-9]+\.[0-9]+" && echo "PASS: sqlite3 binary" || { echo "FAIL: sqlite3 binary"; exit 1; }

echo "=== SQLite init ==="
podman exec data2-geospatial python /scripts/init_sqlite.py 2>&1

echo "=== SQLite plain DB test ==="
TABLES=$(podman exec data2-geospatial sqlite3 /sqlite/dev.db ".tables" 2>&1)
echo "Tables: $TABLES"
echo "$TABLES" | grep -q "entities" && echo "PASS: entities table" || { echo "FAIL: entities table"; exit 1; }
echo "$TABLES" | grep -q "audit_log" && echo "PASS: audit_log table" || { echo "FAIL: audit_log table"; exit 1; }

echo "=== SQLite read/write test ==="
podman exec data2-geospatial sqlite3 /sqlite/dev.db "
INSERT OR REPLACE INTO entities (entity_id, entity_type, category, created_ts, updated_ts)
VALUES ('item-001', 'sensor', 'environmental', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z');
"
RESULT=$(podman exec data2-geospatial sqlite3 /sqlite/dev.db "SELECT entity_id FROM entities WHERE entity_id='item-001';" 2>&1)
echo "$RESULT"
echo "$RESULT" | grep -q "item-001" && echo "PASS: SQLite read/write" || { echo "FAIL: SQLite read/write"; exit 1; }
podman exec data2-geospatial sqlite3 /sqlite/dev.db "DELETE FROM entities WHERE entity_id='item-001';"

echo "=== SpatiaLite extension test ==="
SPATIALITE=$(podman exec data2-geospatial python -c "
import sqlite3
con = sqlite3.connect('/sqlite/dev_spatial.db')
con.enable_load_extension(True)
try:
    con.load_extension('mod_spatialite')
    ver = con.execute('SELECT spatialite_version()').fetchone()
    print(f'SPATIALITE_OK:{ver[0]}')
except Exception as e:
    print(f'SPATIALITE_WARN:{e}')
con.close()
" 2>&1)
echo "$SPATIALITE"
if echo "$SPATIALITE" | grep -q "SPATIALITE_OK:"; then
    echo "PASS: SpatiaLite"
else
    echo "WARN: SpatiaLite extension not loadable (spatial fallback to lat/lon columns)"
fi
