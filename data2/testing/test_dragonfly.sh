#!/usr/bin/env bash
# Test: Dragonfly is running and accepts Redis-compatible commands
set -e
echo "=== Dragonfly connectivity test ==="
PING=$(podman exec data2-dragonfly redis-cli ping 2>&1)
echo "$PING"
echo "$PING" | grep -q "PONG" && echo "PASS: Dragonfly ping" || { echo "FAIL: Dragonfly ping"; exit 1; }

echo "=== Dragonfly read/write test ==="
podman exec data2-dragonfly redis-cli SET data2_test "dragonfly_ok" > /dev/null
RESULT=$(podman exec data2-dragonfly redis-cli GET data2_test 2>&1)
echo "$RESULT"
echo "$RESULT" | grep -q "dragonfly_ok" && echo "PASS: Dragonfly read/write" || { echo "FAIL: Dragonfly read/write"; exit 1; }
podman exec data2-dragonfly redis-cli DEL data2_test > /dev/null
