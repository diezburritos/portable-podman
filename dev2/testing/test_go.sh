#!/usr/bin/env bash
# Test: Go container runtime + data2 connectivity
set -e
echo "=== Go version ==="
podman exec dev2-go go version

echo "=== Go compile + run test ==="
podman exec dev2-go bash -c '
mkdir -p /tmp/go-test
cat > /tmp/go-test/main.go << EOF
package main

import (
    "fmt"
    "os"
)

func main() {
    neo4j := os.Getenv("NEO4J_URI")
    pg := os.Getenv("POSTGRES_DSN")
    redis := os.Getenv("REDIS_URL")
    if neo4j == "" { fmt.Println("FAIL: NEO4J_URI not set"); os.Exit(1) }
    if pg == "" { fmt.Println("FAIL: POSTGRES_DSN not set"); os.Exit(1) }
    if redis == "" { fmt.Println("FAIL: REDIS_URL not set"); os.Exit(1) }
    fmt.Println("NEO4J_URI=" + neo4j)
    fmt.Println("POSTGRES_DSN=" + pg)
    fmt.Println("REDIS_URL=" + redis)
    fmt.Println("PASS: Go env vars + compile")
}
EOF
cd /tmp/go-test && go run main.go
'
