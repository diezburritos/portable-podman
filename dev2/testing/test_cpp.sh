#!/usr/bin/env bash
# Test: C++ container runtime (GCC compile + run)
set -e
echo "=== GCC version ==="
podman exec dev2-cpp gcc --version | head -1

echo "=== C++ compile + run test ==="
podman exec dev2-cpp bash -c '
cat > /tmp/test.cpp << EOF
#include <iostream>
#include <cstdlib>
#include <string>

int main() {
    std::string neo4j = std::getenv("NEO4J_URI") ? std::getenv("NEO4J_URI") : "";
    std::string pg = std::getenv("POSTGRES_DSN") ? std::getenv("POSTGRES_DSN") : "";
    if (neo4j.empty()) { std::cerr << "FAIL: NEO4J_URI not set" << std::endl; return 1; }
    if (pg.empty()) { std::cerr << "FAIL: POSTGRES_DSN not set" << std::endl; return 1; }
    std::cout << "NEO4J_URI=" << neo4j << std::endl;
    std::cout << "POSTGRES_DSN=" << pg << std::endl;
    std::cout << "PASS: C++ env vars + compile" << std::endl;
    return 0;
}
EOF
g++ -o /tmp/test /tmp/test.cpp && /tmp/test
'
