# portable-podman

Portable, generic polyglot dev + data services stack using Podman containers. No project-specific dependencies — bring your own code.

## Structure

```
portable-podman/
├── data2/          # Data services (Neo4j, PostgreSQL, MariaDB, Redis, Memcached, Dragonfly, Geospatial)
├── dev2/           # Dev containers (Python, Node/TS, Rust, Go, R, C++, Lua, Java, Jupyter)
└── README.md
```

## Quick Start

```bash
# Start data services
cd data2 && make up

# Start dev containers (all or a la carte)
cd ../dev2 && make up          # all
cd ../dev2 && make up-python   # just Python

# Shell into a dev container
make python
make rust
make node
```

## Details

See `data2/README.md` and `dev2/README.md` for full service lists, credentials, a la carte commands, and base image reference.

## Data Services (data2)

| Service       | Container          | Port      | Connect                                           |
|---------------|--------------------|-----------|---------------------------------------------------|
| Neo4j         | data2-neo4j        | 7474/7687 | bolt://localhost:7687                              |
| PostgreSQL    | data2-postgres     | 5432      | postgresql://dev:devpassword@localhost:5432/devdb  |
| PostgreSQL+H3 | data2-postgres-h3 | 5432      | same DSN (swap with postgres, not simultaneous)    |
| MariaDB       | data2-mariadb      | 3306      | mysql://dev:devpassword@localhost:3306/devdb       |
| Redis         | data2-redis        | 6379      | redis://localhost:6379                             |
| Memcached     | data2-memcached    | 11211     | localhost:11211                                    |
| Dragonfly     | data2-dragonfly    | 6380      | redis://localhost:6380                             |
| Geospatial    | data2-geospatial   | —         | H3 + SpatiaLite + GeoPandas/Shapely               |

Credentials: `dev`/`devpassword` for PostgreSQL and MariaDB. `neo4j`/`devpassword` for Neo4j.

### Start/stop individual services

```bash
cd data2
make up-neo4j       make down-neo4j
make up-postgres    make down-postgres
make up-postgres-h3 make down-postgres-h3
make up-mariadb     make down-mariadb
make up-redis       make down-redis
make up-memcached   make down-memcached
make up-dragonfly   make down-dragonfly
make up-geo         make down-geo
```

### Interactive shells

```bash
make neo4j-shell    make psql          make psql-h3
make mysql          make redis-cli     make dragonfly-cli
make geo-shell      make sqlite-shell
```

### PostgreSQL variants

Two variants share port 5432 (run one at a time):

