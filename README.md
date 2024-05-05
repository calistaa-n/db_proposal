# Sistem Pengajuan Proposal
by calistaa-n

## Deskripsi
Sistem ini dirancang untuk mengelola proses pengajuan proposal, bimbingan proposal penelitian, dan pengajuan ujian. Hal ini mencakup pengajuan dan peninjauan oleh ketua prodi (diterima/ditolak), mengisi form untuk monitor progress bimbingan penelitian oleh mahasiswa dan dosen pembimbing, mengajukan jadwal ujian yang kemudian disetujui/ ditolak oleh ketua prodi serta pengesahan tanggal ujian oleh administrator.

## Kebutuhan Fungsional
Basis data ini dirancang untuk mengelola sistem pengajuan proposal dalam lingkup universitas. Berikut spesifikasi fungsional pada setiap entitas:

### Mahasiswa
- Mengajukan proposal penelitian
- Melaksanakan penelitian apabila proposal telah disetujui
- Membuat dan mengisi form bimbingan penelitian
- Mengajukan jadwal ujian
- Melihat notifikasi apakah proposal diterima atau ditolak
- Melihat notifikasi apakah pengajuan jadwal diterima atau ditolak

### Ketua Program Studi/ Kaprodi
- Menyetujui atau menolak pengajuan proposal
- Melakukan pemetaan pembimbing penelitian
- Menyetujui atau menolak pengajuan ujian

### Dosen Pembimbing/ Dospem
- Melakukan bimbingan penelitian
- Mengisi form bimbingan mahasiswa
- Melihat notifikasi apakah pengajuan ujian diterima atau ditolak

### Administrator
- Melakukan manajemen pengguna
- Melakukan verifikasi tanggal ujian

## Relationships
![ERD Sistem Pengajuan Proposal](/sql_proposal/erd_proposal.drawio.png)
- Seorang mahasiswa hanya dapat mengajukan satu proposal. (1:1)
- Seorang kaprodi dapat meninjau banyak proposal. (1:N)
- Dua dospem dapat melakukan satu bimbingan penelitian. (N:1)
- Seorang mahasiswa hanya dapat mengikuti satu bimbingan penelitian per proposal. (1:1)
- Seorang mahasiswa dapat mengisi banyak form bimbingan. (1:N)
- Seorang dospem dapat mengisi banyak form bimbingan. (1:N)
- Seorang mahasiswa hanya dapat menjadwalkan satu ujian, dapat mengajukan kembali jika jadwal ditolak. (1:1)
- Seorang kaprodi dapat meninjau banyak jadwal ujian. (1:N)
- Seorang administrator dapat mengesahkan tanggal untuk banyak jadwal ujian. (1:N)

## Uraian Entitas
Bagian ini menjelaskan atribut-atribut dari entitas utama dan entitas asosiatif/ _junction table_

### Entitas Utama

**mahasiswa**
> CREATE TABLE mahasiswa ( <br>
    nim VARCHAR(10) PRIMARY KEY, <br>
    nama VARCHAR(255) NOT NULL, <br>
    email VARCHAR(130) NOT NULL UNIQUE, <br>
    prodi VARCHAR(80) NOT NULL <br>
);
- Nomor Induk Mahasiswa(NIM) bersifat unik dan permanen sehingga cocok digunakan sebagai _primary key_.

**kaprodi**
> CREATE TABLE kaprodi (<br>
    nidn VARCHAR(10) PRIMARY KEY, <br>
    nama VARCHAR(255) NOT NULL,<br>
    email VARCHAR(130) NOT NULL UNIQUE,<br>
    prodi VARCHAR(80) NOT NULL<br>
);
- NIDN digunakan sebagai _primary key_ karena bersifat unik dan permanen selama karir dosen.

**dospem**
> CREATE TABLE dospem ( <br>
    nidn VARCHAR(10) PRIMARY KEY,<br>
    nama VARCHAR(255) NOT NULL,<br>
    email VARCHAR(130) NOT NULL UNIQUE,<br>
    bidang_keahlian VARCHAR(80) NOT NULL<br>
);
- NIDN digunakan sebagai _primary key_ karena bersifat unik dan permanen selama karir dosen.

**administrator**
> CREATE TABLE administrator ( <br>
    id INT PRIMARY KEY AUTO_INCREMENT,<br>
    nama VARCHAR(255) NOT NULL,<br>
    email VARCHAR(80) NOT NULL UNIQUE <br>
);
- _primary key_ dengan AUTO_INCREMENT digunakan untuk kemudahan dalam menentukan nilai unik.

#### Catatan:
- Nama lengkap dengan panjang maksimal 255 karakter, menyesuaikan nama Indonesia yang rata-rata memiliki nama depan, tengah, belakang.
- Alamat email harus unik, mencegah 1 email digunakan lebih dari 1 orang.
- Constraint NOT NULL digunakan pada kolom nama, email, prodi, dan bidang keahlian untuk memastikan data tidak kosong.


### Entitas Asosiatif
**proposal**

> CREATE TABLE proposal (<br>
    id INT PRIMARY KEY AUTO_INCREMENT, <br>
    mahasiswa_nim VARCHAR(10) NOT NULL,<br>
    judul VARCHAR(255) NOT NULL,<br>
    topik VARCHAR(80),<br>
    abstrak TEXT NOT NULL,<br>
    sitasi TEXT NOT NULL,<br>
    file_proposal BLOB NOT NULL,<br>
    tanggal_kumpul DATE NOT NULL DEFAULT CURDATE(),<br>
    status_keputusan ENUM('Diajukan', 'Diterima', 'Ditolak') DEFAULT 'Diajukan' NOT NULL, <br>
    tanggal_keputusan DATE DEFAULT NULL,<br>
    kaprodi_nidn VARCHAR(10),<br>
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),<br>
    FOREIGN KEY (kaprodi_nidn) REFERENCES kaprodi(nidn)<br>
);
- _primary key_ dengan AUTO_INCREMENT untuk memudahkan sistem generate nilai unik.
- mahasiswa_nim dan kaprodi_nidn sebagai _foreign key_ untuk mengetahui identitas mahasiswa yang mengumpulkan proposal dan identitas kaprodi yang menyetujui/ menolak proposal.

