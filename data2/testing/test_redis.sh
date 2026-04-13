#!/usr/bin/env bash
# Test: Redis is running and accepts commands
set -e
echo "=== Redis connectivity test ==="
PING=$(podman exec data2-redis redis-cli ping 2>&1)
echo "$PING"
echo "$PING" | grep -q "PONG" && echo "PASS: Redis ping" || { echo "FAIL: Redis ping"; exit 1; }

echo "=== Redis read/write test ==="
podman exec data2-redis redis-cli SET data2_test "redis_ok" > /dev/null
RESULT=$(podman exec data2-redis redis-cli GET data2_test 2>&1)
echo "$RESULT"
echo "$RESULT" | grep -q "redis_ok" && echo "PASS: Redis read/write" || { echo "FAIL: Redis read/write"; exit 1; }
podman exec data2-redis redis-cli DEL data2_test > /dev/null
