.PHONY: up down logs clean status test \
       up-neo4j up-postgres up-postgres-h3 up-mariadb up-redis up-memcached up-dragonfly up-geo \
       down-neo4j down-postgres down-postgres-h3 down-mariadb down-redis down-memcached down-dragonfly down-geo \
       neo4j-shell psql psql-h3 mysql redis-cli dragonfly-cli geo-shell geo-init sqlite-init sqlite-shell \
       build-postgres-h3

COMPOSE = podman-compose -f podman-compose.yml

# --- lifecycle (all) ---------------------------------------------------------

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

logs:
	$(COMPOSE) logs -f

status:
	$(COMPOSE) ps

# --- a la carte: start -------------------------------------------------------

up-neo4j:
	$(COMPOSE) up -d neo4j

up-postgres:
	$(COMPOSE) up -d postgres

up-postgres-h3: build-postgres-h3
	@echo "NOTE: Stop 'postgres' first if running (same port 5432)"
	$(COMPOSE) --profile h3 up -d postgres-h3

build-postgres-h3:
	$(COMPOSE) --profile h3 build postgres-h3

up-mariadb:
	$(COMPOSE) up -d mariadb

up-redis:
	$(COMPOSE) up -d redis

up-memcached:
	$(COMPOSE) up -d memcached

up-dragonfly:
	$(COMPOSE) up -d dragonfly

up-geo:
	$(COMPOSE) up -d geospatial

# --- a la carte: stop --------------------------------------------------------

down-neo4j:
	podman stop data2-neo4j && podman rm data2-neo4j

down-postgres:
	podman stop data2-postgres && podman rm data2-postgres

down-postgres-h3:
	podman stop data2-postgres-h3 && podman rm data2-postgres-h3

down-mariadb:
	podman stop data2-mariadb && podman rm data2-mariadb

down-redis:
	podman stop data2-redis && podman rm data2-redis

down-memcached:
	podman stop data2-memcached && podman rm data2-memcached

down-dragonfly:
	podman stop data2-dragonfly && podman rm data2-dragonfly

down-geo:
	podman stop data2-geospatial && podman rm data2-geospatial

# --- shells ------------------------------------------------------------------

neo4j-shell:
	podman exec -it data2-neo4j cypher-shell -u neo4j -p devpassword

psql:
	podman exec -it data2-postgres psql -U dev -d devdb

psql-h3:
	podman exec -it data2-postgres-h3 psql -U dev -d devdb

mysql:
	podman exec -it data2-mariadb mariadb -u dev -pdevpassword devdb

redis-cli:
	podman exec -it data2-redis redis-cli

dragonfly-cli:
	podman exec -it data2-dragonfly redis-cli

geo-shell:
	podman exec -it data2-geospatial bash

geo-init:
	podman exec -it data2-geospatial python /scripts/init_geospatial.py

sqlite-init:
	podman exec -it data2-geospatial python /scripts/init_sqlite.py

sqlite-shell:
	podman exec -it data2-geospatial sqlite3 /sqlite/dev.db

# --- testing -----------------------------------------------------------------

test:
	bash testing/test_all.sh
