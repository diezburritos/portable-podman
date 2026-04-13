#!/usr/bin/env bash
# Test: Geospatial container with H3, Shapely, GeoPandas
set -e
echo "=== Geospatial container status ==="
STATUS=$(podman inspect --format '{{.State.Status}}' data2-geospatial 2>&1)
echo "Container status: $STATUS"
[ "$STATUS" = "running" ] || { echo "FAIL: Geospatial container not running"; exit 1; }

echo "=== H3 Python library test ==="
H3_PY=$(podman exec data2-geospatial python -c "
import h3
cell = h3.latlng_to_cell(40.7128, -74.0060, 9)
print(f'H3_OK:{cell}')
" 2>&1)
echo "$H3_PY"
echo "$H3_PY" | grep -q "H3_OK:" && echo "PASS: h3" || { echo "FAIL: h3"; exit 1; }

echo "=== Shapely test ==="
SHAPELY=$(podman exec data2-geospatial python -c "
from shapely.geometry import Point
pt = Point(40.7128, -74.0060)
print(f'SHAPELY_OK:{pt.wkt}')
" 2>&1)
echo "$SHAPELY"
echo "$SHAPELY" | grep -q "SHAPELY_OK:" && echo "PASS: Shapely" || { echo "FAIL: Shapely"; exit 1; }

echo "=== GeoPandas test ==="
GPD=$(podman exec data2-geospatial python -c "
import geopandas as gpd
print(f'GPD_OK:{gpd.__version__}')
" 2>&1)
echo "$GPD"
echo "$GPD" | grep -q "GPD_OK:" && echo "PASS: GeoPandas" || { echo "FAIL: GeoPandas"; exit 1; }

echo "=== Init script test ==="
podman exec data2-geospatial python /scripts/init_geospatial.py 2>&1
echo "PASS: Geospatial init"
