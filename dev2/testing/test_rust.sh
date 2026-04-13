#!/usr/bin/env bash
# Test: Rust container runtime
set -e
echo "=== Rust version ==="
podman exec dev2-rust rustc --version

echo "=== Cargo version ==="
podman exec dev2-rust cargo --version

echo "=== Rust compile + run test ==="
podman exec dev2-rust bash -c '
mkdir -p /tmp/rust-test/src
cat > /tmp/rust-test/Cargo.toml << EOF
[package]
name = "dev2-test"
version = "0.1.0"
edition = "2021"
EOF
cat > /tmp/rust-test/src/main.rs << EOF
use std::env;
fn main() {
    let neo4j = env::var("NEO4J_URI").unwrap_or_default();
    let pg = env::var("POSTGRES_DSN").unwrap_or_default();
    assert!(!neo4j.is_empty(), "NEO4J_URI not set");
    assert!(!pg.is_empty(), "POSTGRES_DSN not set");
    println!("NEO4J_URI={}", neo4j);
    println!("POSTGRES_DSN={}", pg);
    println!("PASS: Rust env vars + compile");
}
EOF
cd /tmp/rust-test && cargo run -q 2>&1
'
