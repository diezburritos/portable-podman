use std::io::{BufRead, BufReader, Write};
use std::net::TcpStream;
use std::time::Instant;

const N: usize = 1000;

fn ms(d: std::time::Duration) -> f64 { d.as_secs_f64() * 1000.0 }
fn ops(d: std::time::Duration) -> f64 { N as f64 / d.as_secs_f64() }

fn report(op: &str, d: std::time::Duration) {
    println!("  {:>8}: {:>10.1}ms  ({:.0} ops/s)", op, ms(d), ops(d));
}

// --- SQLite ------------------------------------------------------------------

fn bench_sqlite() {
    let dir = std::env::var("SQLITE_DIR").unwrap_or("/tmp".into());
    let path = format!("{}/bench_rust.db", dir);
    let _ = std::fs::remove_file(&path);

    let conn = rusqlite::Connection::open(&path).unwrap();
    conn.execute_batch("PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL;").unwrap();
    conn.execute("CREATE TABLE bench (id INTEGER PRIMARY KEY, val TEXT)", []).unwrap();

    let t = Instant::now();
    for i in 0..N {
        conn.execute("INSERT INTO bench VALUES (?1, ?2)", rusqlite::params![i, "v"]).unwrap();
    }
    report("create", t.elapsed());

    let t = Instant::now();
    for i in 0..N {
        let mut stmt = conn.prepare_cached("SELECT val FROM bench WHERE id=?1").unwrap();
        let _: String = stmt.query_row([i], |r| r.get(0)).unwrap();
    }
    report("read", t.elapsed());

    let t = Instant::now();
    for i in 0..N {
        conn.execute("UPDATE bench SET val=?1 WHERE id=?2", rusqlite::params!["v2", i]).unwrap();
    }
    report("update", t.elapsed());

    let t = Instant::now();
    for i in 0..N {
        conn.execute("DELETE FROM bench WHERE id=?1", [i]).unwrap();
    }
    report("delete", t.elapsed());

    drop(conn);
    let _ = std::fs::remove_file(&path);
}

// --- Memcached (raw ASCII protocol over TCP) ---------------------------------

struct MemcacheConn {
    reader: BufReader<TcpStream>,
    writer: TcpStream,
}

impl MemcacheConn {
    fn connect(addr: &str) -> std::io::Result<Self> {
        let stream = TcpStream::connect(addr)?;
        let writer = stream.try_clone()?;
        Ok(Self { reader: BufReader::new(stream), writer })
    }

    fn set(&mut self, key: &str, val: &[u8]) -> std::io::Result<()> {
        write!(self.writer, "set {} 0 60 {}\r\n", key, val.len())?;
        self.writer.write_all(val)?;
        self.writer.write_all(b"\r\n")?;
        self.writer.flush()?;
        let mut line = String::new();
        self.reader.read_line(&mut line)?;
        Ok(())
    }

    fn get(&mut self, key: &str) -> std::io::Result<Option<Vec<u8>>> {
        write!(self.writer, "get {}\r\n", key)?;
        self.writer.flush()?;
        let mut line = String::new();
        self.reader.read_line(&mut line)?;
        if line.starts_with("END") { return Ok(None); }
        let len: usize = line.split_whitespace().nth(3).unwrap_or("0").parse().unwrap_or(0);
        let mut buf = vec![0u8; len + 2]; // +2 for \r\n
        std::io::Read::read_exact(&mut self.reader, &mut buf)?;
        buf.truncate(len);
        let mut end = String::new();
        self.reader.read_line(&mut end)?;
        Ok(Some(buf))
    }

    fn delete(&mut self, key: &str) -> std::io::Result<()> {
        write!(self.writer, "delete {}\r\n", key)?;
        self.writer.flush()?;
        let mut line = String::new();
        self.reader.read_line(&mut line)?;
        Ok(())
    }
}

fn bench_memcached() {
    let addr = std::env::var("MEMCACHED_HOST").unwrap_or("host.containers.internal:11211".into());
    let mut mc = MemcacheConn::connect(&addr).unwrap();
    let keys: Vec<String> = (0..N).map(|i| format!("rbench:{}", i)).collect();

    let t = Instant::now();
    for k in &keys { mc.set(k, b"v").unwrap(); }
    report("create", t.elapsed());

    let t = Instant::now();
    for k in &keys { mc.get(k).unwrap(); }
    report("read", t.elapsed());

    let t = Instant::now();
    for k in &keys { mc.set(k, b"v2").unwrap(); }
    report("update", t.elapsed());

    let t = Instant::now();
    for k in &keys { mc.delete(k).unwrap(); }
    report("delete", t.elapsed());
}

// --- Main --------------------------------------------------------------------

fn main() {
    println!("Rust CRUD benchmark — {} ops each\n", N);

    println!("--- SQLite (autocommit, WAL mode) ---");
    bench_sqlite();
    println!();

    println!("--- Memcached (raw TCP) ---");
    match std::panic::catch_unwind(bench_memcached) {
        Ok(_) => {},
        Err(_) => println!("  SKIP: memcached not reachable"),
    }
    println!();
}
