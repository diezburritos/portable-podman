#!/usr/bin/env bash
# Test: Neo4j is running and accepts Cypher queries
set -e
echo "=== Neo4j connectivity test ==="
RESULT=$(podman exec data2-neo4j cypher-shell -u neo4j -p devpassword "RETURN 'neo4j_ok' AS status" 2>&1)
echo "$RESULT"
echo "$RESULT" | grep -q "neo4j_ok" && echo "PASS: Neo4j" || { echo "FAIL: Neo4j"; exit 1; }
