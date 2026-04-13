FROM docker.io/eclipse-temurin:21-jdk-jammy

# Maven + Gradle
RUN apt-get update && \
    apt-get install -y --no-install-recommends maven gradle && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/java
CMD ["sleep", "infinity"]
