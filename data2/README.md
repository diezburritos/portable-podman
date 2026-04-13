# data2 — Data Services Stack (Podman)

Local data services for development: graph DB, relational/spatial DBs, geospatial analytics, and caching layers. Start everything at once or bring up individual services a la carte.

## Prerequisites

- [Podman](https://podman.io/docs/installation)
- [podman-compose](https://github.com/containers/podman-compose) (`pip install podman-compose`)

## Quick Start

```bash
cd data2
make up          # Start all services
make status      # Check container health
make geo-init    # Verify geospatial libraries
make sqlite-init # Initialize SQLite + SpatiaLite databases
```

## A La Carte

Start only the services you need:

```bash
make up-neo4j       # just Neo4j
make up-postgres    # just PostgreSQL
make up-mariadb     # just MariaDB
make up-redis       # just Redis
make up-memcached   # just Memcached
make up-dragonfly   # just Dragonfly
make up-geo         # just geospatial (H3/SpatiaLite)
```

Stop individual services:

```bash
make down-neo4j
make down-postgres
make down-mariadb
make down-redis
make down-memcached
make down-dragonfly
make down-geo
```

## Services

| Service      | Container          | Port  | URL / Connect String                                      |
|--------------|--------------------|-------|------------------------------------------------------------|
| Neo4j UI     | data2-neo4j        | 7474  | http://localhost:7474                                      |
| Neo4j Bolt   | data2-neo4j        | 7687  | bolt://localhost:7687                                      |
| PostgreSQL   | data2-postgres     | 5432  | postgresql://dev:devpassword@localhost:5432/devdb           |
| PostgreSQL+H3| data2-postgres-h3 | 5432  | Same DSN (swap with postgres, not simultaneous)            |
| MariaDB      | data2-mariadb      | 3306  | mysql://dev:devpassword@localhost:3306/devdb                |
| Redis        | data2-redis        | 6379  | redis://localhost:6379                                     |
| Memcached    | data2-memcached    | 11211 | localhost:11211                                            |
| Dragonfly    | data2-dragonfly    | 6380  | redis://localhost:6380                                     |
| Geospatial   | data2-geospatial   | —     | H3 + SpatiaLite + GeoPandas/Shapely                        |

## Credentials

| Service    | User  | Password    |
|------------|-------|-------------|
| Neo4j      | neo4j | devpassword |
| PostgreSQL | dev   | devpassword |
| MariaDB    | dev   | devpassword |
| MariaDB    | root  | devpassword |

## Geospatial Stack

The `data2-geospatial` container provides H3 hexagonal indexing, SQLite3 with SpatiaLite, and Python geospatial libraries.

**Capabilities:**
- Uber H3 hexagonal indexing (resolutions 0–15) via Python `h3` library
- GeoPandas + Shapely for geometry manipulation
- SQLite3 + SpatiaLite for embedded relational/spatial storage

**Initialize:**
```bash
make geo-init       # Verify H3/Shapely/GeoPandas
make sqlite-init    # SQLite + SpatiaLite databases
```

## MariaDB

MariaDB 11 with built-in spatial support. The `sample_locations` table with a spatial index is created on first start via `init-mariadb/01-spatial.sql`.

## PostgreSQL

Two PostgreSQL variants are available:

**`postgres`** (default) — stock PostGIS image. PostGIS spatial functions work out of the box. H3 is not included.

**`postgres-h3`** (with H3 extension) — installs [h3-pg](https://github.com/postgis/h3-pg) from the PGDG apt repo. First build is fast (binary package, no compilation). Use this when you need H3 hexagonal indexing in PostgreSQL.

```bash
# Default (no H3):
make up-postgres

# With H3 (builds on first run, stop default postgres first):
make down-postgres
make up-postgres-h3
make psql-h3
```

Both use the same credentials, database name, and init SQL. They share port 5432 so only one can run at a time.

PostGIS is automatically enabled on first start via `init-sql/01-extensions.sql`. H3 extensions are loaded if available (graceful skip if not).

## Commands

| Command              | Description                          |
|----------------------|--------------------------------------|
| `make up`            | Start all containers                 |
| `make down`          | Stop all containers                  |
| `make clean`         | Stop all + delete volumes            |
| `make logs`          | Tail all container logs              |
| `make status`        | Show container status                |
| `make test`          | Run all service tests                |
| `make up-neo4j`      | Start Neo4j only                     |
| `make up-postgres`   | Start PostgreSQL only                |
| `make up-postgres-h3`| Start PostgreSQL with H3 (build+run) |
| `make up-mariadb`    | Start MariaDB only                   |
| `make up-redis`      | Start Redis only                     |
| `make up-memcached`  | Start Memcached only                 |
| `make up-dragonfly`  | Start Dragonfly only                 |
| `make up-geo`        | Start geospatial only                |
| `make down-neo4j`    | Stop Neo4j only                      |
| `make down-postgres` | Stop PostgreSQL only                 |
| `make down-postgres-h3` | Stop PostgreSQL+H3 only          |
| `make down-mariadb`  | Stop MariaDB only                    |
| `make down-redis`    | Stop Redis only                      |
| `make down-memcached`| Stop Memcached only                  |
| `make down-dragonfly`| Stop Dragonfly only                  |
| `make down-geo`      | Stop geospatial only                 |
| `make neo4j-shell`   | Open cypher-shell                    |
| `make psql`          | Open psql to devdb                   |
| `make psql-h3`       | Open psql to devdb (H3 variant)      |
| `make mysql`         | Open mariadb CLI to devdb            |
| `make redis-cli`     | Open redis-cli to Redis              |
| `make dragonfly-cli` | Open redis-cli to Dragonfly          |
| `make geo-shell`     | Bash into geospatial container       |
| `make geo-init`      | Verify geospatial libraries          |
| `make sqlite-init`   | Initialize SQLite + SpatiaLite DBs   |
| `make sqlite-shell`  | Open sqlite3 CLI to dev.db           |

## Port Mapping Notes

- Redis on 6379, Dragonfly on 6380 (host side) to avoid conflicts
- MariaDB on 3306 (default MySQL port)
- PostgreSQL variants share port 5432 — only run one at a time
- If `dev-environment/` Neo4j is also running, stop it first or remap ports
