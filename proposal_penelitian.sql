CREATE database proposal_db;

USE proposal_db;

CREATE TABLE mahasiswa (
    nim VARCHAR(10) PRIMARY KEY, 
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(130) NOT NULL UNIQUE,
    prodi VARCHAR(80) NOT NULL
);

CREATE TABLE kaprodi (
    nidn VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(130) NOT NULL UNIQUE,
    prodi VARCHAR(80) NOT NULL
);

CREATE TABLE dospem (
    nidn VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(130) NOT NULL UNIQUE,
    bidang_keahlian VARCHAR(80) NOT NULL
);

CREATE TABLE administrator (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE proposal (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_nim VARCHAR(10) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    topik VARCHAR(80),
    abstrak TEXT NOT NULL,
    sitasi TEXT NOT NULL,
    file_proposal BLOB NOT NULL,
    tanggal_kumpul DATE NOT NULL DEFAULT CURDATE(),    
    status_keputusan ENUM('Diajukan', 'Diterima', 'Ditolak') DEFAULT 'Diajukan' NOT NULL,
    tanggal_keputusan DATE DEFAULT NULL,
    kaprodi_nidn VARCHAR(10),
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),
    FOREIGN KEY (kaprodi_nidn) REFERENCES kaprodi(nidn)
);

CREATE TABLE bimbingan_penelitian (
    id INT PRIMARY KEY AUTO_INCREMENT,
    proposal_id INT,
    mahasiswa_nim VARCHAR(10),
    dospem_satu VARCHAR(10),
    dospem_dua VARCHAR(10),
    tanggal_mulai DATE,
    hasil_penelitian TEXT NOT NULL DEFAULT 'deskripsi penelitian',
    FOREIGN KEY (proposal_id) REFERENCES proposal(id),
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),
    FOREIGN KEY (dospem_satu) REFERENCES dospem(nidn),
    FOREIGN KEY (dospem_dua) REFERENCES dospem(nidn)
);

DELIMITER //
CREATE TRIGGER penetapan_dospem
AFTER UPDATE ON proposal
FOR EACH ROW 
BEGIN 
    DECLARE pilih_dospem1 VARCHAR(10);
    DECLARE pilih_dospem2 VARCHAR(10);

    IF NEW.status_keputusan = 'Diterima' THEN
        SELECT nidn INTO pilih_dospem1
        FROM dospem 
        WHERE bidang_keahlian = OLD.topik
        ORDER BY RAND() LIMIT 1;

        SELECT nidn INTO pilih_dospem2
        FROM dospem WHERE bidang_keahlian = OLD.topik
        AND nidn != pilih_dospem1
        ORDER BY RAND() LIMIT 1;

        INSERT INTO bimbingan_penelitian 
        SET proposal_id = OLD.id, 
        mahasiswa_nim = OLD.mahasiswa_nim, 
        dospem_satu = pilih_dospem1,
        dospem_dua = pilih_dospem2,
        tanggal_mulai = CURDATE();
    END IF;
END;
//

CREATE VIEW "notifikasi_proposal" AS
SELECT proposal.judul, mahasiswa.nama, proposal.status_keputusan, proposal.tanggal_keputusan FROM proposal 
JOIN mahasiswa ON mahasiswa.nim = proposal.mahasiswa_nim
WHERE proposal.status_keputusan = 'Diterima' OR proposal.status_keputusan = 'Ditolak';

CREATE VIEW "pembimbing_proposal" AS
SELECT proposal.judul, proposal.topik, mahasiswa.nama, dospem_satu.nama AS dospem_satu_nama, dospem_dua.nama AS dospem_dua_nama
FROM bimbingan_penelitian
JOIN proposal ON proposal.id = bimbingan_penelitian.proposal_id
JOIN mahasiswa ON mahasiswa.nim = bimbingan_penelitian.mahasiswa_nim
JOIN dospem AS dospem_satu ON dospem_satu.nidn = bimbingan_penelitian.dospem_satu
JOIN dospem AS dospem_dua ON dospem_dua.nidn = bimbingan_penelitian.dospem_dua;

