#!/usr/bin/env bash
# Test: Lua/LuaJIT container runtime
set -e
echo "=== LuaJIT version ==="
podman exec dev2-lua luajit -v 2>&1 || podman exec dev2-lua lua -v 2>&1

echo "=== Lua runtime test ==="
podman exec dev2-lua luajit -e '
local neo4j = os.getenv("NEO4J_URI") or ""
local pg = os.getenv("POSTGRES_DSN") or ""
local redis = os.getenv("REDIS_URL") or ""
assert(#neo4j > 0, "NEO4J_URI not set")
assert(#pg > 0, "POSTGRES_DSN not set")
assert(#redis > 0, "REDIS_URL not set")
print("NEO4J_URI=" .. neo4j)
print("POSTGRES_DSN=" .. pg)
print("REDIS_URL=" .. redis)
print("PASS: Lua env vars")
'
