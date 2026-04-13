#!/usr/bin/env python3
"""
Initialize SQLite + SpatiaLite databases in /sqlite/.
Creates a plain SQLite DB and a SpatiaLite-enabled spatial DB.
"""
import sqlite3
import os

SQLITE_DIR = "/sqlite"
PLAIN_DB = os.path.join(SQLITE_DIR, "dev.db")
SPATIAL_DB = os.path.join(SQLITE_DIR, "dev_spatial.db")


def init_plain():
    """Plain SQLite database for general-purpose storage."""
    con = sqlite3.connect(PLAIN_DB)
    con.execute("""
        CREATE TABLE IF NOT EXISTS entities (
            entity_id TEXT PRIMARY KEY,
            entity_type TEXT NOT NULL,
            category TEXT,
            properties TEXT,
            created_ts TEXT NOT NULL,
            updated_ts TEXT NOT NULL
        )
    """)
    con.execute("""
        CREATE TABLE IF NOT EXISTS audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity_id TEXT NOT NULL,
            event_type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            source TEXT,
            actor TEXT,
            changes TEXT
        )
    """)
    con.execute("CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_log(entity_id)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_audit_ts ON audit_log(timestamp)")
    con.commit()
    print(f"Plain SQLite DB initialized at {PLAIN_DB}")
    print("Tables: entities, audit_log")

    tables = con.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
    print(f"Tables found: {[t[0] for t in tables]}")
    con.close()


def init_spatial():
    """SpatiaLite-enabled database for geospatial queries."""
    con = sqlite3.connect(SPATIAL_DB)
    con.enable_load_extension(True)
    try:
        con.load_extension("mod_spatialite")
        con.execute("SELECT InitSpatialMetaData(1)")
        con.execute("""
            CREATE TABLE IF NOT EXISTS locations (
                entity_id TEXT PRIMARY KEY,
                entity_type TEXT NOT NULL,
                category TEXT,
                h3_res9 TEXT,
                h3_res7 TEXT
            )
        """)
        con.execute("""
            SELECT AddGeometryColumn('locations', 'geom', 4326, 'POINT', 'XY')
        """)
        con.execute("""
            SELECT CreateSpatialIndex('locations', 'geom')
        """)
        con.commit()
        print(f"SpatiaLite DB initialized at {SPATIAL_DB}")
        print("Tables: locations (with spatial index)")

        ver = con.execute("SELECT spatialite_version()").fetchone()
        print(f"SpatiaLite version: {ver[0]}")
    except Exception as e:
        print(f"SpatiaLite init: {e}")
        print("Falling back to plain SQLite with lat/lon columns")
        con.execute("""
            CREATE TABLE IF NOT EXISTS locations (
                entity_id TEXT PRIMARY KEY,
                entity_type TEXT NOT NULL,
                category TEXT,
                latitude REAL,
                longitude REAL,
                h3_res9 TEXT,
                h3_res7 TEXT
            )
        """)
        con.commit()
        print(f"Fallback SQLite spatial DB at {SPATIAL_DB}")
    finally:
        con.close()


if __name__ == "__main__":
    os.makedirs(SQLITE_DIR, exist_ok=True)
    init_plain()
    print()
    init_spatial()
