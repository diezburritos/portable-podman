#!/usr/bin/env bash
# Test: Node.js container runtime + TypeScript + data2 connectivity
set -e
echo "=== Node.js version ==="
podman exec dev2-node node --version

echo "=== npm version ==="
podman exec dev2-node npm --version

echo "=== TypeScript test ==="
# Install tsc globally once rather than npx downloading each time
podman exec dev2-node bash -c "
if ! command -v tsc &>/dev/null; then
  npm install -g typescript 2>/dev/null
fi
tsc --version
"

echo "=== Node.js runtime test ==="
podman exec dev2-node node -e "
const assert = require('assert');
console.log('Node.js ' + process.version);
assert(process.env.NEO4J_URI, 'NEO4J_URI not set');
assert(process.env.POSTGRES_DSN, 'POSTGRES_DSN not set');
assert(process.env.REDIS_URL, 'REDIS_URL not set');
console.log('PASS: Node.js env vars');
"

echo "=== Node.js → Redis test ==="
podman exec dev2-node bash -c "
cd /tmp
npm init -y --silent 2>/dev/null
npm install --silent redis 2>/dev/null
node -e \"
const { createClient } = require('redis');
(async () => {
  const client = createClient({ url: process.env.REDIS_URL });
  await client.connect();
  await client.set('dev2_node_test', 'ok');
  const val = await client.get('dev2_node_test');
  if (val !== 'ok') throw new Error('Expected ok, got ' + val);
  await client.del('dev2_node_test');
  await client.quit();
  console.log('PASS: Node.js → Redis');
})().catch(e => { console.error('FAIL:', e.message); process.exit(1); });
\"
"