CREATE TABLE form_bimbingan (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_nim VARCHAR(10),
    dospem_nidn VARCHAR(10),
    tanggal DATE NOT NULL,
    topik VARCHAR(80) NOT NULL,
    komentar TEXT NOT NULL,
    hasil_bimbingan ENUM('Disetujui', 'Ditolak'),
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),
    FOREIGN KEY (dospem_nidn) REFERENCES dospem(nidn)
);

CREATE TABLE jadwal_ujian(
    id INT PRIMARY KEY AUTO_INCREMENT,
    proposal_id INT,
    mahasiswa_nim VARCHAR(10),
    dospem_nidn VARCHAR(10),
    tanggal_ujian DATETIME NOT NULL,
    status_jadwal ENUM('Diajukan', 'Diterima', 'Ditolak') DEFAULT 'Diajukan' NOT NULL,
    tanggal_keputusan DATE,
    tanggal_ujian_disetujui DATETIME NOT NULL,
    kaprodi_nidn VARCHAR(10),
    admin_id INT,
    FOREIGN KEY (proposal_id) REFERENCES proposal(id),
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),
    FOREIGN KEY (dospem_nidn) REFERENCES dospem(nidn),
    FOREIGN KEY (admin_id) REFERENCES administrator(id)
);

CREATE VIEW "notifikasi_ujian" AS
    SELECT proposal.judul, mahasiswa.nama AS mahasiswa, jadwal_ujian.tanggal_ujian, jadwal_ujian.status_jadwal, jadwal_ujian.tanggal_keputusan, kaprodi.nama AS kaprodi FROM proposal 
    JOIN mahasiswa ON mahasiswa.nim = proposal.mahasiswa_nim
    JOIN jadwal_ujian ON jadwal_ujian.mahasiswa_nim = proposal.mahasiswa_nim
    JOIN kaprodi ON kaprodi.nidn = jadwal_ujian.kaprodi_nidn 
    WHERE jadwal_ujian.status_jadwal = 'Diterima' OR jadwal_ujian.status_jadwal = 'Ditolak';


-- memasukkan data ke tabel mahasiswa
INSERT INTO mahasiswa (nim, nama, email, prodi)  VALUES
('1901030035', 'Jasmin Lestari Usamah', 'jasminlestariusamah@gmail.com', 'Ilmu Komputer'),
('1901020080','Hasan Prayoga', 'hasannprayoga@email.com','Sistem Informasi'),
('2101010058', 'Silvia Puspita Intan','silviapuspitaaintan@gmail.com', 'Ilmu Komputer');

-- memasukkan data ke tabel kaprodi
INSERT INTO kaprodi (nidn, nama, email, prodi) VALUES
('3101050378', 'Bambang Hartono, S.T., M.T.', 'bambang.hartono@univ.ac.id', 'Ilmu Komputer'),
('3101050956', 'Elvina Santoso, S.Pd., M.KOM ', 'anton.wijaya@univ.ac.id', 'Teknik Informatika'),
('3101020239', 'Dewi Setiani, S.Pd., M.SI', 'dewi.setiani@univ.ac.id', 'Sistem Informasi');

-- mengisi data ke tabel dospem
INSERT INTO dospem (nidn, nama, email, bidang_keahlian) VALUES
('4101050630', 'Hilda Handayani Wastuti', 'hilda.handayani@univ.ac.id', 'Software Development'),
('4101050393', 'Dimas Saputra Hari', 'dimas.saputra.hari@univ.ac.id', 'Software Development'),
('4101050232', 'Dina Maryanti', 'dina.maryanti@univ.ac.id', 'Business Intelligence'),
('4101050662', 'Wahyu Purwadi Hidayat', 'wahyu.purwadi.hidayat@univ.ac.id', 'Business Intelligence');

