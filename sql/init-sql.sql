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