**bimbingan_penelitian**

> CREATE TABLE bimbingan_penelitian (<br>
    id INT PRIMARY KEY AUTO_INCREMENT,<br>
    proposal_id INT,<br>
    mahasiswa_nim VARCHAR(10),<br>
    dospem_satu VARCHAR(10),<br>
    dospem_dua VARCHAR(10),<br>
    tanggal_mulai DATE,<br>
    hasil_penelitian TEXT NOT NULL DEFAULT 'deskripsi penelitian',<br>
    FOREIGN KEY (proposal_id) REFERENCES proposal(id),<br>
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),<br>
    FOREIGN KEY (dospem_satu) REFERENCES dospem(nidn),<br>
    FOREIGN KEY (dospem_dua) REFERENCES dospem(nidn)<br>
);
- _primary key_ dengan AUTO_INCREMENT untuk memudahkan sistem generate nilai unik.
- mahasiswa_nim, dospem_satu dan dospem_dua sebagai _foreign key_ diperlukan untuk menghubungkan antara mahasiswa yang mengajukan proposal dengan dospem yang bertugas untuk membimbing.

**form_bimbingan**
> CREATE TABLE form_bimbingan (<br>
    id INT PRIMARY KEY AUTO_INCREMENT,<br>
    mahasiswa_nim VARCHAR(10),<br>
    dospem_nidn VARCHAR(10),<br>
    tanggal DATE NOT NULL,<br>
    topik VARCHAR(80) NOT NULL,<br>
    komentar TEXT NOT NULL,<br>
    hasil_bimbingan ENUM('Disetujui', 'Ditolak'),<br>
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),<br>
    FOREIGN KEY (dospem_nidn) REFERENCES dospem(nidn)<br>
);
- _primary key_ dengan AUTO_INCREMENT untuk memudahkan sistem generate nilai unik.
- mahasiswa_nim dan dospem_nidn sebagai _foreign key_ diperlukan untuk mengetahui mahasiswa melakukan bimbingan dengan dosen terkait.

**jadwal_ujian**
> CREATE TABLE jadwal_ujian(<br>
    id INT PRIMARY KEY AUTO_INCREMENT,<br>
    proposal_id INT,<br>
    mahasiswa_nim VARCHAR(10),<br>
    dospem_nidn VARCHAR(10),<br>
    tanggal_ujian DATETIME NOT NULL,<br>
    status_jadwal ENUM('Diajukan', 'Diterima', 'Ditolak') DEFAULT 'Diajukan' NOT NULL,<br>
    tanggal_keputusan DATE,<br>
    tanggal_ujian_disetujui DATETIME NOT NULL,<br>
    kaprodi_nidn VARCHAR(10),<br>
    admin_id INT,<br>
    FOREIGN KEY (proposal_id) REFERENCES proposal(id),<br>
    FOREIGN KEY (mahasiswa_nim) REFERENCES mahasiswa(nim),<br>
    FOREIGN KEY (dospem_nidn) REFERENCES dospem(nidn),<br>
    FOREIGN KEY (admin_id) REFERENCES administrator(id)<br>
);
- _primary key_ dengan AUTO_INCREMENT untuk memudahkan sistem generate nilai unik.
- proposal_id sebagai _foreign key_ untuk menyimpan informasi proposal yang akan diuji.
- kaprodi_nidn dan admin_id sebagai _foreign key_ untuk menyimpan data kaprodi yang menyetujui/ menolak.
- admin_id sebagai _foreign key_ yang melakukan verifikasi tanggal ujian.

#### Catatan:
status_keputusan/ hasil_bimbingan
- menggunakan ENUM dengan mempertimbangkan 2 nilai kemungkinan yaitu 'disetujui' atau 'ditolak' dengan default 'diajukan' (kecuali tabel form_bimbingan).
- penggunaan tipe data ini juga memudahkan pemfilteran data.

tgl_kumpul
- penggunaan CURDATE() memastikan data yang akurat dan konsisten, serta memudahkan pelacakan tanggal.

## Optimasi

### Trigger

- trigger penetapan_dospem berfungsi untuk menetapkan dua dosen pembimbing (dospem) pada proposal yang telah disetujui (status keputusan 'Diterima'). Memilih dospem secara acak dengan membandingkan apakah bidang keahlian dospem dan topik proposal sama, jika iya dospem akan membimbing proposal terkait.

### View

- view notifikasi_proposal berfungsi untuk menampilkan informasi penting terkait status proposal seperti judul proposal, nama mahasiswa, status, dan tanggal proposal diterima/ditolak. View ini hanya menampilkan proposal yang telah mendapatkan keputusan (Diterima atau Ditolak).
- view pembimbing_proposal berfungsi untuk menampilkan informasi penting terkait bimbingan proposal penelitian seperti judul proposal, topik, nama mahasiswa, nama dospem satu, dan nama dospem dua. View ini memudahkan pencarian informasi dan monitoring proses bimbingan penelitian.
- view notifikasi_ujian berfungsi untuk menampilkan informasi penting terkait jadwal ujian proposal yang telah mendapatkan keputusan (Diterima atau Ditolak). View ini memudahkan monitoring dan notifikasi kepada pihak-pihak terkait.
