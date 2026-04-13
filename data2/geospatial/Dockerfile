FROM docker.io/library/python:3.13-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 libsqlite3-dev libspatialite-dev libsqlite3-mod-spatialite && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --break-system-packages h3 geopandas shapely

WORKDIR /data
CMD ["sleep", "infinity"]
