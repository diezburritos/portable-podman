#!/usr/bin/env python3
"""
CRUD benchmark across all data2 services.
Run inside dev2-python: python bench.py
"""
import os, time, json, sqlite3

N = 1000  # operations per test

def ms(t): return f"{t*1000:.1f}ms"
def ops(t): return f"{N/t:.0f} ops/s"
def report(name, create, read, update, delete):
    print(f"  {'create':>8}: {ms(create):>10}  ({ops(create)})")
    print(f"  {'read':>8}: {ms(read):>10}  ({ops(read)})")
    print(f"  {'update':>8}: {ms(update):>10}  ({ops(update)})")
    print(f"  {'delete':>8}: {ms(delete):>10}  ({ops(delete)})")

# --- Redis -------------------------------------------------------------------
def bench_redis():
    import redis
    r = redis.from_url(os.environ["REDIS_URL"])
    r.ping()
    keys = [f"bench:{i}" for i in range(N)]

    t = time.perf_counter(); [r.set(k, "v") for k in keys]; c = time.perf_counter() - t
    t = time.perf_counter(); [r.get(k) for k in keys]; rd = time.perf_counter() - t
    t = time.perf_counter(); [r.set(k, "v2") for k in keys]; u = time.perf_counter() - t
    t = time.perf_counter(); [r.delete(k) for k in keys]; d = time.perf_counter() - t
    report("Redis", c, rd, u, d)

# --- Dragonfly ---------------------------------------------------------------
def bench_dragonfly():
    import redis
    r = redis.from_url(os.environ["DRAGONFLY_URL"])
    r.ping()
    keys = [f"bench:{i}" for i in range(N)]

    t = time.perf_counter(); [r.set(k, "v") for k in keys]; c = time.perf_counter() - t
    t = time.perf_counter(); [r.get(k) for k in keys]; rd = time.perf_counter() - t
    t = time.perf_counter(); [r.set(k, "v2") for k in keys]; u = time.perf_counter() - t
    t = time.perf_counter(); [r.delete(k) for k in keys]; d = time.perf_counter() - t
    report("Dragonfly", c, rd, u, d)

# --- Memcached ---------------------------------------------------------------
def bench_memcached():
    from pymemcache.client.base import Client
    host, port = os.environ["MEMCACHED_HOST"].split(":")
    mc = Client((host, int(port)))
    keys = [f"bench:{i}" for i in range(N)]

    t = time.perf_counter(); [mc.set(k, b"v") for k in keys]; c = time.perf_counter() - t
    t = time.perf_counter(); [mc.get(k) for k in keys]; rd = time.perf_counter() - t
    t = time.perf_counter(); [mc.set(k, b"v2") for k in keys]; u = time.perf_counter() - t
    t = time.perf_counter(); [mc.delete(k) for k in keys]; d = time.perf_counter() - t
    report("Memcached", c, rd, u, d)

# --- PostgreSQL --------------------------------------------------------------
def bench_postgres():
    import psycopg2
    dsn = os.environ["POSTGRES_DSN"]
    conn = psycopg2.connect(dsn)
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS bench (id INT PRIMARY KEY, val TEXT)")
    cur.execute("TRUNCATE bench")

    t = time.perf_counter()
    for i in range(N): cur.execute("INSERT INTO bench VALUES (%s,%s)", (i, "v"))
    c = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("SELECT val FROM bench WHERE id=%s", (i,)); cur.fetchone()
    rd = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("UPDATE bench SET val=%s WHERE id=%s", ("v2", i))
    u = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("DELETE FROM bench WHERE id=%s", (i,))
    d = time.perf_counter() - t

    cur.execute("DROP TABLE bench")
    conn.close()
    report("PostgreSQL", c, rd, u, d)

# --- MariaDB -----------------------------------------------------------------
def bench_mariadb():
    import pymysql
    dsn = os.environ["MARIADB_DSN"]  # mysql://dev:devpassword@host:3306/devdb
    parts = dsn.replace("mysql://", "").split("@")
    user, pw = parts[0].split(":")
    host_db = parts[1].split("/")
    host, port = host_db[0].split(":")
    db = host_db[1]
    conn = pymysql.connect(host=host, port=int(port), user=user, password=pw, database=db, autocommit=True)
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS bench (id INT PRIMARY KEY, val TEXT)")
    cur.execute("TRUNCATE TABLE bench")

    t = time.perf_counter()
    for i in range(N): cur.execute("INSERT INTO bench VALUES (%s,%s)", (i, "v"))
    c = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("SELECT val FROM bench WHERE id=%s", (i,)); cur.fetchone()
    rd = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("UPDATE bench SET val=%s WHERE id=%s", ("v2", i))
    u = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("DELETE FROM bench WHERE id=%s", (i,))
    d = time.perf_counter() - t

    cur.execute("DROP TABLE bench")
    conn.close()
    report("MariaDB", c, rd, u, d)

# --- Neo4j -------------------------------------------------------------------
def bench_neo4j():
    from neo4j import GraphDatabase
    uri = os.environ["NEO4J_URI"]
    drv = GraphDatabase.driver(uri, auth=(os.environ["NEO4J_USER"], os.environ["NEO4J_PASSWORD"]))
    with drv.session() as s:
        s.run("MATCH (n:Bench) DELETE n").consume()

        t = time.perf_counter()
        for i in range(N): s.run("CREATE (n:Bench {id:$i, val:'v'})", i=i).consume()
        c = time.perf_counter() - t

        t = time.perf_counter()
        for i in range(N): s.run("MATCH (n:Bench {id:$i}) RETURN n.val", i=i).single()
        rd = time.perf_counter() - t

        t = time.perf_counter()
        for i in range(N): s.run("MATCH (n:Bench {id:$i}) SET n.val='v2'", i=i).consume()
        u = time.perf_counter() - t

        t = time.perf_counter()
        for i in range(N): s.run("MATCH (n:Bench {id:$i}) DELETE n", i=i).consume()
        d = time.perf_counter() - t

    drv.close()
    report("Neo4j", c, rd, u, d)

# --- SQLite ------------------------------------------------------------------
def bench_sqlite():
    db_path = os.path.join(os.environ.get("SQLITE_DIR", "/tmp"), "bench.db")
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS bench (id INT PRIMARY KEY, val TEXT)")
    cur.execute("DELETE FROM bench")
    conn.commit()

    t = time.perf_counter()
    for i in range(N): cur.execute("INSERT INTO bench VALUES (?,?)", (i, "v"))
    conn.commit(); c = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("SELECT val FROM bench WHERE id=?", (i,)); cur.fetchone()
    rd = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("UPDATE bench SET val=? WHERE id=?", ("v2", i))
    conn.commit(); u = time.perf_counter() - t

    t = time.perf_counter()
    for i in range(N): cur.execute("DELETE FROM bench WHERE id=?", (i,))
    conn.commit(); d = time.perf_counter() - t

    conn.close()
    os.remove(db_path)
    report("SQLite", c, rd, u, d)

# --- Run all -----------------------------------------------------------------
if __name__ == "__main__":
    print(f"CRUD benchmark — {N} ops each\n")
    tests = [
        ("Redis",      bench_redis),
        ("Dragonfly",  bench_dragonfly),
        ("Memcached",  bench_memcached),
        ("PostgreSQL", bench_postgres),
        ("MariaDB",    bench_mariadb),
        ("Neo4j",      bench_neo4j),
        ("SQLite",     bench_sqlite),
    ]
    for name, fn in tests:
        print(f"--- {name} ---")
        try:
            fn()
        except Exception as e:
            print(f"  SKIP: {e}")
        print()
