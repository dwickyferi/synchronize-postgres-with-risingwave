-- This SQL script is used to synchronize data from a PostgreSQL database to RisingWave using the PostgreSQL CDC connector.
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

-- This SQL script is used to create a table in RisingWave that will receive data from the PostgreSQL source.
-- The table structure matches the source table in PostgreSQL.
-- The table is created with the same column names and data types as the source table.
CREATE TABLE belanjaan (
    id int PRIMARY KEY,
    nama_barang VARCHAR,
    harga DECIMAL,
    jumlah INT,
    total_harga DECIMAL,
    tanggal_beli DATE ,
    status_pembayaran VARCHAR
)
FROM pg_source TABLE 'public.belanjaan';

-- This SQL script is used to create a view in RisingWave that will select data from the belanjaan table.
-- The view is created with the same column names and data types as the source table.
-- The view is created to allow for easier querying of the data in the belanjaan table.
select * from belanjaan

-- This SQL script is used to create a sink in RisingWave that will write data to a PostgreSQL database.
-- The sink is configured to use the JDBC connector to connect to the PostgreSQL database.
-- The sink is configured to use the 'upsert' type, which means that it will update existing rows in the target table
-- if they already exist, or insert new rows if they do not exist.
-- The sink is configured to use the 'id' column as the primary key for the target table.
CREATE SINK target_belanjaan_postgres_sink FROM belanjaan WITH (
    connector = 'jdbc',
    jdbc.url = 'jdbc:postgresql://postgres-vendor-1:5432/postgres',
    user = 'postgres',
    password = 'postgres',
    table.name = 'belanjaan',
    type = 'upsert',
    primary_key = 'id'
);
