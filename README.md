# 🔄 PostgreSQL Synchronization with RisingWave

This project demonstrates real-time data synchronization between two PostgreSQL instances using RisingWave as the CDC (Change Data Capture) pipeline.

## 🏗️ Architecture Overview

```
PostgreSQL Source (vendor-0) -> RisingWave -> PostgreSQL Target (vendor-1)
```

## 📋 Prerequisites

- Docker and Docker Compose
- At least 32GB RAM (RisingWave requirement)
- PostgreSQL client (psql)

## 🚀 Quick Start

### 1. 🛠️ Start the Infrastructure

Start all required services using Docker Compose:

```bash
docker-compose up -d
```

This will start:

- RisingWave components (meta-node, compute-node, frontend-node, compactor)
- Source PostgreSQL (postgres-vendor-0)
- Target PostgreSQL (postgres-vendor-1)
- MinIO (object storage)
- Prometheus (monitoring)

### 2. 🎯 Initialize Source Database

Connect to the source PostgreSQL instance and create the initial table structure:

```bash
psql -h localhost -p 5566 -U postgres -d postgres
```

Execute the initialization SQL:

```sql
CREATE TABLE belanjaan (
    id SERIAL PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    harga DECIMAL(10,2) NOT NULL,
    jumlah INTEGER NOT NULL,
    total_harga DECIMAL(10,2),
    tanggal_beli DATE DEFAULT CURRENT_DATE,
    status_pembayaran VARCHAR(20) DEFAULT 'pending'
);

INSERT INTO belanjaan (nama_barang, harga, jumlah, total_harga, status_pembayaran)
VALUES
    ('Pensil 2B', 3000.00, 5, 15000.00, 'lunas'),
    ('Penghapus', 2000.00, 2, 4000.00, 'pending'),
    ('Tas Sekolah', 150000.00, 1, 150000.00, 'lunas');
```

### 3. ⚙️ Configure CDC on Source PostgreSQL

Enable logical replication:

```sql
ALTER SYSTEM SET wal_level = logical;
CREATE PUBLICATION rw_publication FOR TABLE belanjaan;
```

### 4. 🔗 Set Up RisingWave Pipeline

Connect to RisingWave and create the synchronization pipeline:

```bash
psql -h localhost -p 4566 -d dev -U root
```

Execute the RisingWave SQL commands:

```sql
-- Create source connector
CREATE SOURCE pg_source WITH (
    connector='postgres-cdc',
    hostname='postgres-vendor-0',
    port='5432',
    username='postgres',
    password='postgres',
    database.name='postgres',
    schema.name='public',
    slot.name = 'rising_wave',
    publication.name ='rw_publication'
);

-- Create materialized view
CREATE TABLE belanjaan (
    id int PRIMARY KEY,
    nama_barang VARCHAR,
    harga DECIMAL,
    jumlah INT,
    total_harga DECIMAL,
    tanggal_beli DATE,
    status_pembayaran VARCHAR
)
FROM pg_source TABLE 'public.belanjaan';

-- Create sink to target PostgreSQL
CREATE SINK target_belanjaan_postgres_sink FROM belanjaan WITH (
    connector = 'jdbc',
    jdbc.url = 'jdbc:postgresql://postgres-vendor-1:5432/postgres',
    user = 'postgres',
    password = 'postgres',
    table.name = 'belanjaan',
    type = 'upsert',
    primary_key = 'id'
);
```

## 🧪 Testing the Synchronization

1. Insert new data into source PostgreSQL:

```sql
INSERT INTO belanjaan (nama_barang, harga, jumlah, total_harga, status_pembayaran)
VALUES ('Buku Tulis', 5000.00, 3, 15000.00, 'pending');
```

2. Verify data in target PostgreSQL:

```bash
psql -h localhost -p 5577 -U postgres -d postgres -c "SELECT * FROM belanjaan;"
```

## 📊 Monitoring

- RisingWave Dashboard: http://localhost:5691
- Prometheus: http://localhost:9500

## 📁 Project Structure

```
.
├── docker-compose.yml      # Docker services configuration
├── risingwave.toml        # RisingWave configuration
├── prometheus.yaml        # Prometheus configuration
└── sql/
    ├── init-sql.sql      # Source database initialization
    └── rising-wave.sql   # RisingWave pipeline setup
```

## 📜 License

Apache License 2.0

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
