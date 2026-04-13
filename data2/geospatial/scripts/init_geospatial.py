#!/usr/bin/env python3
"""
Initialize geospatial environment.
Verifies H3, Shapely, and GeoPandas are working.
"""
import h3
from shapely.geometry import Point

def init():
    # Verify H3
    cell = h3.latlng_to_cell(40.7128, -74.0060, 9)
    print(f"H3 test (NYC res9): {cell}")

    neighbors = h3.grid_disk(cell, 1)
    print(f"H3 grid_disk (k=1): {len(neighbors)} cells")

    # Verify Shapely
    pt = Point(40.7128, -74.0060)
    print(f"Shapely test: {pt.wkt}")

    # Verify GeoPandas
    import geopandas as gpd
    print(f"GeoPandas version: {gpd.__version__}")

    print("PASS: Geospatial environment ready")
    print("Libraries: h3, shapely, geopandas")

if __name__ == "__main__":
    init()