- `postgres` — stock PostGIS image, spatial functions out of the box
- `postgres-h3` — adds [h3-pg](https://github.com/postgis/h3-pg) from the PGDG apt repo for H3 hexagonal indexing

```bash
make down-postgres && make up-postgres-h3
```

### Geospatial container

Python container with H3, Shapely, GeoPandas, SQLite3, and SpatiaLite.

```bash
make geo-init       # verify libraries
make sqlite-init    # create SQLite + SpatiaLite databases
```

### Init scripts

PostgreSQL auto-runs `init-sql/01-extensions.sql` on first start (enables PostGIS, skips H3 gracefully if not installed). MariaDB auto-runs `init-mariadb/01-spatial.sql` (creates spatial table).

## Dev Containers (dev2)

| Container    | Image                                | Language                | Shell         |
|-------------|---------------------------------------|-------------------------|---------------|
| dev2-python | python:3.13-bookworm                  | Python 3.13             | `make python` |
| dev2-node   | node:22-bookworm                      | Node.js 22 + TypeScript | `make node`   |
| dev2-rust   | rust:1.82-bookworm                    | Rust stable             | `make rust`   |
| dev2-go     | golang:1.23-bookworm                  | Go 1.23                 | `make go`     |
| dev2-r      | rocker/r-ver:4                        | R 4.x                   | `make r`      |
| dev2-cpp    | gcc:13-bookworm                       | C++ (GCC 13)            | `make cpp`    |
| dev2-lua    | openresty/openresty:bookworm          | Lua/LuaJIT              | `make lua`    |
| dev2-java   | eclipse-temurin:21 + Maven + Gradle   | Java 21 (OpenJDK)       | `make java`   |
| dev2-jupyter| python:3.13-bookworm                  | Jupyter Notebooks       | :8888         |

### Start/stop individual containers

```bash
cd dev2
make up-python      make down-python
make up-node        make down-node
make up-rust        make down-rust
make up-go          make down-go
make up-r           make down-r
make up-cpp         make down-cpp
make up-lua         make down-lua
make up-java        make down-java
make up-jupyter     make down-jupyter
```

### Workspace

All containers mount `dev2/workspace/` at `/workspace` with per-language subdirectories. Edit on your host, changes are live inside the container.

### Data service connections

Every dev2 container has these env vars pre-set, pointing to data2 services on the host:

```
NEO4J_URI=bolt://host.containers.internal:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=devpassword
POSTGRES_DSN=postgresql://dev:devpassword@host.containers.internal:5432/devdb
MARIADB_DSN=mysql://dev:devpassword@host.containers.internal:3306/devdb
REDIS_URL=redis://host.containers.internal:6379
DRAGONFLY_URL=redis://host.containers.internal:6380
MEMCACHED_HOST=host.containers.internal:11211
SQLITE_DIR=/workspace/sqlite
```

### Language notes

- **Python**: Use `--break-system-packages` with pip (Makefile targets handle this). `make install-python` installs from `workspace/python/requirements.txt`.
- **Rust**: Cargo registry and target dir cached in named volumes. Corp CA cert mount pre-configured for TLS inspection environments.
- **Go**: Module cache in named volume.
- **Java**: Maven and Gradle caches in named volumes.
- **Node/TypeScript**: `npm i -g typescript` inside the container for tsc.

## Base Images for Production Builds

Pre-pulled minimal images for multi-stage Dockerfile builds:

| Image | Size | Shell | Use Case |
|-------|------|-------|----------|
| `scratch` | 0B | No | Static Go/Rust/C++ binaries |
| `busybox:latest` | ~4MB | Yes | Debugging scratch containers |
| `debian:bookworm-slim` | ~75MB | Yes | General-purpose with apt |
| `alpine:3.20` | ~7MB | Yes | Tiny musl-based Linux |
| `ubuntu/dotnet-deps:8.0-24.04_chiselled` | ~13MB | No | Ubuntu distroless |
| `fedora-minimal:41` | ~95MB | Yes | Fedora/Atomic with microdnf |
| `ubi9-micro:latest` | ~28MB | No | RHEL distroless (enterprise) |
| `distroless/static-debian12` | ~2MB | No | Google distroless (static) |
| `distroless/base-debian12` | ~20MB | No | Google distroless (glibc) |

Multi-stage pattern: build in the fat dev container, copy artifact into a minimal base.

```dockerfile
FROM docker.io/library/golang:1.23-bookworm AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app/service .

FROM scratch
COPY --from=builder /app/service /service
ENTRYPOINT ["/service"]
```

## Testing

```bash
cd data2 && make test    # smoke tests for all data services
cd ../dev2 && make test  # smoke tests for all dev containers
```

## Included Benchmarks

CRUD benchmark across all data2 services:

```bash
podman exec -it dev2-python python bench.py
```

Compiled Rust benchmark for SQLite + Memcached:

```bash
podman exec -it dev2-rust bash -c "cd /workspace/rust/bench-data && cargo run --release"
```

## TLS Inspection / Corporate Proxy

The Rust container mounts `/tmp/corp-ca.pem` as the CA cert for cargo. For other containers, mount your cert and set the appropriate env var (`SSL_CERT_FILE`, `NODE_EXTRA_CA_CERTS`, `REQUESTS_CA_BUNDLE`).

## Port Summary

| Port  | Service             |
|-------|---------------------|
| 3306  | MariaDB             |
| 5432  | PostgreSQL (or +H3) |
| 6379  | Redis               |
| 6380  | Dragonfly           |
| 7474  | Neo4j Browser       |
| 7687  | Neo4j Bolt          |
| 8888  | Jupyter Notebook    |
| 11211 | Memcached           |