-- memasukkan data ke tabel administrator
INSERT INTO administrator (nama_admin, email_admin) VALUES
('Jamalia Mandasari Septiani', 'admin_amalia@univ.ac.id'),
('Estiono Siregar', 'admin_tiono@univ.ac.id'),
('Farhunnisa Handayani', 'admin_farhun@univ.ac.id');

-- skenario: mahasiswa mengajukan proposal
INSERT INTO proposal (mahasiswa_nim, judul, topik, abstrak, sitasi, file_proposal) VALUES
('1901020080', 'BI: Kunci Analisis Data dan Optimasi Alokasi Sumber Daya di kampus', 'Business Intelligence', 'Abstrak proposal penelitian tentang peningkatan praktik pengembangan perangkat lunak dan business intelligence di perguruan tinggi Indonesia.', 'https://proposal/sitasi', 'proposal_bi.pdf'),
('1901030035', 'Implementasi Solusi Berbasis Cloud untuk Pengembangan Perangkat Lunak yang Terukur', 'Software Development', 'Abstrak proposal penelitian tentang implemetnasi solusi pengembangan software.', 'https://proposal/sitasi', 'software_cloud.pdf'),
('2101010058', 'Memanfaatkan Praktik DevOps untuk Integrasi, Pengiriman, dan Penerapan Berkelanjutan', 'Software Development', 'Abstrak proposal penelitian tentang praktik devops', 'https://proposal/sitasi', 'devops.pdf');

-- skenario: kaprodi menerima/ menolak proposal
UPDATE proposal SET status_keputusan = 'Diterima', tanggal_keputusan = CURDATE() WHERE id = 1 OR id = 3;
UPDATE proposal SET status_keputusan = 'Ditolak', tanggal_keputusan = CURDATE() WHERE id = 2;

-- skenario: mahasiswa mengisi form bimbingan
INSERT INTO form_bimbingan (mahasiswa_nim, dospem_nidn, tanggal, topik)
VALUES
  ('1901020080', '4101050662', '2024-05-02', 'Pemilihan algoritma'),
  ('1901020080', '4101050232', '2024-05-09', 'Penerapan metodologi'),
  ('1901020080', '4101050232', '2024-05-13', 'Revisi metodologi');

-- skenario: dospem menulis komentar dan memberikan keputusan hasil bimbingan pada form bimbingan yang telah diisi mahasiswa
UPDATE form_bimbingan SET komentar = 'Algoritma yang dipilih membuahkan hasil yang memenuhi hipotesa, dapat melanjutkan penelitian untuk monitor perkembangan', hasil_bimbingan = 'Disetujui' WHERE id = '1';
UPDATE form_bimbingan SET komentar = 'Ditemukan metodologi yang saling bertentangan dalam bidang ilmu komputer, sehingga menimbulkan kebingungan dalam memilih pendekatan yang tepat untuk penelitian.', hasil_bimbingan = 'Ditolak' WHERE id = '2';
UPDATE form_bimbingan SET komentar = 'Metodologi penelitian yang digunakan oleh mahasiswa telah memenuhi semua persyaratan, sehingga mahasiswa terkait dapat melanjutkan ke ujian.', hasil_bimbingan = 'Diterima' WHERE id = '3';


-- skenario: mahasiswa dengan NIM 1901020080 telah menyelesaikan bimbingan di bawah dospem dengan NIDN 4101050662 dan 4101050232. Dospem terkait telah meninjau hasil penelitian dan memberikan komentar, hal ini menandakan penelitian siap untuk diuji.
INSERT INTO jadwal_ujian (proposal_id, mahasiswa_nim, dospem_nidn, tanggal_ujian)
VALUES (1, '1901020080', '4101050662', '2024-05-20 10:00:00');

-- skenario: kaprodi menyetujui dan staff verifikasi tanggal ujian 
UPDATE jadwal_ujian SET status_jadwal = 'Diterima', tanggal_keputusan = CURDATE(), tanggal_ujian_disetujui = '2024-05-22 10:00:00', kaprodi_nidn = '3101020239', admin_id = '1'
WHERE proposal_id = 1;