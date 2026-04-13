#!/usr/bin/env bash
# Test: Java container runtime (OpenJDK + Maven + Gradle)
set -e
echo "=== Java version ==="
podman exec dev2-java java --version | head -1

echo "=== Maven version ==="
podman exec dev2-java mvn --version | head -1

echo "=== Gradle version ==="
podman exec dev2-java gradle --version | grep "^Gradle"

echo "=== Java compile + run test ==="
podman exec dev2-java bash -c '
mkdir -p /tmp/java-test
cat > /tmp/java-test/Dev2Test.java << EOF
public class Dev2Test {
    public static void main(String[] args) {
        String neo4j = System.getenv("NEO4J_URI");
        String pg = System.getenv("POSTGRES_DSN");
        String redis = System.getenv("REDIS_URL");
        if (neo4j == null || neo4j.isEmpty()) { System.err.println("FAIL: NEO4J_URI not set"); System.exit(1); }
        if (pg == null || pg.isEmpty()) { System.err.println("FAIL: POSTGRES_DSN not set"); System.exit(1); }
        if (redis == null || redis.isEmpty()) { System.err.println("FAIL: REDIS_URL not set"); System.exit(1); }
        System.out.println("NEO4J_URI=" + neo4j);
        System.out.println("POSTGRES_DSN=" + pg);
        System.out.println("REDIS_URL=" + redis);
        System.out.println("PASS: Java env vars + compile");
    }
}
EOF
cd /tmp/java-test && javac Dev2Test.java && java Dev2Test
'
