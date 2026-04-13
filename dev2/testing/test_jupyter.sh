#!/usr/bin/env bash
# Test: Jupyter notebook server is running and reachable
set -e
echo "=== Jupyter server test ==="

# Check the container is running
STATUS=$(podman inspect --format '{{.State.Status}}' dev2-jupyter 2>&1)
echo "Container status: $STATUS"
[ "$STATUS" = "running" ] || { echo "FAIL: Jupyter container not running"; exit 1; }

# Jupyter needs time to pip install + boot — poll up to 60s
echo "Waiting for Jupyter to start (up to 60s)..."
for i in $(seq 1 12); do
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8888/ 2>&1 || echo "000")
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "302" ]; then
    echo "HTTP status: $HTTP"
    echo "PASS: Jupyter reachable on :8888"
    exit 0
  fi
  sleep 5
done

echo "HTTP status: $HTTP"
echo "FAIL: Jupyter not reachable after 60s (pip install may still be running — check: make jupyter)"
exit 1
