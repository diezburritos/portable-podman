#!/usr/bin/env bash
# Run all dev2 container tests
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

for test in "$DIR"/test_python.sh \
            "$DIR"/test_node.sh \
            "$DIR"/test_rust.sh \
            "$DIR"/test_go.sh \
            "$DIR"/test_r.sh \
            "$DIR"/test_cpp.sh \
            "$DIR"/test_lua.sh \
            "$DIR"/test_java.sh \
            "$DIR"/test_jupyter.sh; do
  echo ""
  echo "================================================================"
  echo "Running: $(basename "$test")"
  echo "================================================================"
  if bash "$test"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "================================================================"
echo "dev2 results: $PASS passed, $FAIL failed"
echo "================================================================"
[ "$FAIL" -eq 0 ] || exit 1
