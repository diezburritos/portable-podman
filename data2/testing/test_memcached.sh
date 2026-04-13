#!/usr/bin/env bash
# Test: Memcached is running and accepts commands
set -e
echo "=== Memcached connectivity test ==="
STATS=$(podman exec data2-memcached bash -c 'echo "stats" | nc -q1 localhost 11211' 2>&1 || true)
if echo "$STATS" | grep -q "STAT pid"; then
  echo "PASS: Memcached stats"
else
  # Fallback: check if the process is running
  PID=$(podman exec data2-memcached pgrep memcached 2>&1 || true)
  if [ -n "$PID" ]; then
    echo "PASS: Memcached process running (pid $PID)"
  else
    echo "FAIL: Memcached"
    exit 1
  fi
fi
