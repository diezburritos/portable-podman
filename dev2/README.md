# dev2 — Polyglot Dev Environment (Podman)

Container-per-language development environment. Each runtime gets its own container with a shared workspace mount and pre-wired connections to `data2/` services. Start everything at once or bring up individual containers a la carte.

## Prerequisites

- [Podman](https://podman.io/docs/installation)
- [podman-compose](https://github.com/containers/podman-compose) (`pip install podman-compose`)
- `data2/` services running (`cd ../data2 && make up` or start individual services)

## Quick Start

```bash
cd ../data2 && make up     # Start data services
cd ../dev2 && make up      # Start all dev containers
make python                # Shell into Python
```

## A La Carte

Start only the runtimes you need:

```bash
make up-python      # just Python
make up-node        # just Node.js / TypeScript
make up-rust        # just Rust
make up-go          # just Go
make up-r           # just R
make up-cpp         # just C++
make up-lua         # just Lua
make up-java        # just Java
make up-jupyter     # just Jupyter
```

Stop individual containers:

```bash
make down-python
make down-node
make down-rust
make down-go
make down-r
make down-cpp
make down-lua
make down-java
make down-jupyter
```

## Containers

| Container    | Image                          | Language               | Shell Command |
|-------------|--------------------------------|------------------------|---------------|
| dev2-python | python:3.13-bookworm           | Python 3.13            | `make python` |
| dev2-node   | node:22-bookworm               | Node.js 22 + TypeScript| `make node`   |
| dev2-rust   | rust:1.82-bookworm             | Rust (stable)          | `make rust`   |
| dev2-go     | golang:1.23-bookworm           | Go 1.23                | `make go`     |
| dev2-r      | rocker/r-ver:4                 | R 4.x                  | `make r`      |
| dev2-cpp    | gcc:13-bookworm                | C++ (GCC 13)           | `make cpp`    |
| dev2-lua    | openresty/openresty:bookworm   | Lua/LuaJIT             | `make lua`    |
| dev2-java   | eclipse-temurin:21 + Maven + Gradle | Java 21 (OpenJDK) | `make java`   |
| dev2-jupyter| python:3.13-bookworm           | Jupyter Notebooks      | http://localhost:8888 |

## Workspace Layout

All containers mount `dev2/workspace/` at `/workspace`. Each language has its own subdirectory:

```
dev2/
├── podman-compose.yml
├── Makefile
├── README.md
├── notebooks/              # Jupyter notebooks
└── workspace/
    ├── python/             # Python projects
    ├── node/               # Node.js / TypeScript projects
    ├── rust/               # Rust projects (Cargo)
    ├── go/                 # Go modules
    ├── r/                  # R scripts and projects
    ├── cpp/                # C++ projects (CMake)
    ├── lua/                # Lua scripts
    ├── java/               # Java projects (Maven/Gradle)
    └── sqlite/             # Shared SQLite databases
```

Edit files on your host in `dev2/workspace/`; they're live-mounted into every container.

## Data Service Connections

Every container has these environment variables pre-set, pointing to `data2/` services:

| Variable        | Value                                                                 |
|-----------------|-----------------------------------------------------------------------|
| `NEO4J_URI`     | `bolt://host.containers.internal:7687`                                |
| `NEO4J_USER`    | `neo4j`                                                               |
| `NEO4J_PASSWORD`| `devpassword`                                                         |
| `POSTGRES_DSN`  | `postgresql://dev:devpassword@host.containers.internal:5432/devdb`    |
| `MARIADB_DSN`   | `mysql://dev:devpassword@host.containers.internal:3306/devdb`        |
| `REDIS_URL`     | `redis://host.containers.internal:6379`                               |
| `DRAGONFLY_URL` | `redis://host.containers.internal:6380`                               |
| `MEMCACHED_HOST`| `host.containers.internal:11211`                                      |
| `SQLITE_DIR`    | `/workspace/sqlite`                                                   |

## Commands

| Command              | Description                              |
|----------------------|------------------------------------------|
| `make up`            | Start all dev containers                 |
| `make down`          | Stop all containers                      |
| `make clean`         | Stop all + delete volumes                |
| `make logs`          | Tail all container logs                  |
| `make status`        | Show container status                    |
| `make test`          | Run all container tests                  |
| `make up-python`     | Start Python only                        |
| `make up-node`       | Start Node.js only                       |
| `make up-rust`       | Start Rust only                          |
| `make up-go`         | Start Go only                            |
| `make up-r`          | Start R only                             |
| `make up-cpp`        | Start C++ only                           |
| `make up-lua`        | Start Lua only                           |
| `make up-java`       | Start Java only                          |
| `make up-jupyter`    | Start Jupyter only                       |
| `make down-python`   | Stop Python only                         |
| `make down-node`     | Stop Node.js only                        |
| `make down-rust`     | Stop Rust only                           |
| `make down-go`       | Stop Go only                             |
| `make down-r`        | Stop R only                              |
| `make down-cpp`      | Stop C++ only                            |
| `make down-lua`      | Stop Lua only                            |
| `make down-java`     | Stop Java only                           |
| `make down-jupyter`  | Stop Jupyter only                        |
| `make python`        | Bash into Python container               |
| `make node`          | Bash into Node.js container              |
| `make rust`          | Bash into Rust container                 |
| `make go`            | Bash into Go container                   |
| `make r`             | R console in R container                 |
| `make cpp`           | Bash into C++ container                  |
| `make lua`           | Bash into Lua container                  |
| `make java`          | Bash into Java container                 |
| `make jupyter`       | Tail Jupyter logs                        |
| `make install-python`| pip install from requirements.txt        |
| `make install-node`  | npm install from workspace/node/         |
| `make test-python`   | Run Python tests                         |

## Language-Specific Notes

**Node.js / TypeScript**: TypeScript available via `npx tsc` or `npm i -g typescript`.

**Rust**: Cargo registry and target dir cached in named volumes so rebuilds are fast.

**Go**: Module cache in named volume. `GOPATH=/go`.

**R**: Base R from rocker. Install packages with `install.packages()`.

**C++**: GCC 13. Install CMake with `apt-get install cmake` if needed.

**Lua**: OpenResty provides LuaJIT and `luarocks`.

**Java**: Eclipse Temurin OpenJDK 21 with Maven and Gradle. `~/.m2` and `~/.gradle` cached in named volumes.

## Ports

| Port | Service |
|------|---------|
| 8888 | Jupyter Notebook |

All other containers are shell-only. Add port mappings to `podman-compose.yml` as needed.


## Base Images for Production Builds

These minimal base images are pre-pulled and available for building production containers from your dev2 workspace projects. Use them in your `Dockerfile` `FROM` lines when packaging applications for deployment.

### Available Base Images

| Image | Size | Shell | Pkg Mgr | Best For |
|-------|------|-------|---------|----------|
| `scratch` | 0 bytes | No | No | Static Go/Rust/C++ binaries with zero dependencies |
| `docker.io/library/busybox:latest` | ~4MB | Yes | No | Minimal shell for debugging scratch-like containers |
| `docker.io/library/debian:bookworm-slim` | ~75MB | Yes | apt | General-purpose minimal Linux when you need apt |
| `docker.io/library/alpine:3.20` | ~7MB | Yes | apk | Tiny musl-based Linux, good for Go and static builds |
| `docker.io/ubuntu/dotnet-deps:8.0-24.04_chiselled` | ~13MB | No | No | Ubuntu chiselled (distroless-style), no shell |
| `registry.fedoraproject.org/fedora-minimal:41` | ~95MB | Yes | microdnf | Fedora/Atomic lineage, rpm-based minimal |
| `registry.access.redhat.com/ubi9-micro:latest` | ~28MB | No | No | RHEL distroless, certified for enterprise |
| `gcr.io/distroless/static-debian12:latest` | ~2MB | No | No | Google distroless for fully static binaries |
| `gcr.io/distroless/base-debian12:latest` | ~20MB | No | No | Google distroless with glibc for dynamic linking |

### How to Choose

**Static binary (Go, Rust with musl, C++ static)?**
Use `scratch` or `distroless/static-debian12`. Smallest possible image, no attack surface.

```dockerfile
FROM scratch
COPY --from=builder /app/myservice /myservice
ENTRYPOINT ["/myservice"]
```

**Dynamic binary needing glibc (Rust default, C++, Java native)?**
Use `distroless/base-debian12` or `debian:bookworm-slim`.

```dockerfile
FROM gcr.io/distroless/base-debian12:latest
COPY --from=builder /app/myservice /myservice
ENTRYPOINT ["/myservice"]
```

**Python app?**
Use `debian:bookworm-slim` or `alpine:3.20` as the runtime stage.

```dockerfile
FROM docker.io/library/python:3.13-bookworm AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --break-system-packages --target=/deps -r requirements.txt

FROM docker.io/library/debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends python3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /deps /usr/local/lib/python3.13/dist-packages
COPY . /app
CMD ["python3", "/app/main.py"]
```

**Node.js app?**
Use `alpine:3.20` with Node installed, or multi-stage from `node:22-bookworm`.

```dockerfile
FROM docker.io/library/node:22-bookworm AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production

FROM docker.io/library/alpine:3.20
RUN apk add --no-cache nodejs
COPY --from=builder /app /app
CMD ["node", "/app/index.js"]
```

**Java app?**
Use Eclipse Temurin JRE on `debian:bookworm-slim` or `ubi9-micro` for enterprise.

```dockerfile
FROM dev2-java AS builder
WORKDIR /app
COPY . .
RUN mvn package -DskipTests

FROM docker.io/library/debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-21-jre-headless && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/*.jar /app/app.jar
CMD ["java", "-jar", "/app/app.jar"]
```

**Need a shell for debugging?**
Use `busybox`, `alpine`, `debian:bookworm-slim`, or `fedora-minimal`. The distroless and chiselled images have no shell — you can't exec into them.

**Enterprise / compliance requirement?**
Use `ubi9-micro` (Red Hat certified) or `ubuntu/dotnet-deps:chiselled` (Canonical supported).

### Multi-Stage Build Pattern

The general pattern is: build in the dev2 language container, copy the artifact into a minimal base.

```dockerfile
# Stage 1: Build in the full dev image
FROM docker.io/library/golang:1.23-bookworm AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app/service .

# Stage 2: Run in minimal base
FROM scratch
COPY --from=builder /app/service /service
ENTRYPOINT ["/service"]
```

This keeps your dev containers fat (all the tools) and your production images tiny (just the binary).
