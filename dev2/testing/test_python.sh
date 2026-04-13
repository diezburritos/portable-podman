#!/usr/bin/env bash
# Test: Python container runtime + data2 connectivity
set -e
echo "=== Python version ==="
podman exec dev2-python python --version

echo "=== Python runtime test ==="
podman exec dev2-python python -c "
import sys, os
print(f'Python {sys.version}')
print(f'PYTHONPATH={os.environ.get(\"PYTHONPATH\", \"(not set)\")}')
print(f'NEO4J_URI={os.environ.get(\"NEO4J_URI\", \"(not set)\")}')
print(f'POSTGRES_DSN={os.environ.get(\"POSTGRES_DSN\", \"(not set)\")}')
print(f'REDIS_URL={os.environ.get(\"REDIS_URL\", \"(not set)\")}')
assert os.environ.get('NEO4J_URI'), 'NEO4J_URI not set'
assert os.environ.get('POSTGRES_DSN'), 'POSTGRES_DSN not set'
assert os.environ.get('REDIS_URL'), 'REDIS_URL not set'
print('PASS: Python env vars')
"

echo "=== Python pip install test ==="
podman exec dev2-python pip install --break-system-packages -q redis 2>&1 | tail -1
podman exec dev2-python python -c "
import redis, os
r = redis.from_url(os.environ['REDIS_URL'])
r.set('dev2_python_test', 'ok')
val = r.get('dev2_python_test')
assert val == b'ok', f'Expected b\"ok\", got {val}'
r.delete('dev2_python_test')
print('PASS: Python → Redis')
"
