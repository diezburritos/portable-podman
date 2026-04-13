.PHONY: up down logs clean status test \
       up-python up-node up-rust up-go up-r up-cpp up-lua up-java up-jupyter \
       down-python down-node down-rust down-go down-r down-cpp down-lua down-java down-jupyter \
       python node rust go r cpp lua java jupyter \
       install-python install-node test-python

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

up-python:
	$(COMPOSE) up -d python

up-node:
	$(COMPOSE) up -d node

up-rust:
	$(COMPOSE) up -d rust

up-go:
	$(COMPOSE) up -d golang

up-r:
	$(COMPOSE) up -d rlang

up-cpp:
	$(COMPOSE) up -d cpp

up-lua:
	$(COMPOSE) up -d lua

up-java:
	$(COMPOSE) up -d java

up-jupyter:
	$(COMPOSE) up -d jupyter

# --- a la carte: stop --------------------------------------------------------

down-python:
	podman stop dev2-python && podman rm dev2-python

down-node:
	podman stop dev2-node && podman rm dev2-node

down-rust:
	podman stop dev2-rust && podman rm dev2-rust

down-go:
	podman stop dev2-go && podman rm dev2-go

down-r:
	podman stop dev2-r && podman rm dev2-r

down-cpp:
	podman stop dev2-cpp && podman rm dev2-cpp

down-lua:
	podman stop dev2-lua && podman rm dev2-lua

down-java:
	podman stop dev2-java && podman rm dev2-java

down-jupyter:
	podman stop dev2-jupyter && podman rm dev2-jupyter

# --- shells ------------------------------------------------------------------

python:
	podman exec -it dev2-python bash

node:
	podman exec -it dev2-node bash

rust:
	podman exec -it dev2-rust bash

go:
	podman exec -it dev2-go bash

r:
	podman exec -it dev2-r R

cpp:
	podman exec -it dev2-cpp bash

lua:
	podman exec -it dev2-lua bash

java:
	podman exec -it dev2-java bash

jupyter:
	podman logs -f dev2-jupyter

# --- convenience -------------------------------------------------------------

install-python:
	podman exec -it dev2-python pip install --break-system-packages -r /workspace/python/requirements.txt

install-node:
	podman exec -it dev2-node bash -c "cd workspace/node && npm install"

test-python:
	podman exec -it dev2-python python -m pytest workspace/python/tests/ -v

test:
	bash testing/test_all.sh
