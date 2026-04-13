#!/usr/bin/env bash
# Test: R container runtime
set -e
echo "=== R version ==="
podman exec dev2-r R --version | head -1

echo "=== R runtime test ==="
podman exec dev2-r Rscript -e '
neo4j <- Sys.getenv("NEO4J_URI")
pg <- Sys.getenv("POSTGRES_DSN")
redis <- Sys.getenv("REDIS_URL")
stopifnot(nchar(neo4j) > 0)
stopifnot(nchar(pg) > 0)
stopifnot(nchar(redis) > 0)
cat("NEO4J_URI=", neo4j, "\n")
cat("POSTGRES_DSN=", pg, "\n")
cat("REDIS_URL=", redis, "\n")
cat("PASS: R env vars\n")
'
