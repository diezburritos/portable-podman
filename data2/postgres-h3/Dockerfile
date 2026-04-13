FROM docker.io/postgis/postgis:16-3.4

# h3-pg from the official PostGIS project (https://github.com/postgis/h3-pg)
# Available as a binary package in the PGDG apt repo (already configured in the base image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-16-h3 && \
    rm -rf /var/lib/apt/lists/*
