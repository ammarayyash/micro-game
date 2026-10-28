# 🎬 PANDUAN REKAMAN PRAKTEK (SCREEN RECORDING CHEAT SHEET)
## Game: "Pixel Intro Bros" (Godot Engine 4)

Dokumen ini disusun sebagai panduan rekaman layar (*screen recording*) untuk pemenuhan bukti pengerjaan tugas kuliah sesuai pembagian peran tim (**Artist**, **Level Designer**, dan **Programmer**).

Game utama Anda sudah **100% jadi dan siap dimainkan**. Seluruh praktek demonstrasi pada panduan ini menggunakan folder isolasi [`Bahan_Praktek_Rekaman/`](file:///e:/Kuliah%20Mamank/Semester%205/05%20-%20Game/Pertemuan%20ke-10%20-%2028-10/Game%20baru%203/Bahan_Praktek_Rekaman), sehingga **tidak akan merusak atau mengganggu sistem game utama**.

---

## 📋 DAFTAR CHECKLIST TUGAS (Trello Verification)

| Peran | Tugas | Status di Proyek |
| :--- | :--- | :---: |
| **Artist** | 1. 3 Wajah Pixelate Anggota Tim | ✅ Siap di `Assets/Profiles/` |
| | 2. Spritesheet Karakter Utama (Jalan, Lompat) | ✅ Siap di `Assets/Profiles/Member 1/` |
| | 3. Spritesheet Bos (Kena Injak / Pusing) | ✅ Siap di `Assets/Profiles/Member 1/` |
| | 4. Aset Lingkungan (Tileset & Rintangan) | ✅ Siap di `Assets/Environment/` |
| | 5. Aset UI Panel Pop-up & Tombol | ✅ Siap di `Assets/UI/` |
| **Level Designer** | 1. Setup Struktur Folder Proyek Godot | ✅ Folder `Scenes`, `Scripts`, `Assets` |
| | 2. Desain Scene Menu Pemilihan Karakter | ✅ `Scenes/CharacterSelect.tscn` |
| | 3. Desain Scene Level 1 (Hutan + Bos 1) | ✅ `Scenes/Level1.tscn` |
| | 4. Desain Scene Level 2 (Kastil + Bos 2) | ✅ `Scenes/Level2.tscn` |
| **Programmer** | 1. Autoload Global Variable Sistem Karakter | ✅ `Scripts/GameManager.gd` |
| | 2. Skrip Pergerakan Pemain (`Player.gd`) | ✅ Lari, lompat, gravitasi, pantulan injak |
| | 3. Skrip Interaksi Bos & Pop-up Profil | ✅ `Scripts/Boss.gd` & `ProfilePopup.gd` |

---

## 🎥 SKENARIO 1: REKAMAN TUGAS ARTIST (Estimasi Durasi: 1 - 2 Menit)

### A. Tujuan Rekaman:
Membuktikan bahwa Artist telah menyiapkan aset visual pixel art (wajah tim, animasi gerak/pusing, tileset, dan UI panel) dan mengimpornya ke dalam Godot.

### B. Langkah Aksi Layar:
1. **Showcase Wajah Pixelate:**
   * Di panel **FileSystem** (kiri bawah Godot), klik buka folder `res://Assets/Profiles/`.
   * Klik dua kali atau sorot file `member_1.png`, `member_2.png`, dan `member_3.png`.
   * *(Narasi: "Berikut adalah 3 aset wajah pixelate anggota tim yang akan digunakan sebagai identitas Hero dan Bos.")*
2. **Showcase Aset Gerak Karakter & Bos:**
   * Buka folder `res://Assets/Profiles/Member 1/`.
   * Sorot file gambar: `char_idle.png`, `char_walk.png`, `char_jump.png`, dan `char_dizzy.png`.
   * Tunjukkan bahwa aset ini memuat animasi berjalan, melompat, hingga animasi pusing/kalah saat menjadi bos.
3. **Praktek Impor & Setting Texture Filter Retro (Bukti Aksi):**
   * Di FileSystem, buka folder `res://Bahan_Praktek_Rekaman/Aset_Mentahan/`.
   * Klik salah satu file `raw_member_1.png`, lalu lihat panel **Inspector** di sebelah kanan.
   * Tunjukkan setting atau buka `Project -> Project Settings -> Rendering -> Textures -> Canvas Textures -> Default Texture Filter: Nearest`.
   * *(Narasi: "Kita memastikan filter tekstur menggunakan Nearest agar grafis pixel art tetap tajam dan tidak kabur.")*
4. **Showcase Aset UI & Lingkungan:**
   * Buka folder `res://Assets/UI/` dan `res://Assets/Environment/` untuk memperlihatkan tileset tanah dan komponen pop-up retro.

---

## 🎥 SKENARIO 2: REKAMAN TUGAS LEVEL DESIGNER (Estimasi Durasi: 1.5 - 2 Menit)

### A. Tujuan Rekaman:
Membuktikan penataan struktur folder proyek serta penyusunan scene level permainan di Godot Engine.

### B. Langkah Aksi Layar:
1. **Showcase Struktur Folder Proyek:**
   * Sorot panel **FileSystem** dan perlihatkan folder utama yang rapi: `Assets`, `Scenes`, `Scripts`, dan `Bahan_Praktek_Rekaman`.
   * *(Narasi: "Struktur proyek Godot telah disusun rapi memisahkan antara Scenes, Scripts, dan Assets.")*
2. **Praktek Menyusun Level (Bukti Aksi di Scene Demo):**
   * Buka scene [`res://Bahan_Praktek_Rekaman/Scene_Demo_Praktek.tscn`](file:///e:/Kuliah%20Mamank/Semester%205/05%20-%20Game/Pertemuan%20ke-10%20-%2028-10/Game%20baru%203/Bahan_Praktek_Rekaman/Scene_Demo_Praktek.tscn).
   * Di viewport 2D, klik node `DemoGround` atau buat node balok baru untuk mendemonstrasikan cara meletakkan platform tanah.
   * Drag instance `Player.tscn` dari folder `Scenes/Prefabs/` ke dalam viewport.
   * *(Narasi: "Di sini kita mendesain platform rintangan dan menentukan posisi awal pemain melompat.")*
3. **Review Scene Game Jadi:**
   * Buka tab scene `res://Scenes/Level1.tscn`: Perlihatkan susunan rute taman/hutan, letak Player, posisi Bos 1, dan Goal Door.
   * Buka tab scene `res://Scenes/Level2.tscn`: Perlihatkan rintangan platform batu kastil dan posisi Bos Terakhir.
   * Buka tab scene `res://Scenes/CharacterSelect.tscn`: Perlihatkan tata letak 3 kartu pemilihan karakter tim.

---

## 🎥 SKENARIO 3: REKAMAN TUGAS PROGRAMMER (Estimasi Durasi: 2 Menit)

### A. Tujuan Rekaman:
Membuktikan implementasi skrip logika pemilihan dinamis karakter, pergerakan player, dan mekanik injak kepala bos.

### B. Langkah Aksi Layar:
1. **Bukti Autoload / Global Variable:**
   * Buka menu atas: **Project -> Project Settings -> Globals -> Autoload**.
   * Tunjukkan bahwa `GameManager` (`res://Scripts/GameManager.gd`) terdaftar aktif sebagai Singleton.
   * *(Narasi: "GameManager dikonfigurasi sebagai Autoload untuk menyimpan state pemilihan karakter dan alokasi bos secara global.")*
2. **Review Skrip `GameManager.gd`:**
   * Buka tab **Script** dan pilih `GameManager.gd`.
   * Sorot baris fungsi `assign_roles(hero_index)`:
     ```gdscript
     selected_hero = team_members[hero_index]
     # Anggota yang tidak dipilih otomatis di-assign menjadi Boss 1 dan Boss 2
     boss_1 = remaining[0]
     boss_2 = remaining[1]
     ```
   * *(Narasi: "Fungsi assign_roles memastikan 1 anggota yang dipilih menjadi Hero, dan 2 anggota sisanya otomatis menjadi Bos 1 dan Bos 2.")*
3. **Review Skrip `Player.gd` & Stomp Bounce:**
   * Pilih `Player.gd`.
   * Sorot fungsi pergerakan horizontal `Input.get_axis`, lompatan `JUMP_VELOCITY`, dan fungsi pantulan:
     ```gdscript
     func bounce(force: float = BOUNCE_VELOCITY) -> void:
         velocity.y = force
     ```
   * *(Narasi: "Fungsi bounce dipanggil saat kaki pemain menginjak kepala musuh, memberi gaya pantulan ke atas.")*
4. **Review Skrip `Boss.gd` & `ProfilePopup.gd`:**
   * Pilih `Boss.gd`, sorot fungsi `_on_head_hurtbox_body_entered` saat mendeteksi tabrakan dari atas:
     ```gdscript
     boss_defeated.emit(boss_data)
     ```
   * Tunjukkan skrip `ProfilePopup.gd` yang menggunakan `process_mode = PROCESS_MODE_ALWAYS` dan `get_tree().paused = true` saat memunculkan Nama, NIM, dan Foto Bos.

---

## 🎮 SKENARIO 4: DEMONSTRASI GAMEPLAY LENGKAP (Durasi: ~1.5 Menit)

### Kontrol Permainan & Sistem Senjata:
* **Bergerak Kiri/Kanan**: `A` / `D` atau `Panah Kiri` / `Panah Kanan`
* **Lompat Tinggi**: `W` / `Space` / `Panah Atas` (Lompatan akrobatik tinggi untuk menjangkau platform & kepala bos)
* **Tebasan Pedang Melee**: `Z` / `J` / `Klik Kiri Mouse` (**Damage: 2** — 2x lebih besar, efektif menghabisi monster biasa dalam 1 tebasan jarak dekat!)
* **Gelombang Pedang Jarak Jauh (Sword Beam)**: `X` / `K` / `Klik Kanan Mouse` (**Damage: 1** — Pedang menembakkan gelombang tebasan berelemen biru berputar, aman digunakan untuk menyerang dari kejauhan)

### Tampilan Antarmuka (UI Retro Kenney):
* **HUD Panel Kiri Atas**: Bingkai 9-slice retro berisi indikator Darah berbentuk ikon Hati Pixel Art (`ui_heart_full.png`) dan jumlah sisa monster.
* **Slot Senjata Kanan Atas**: Menampilkan 2 slot senjata aktif (Pedang Besi Melee 2 DMG dan Gelombang Pedang 1 DMG).
* **Banner Bawah**: Petunjuk tombol kontrol berbingkai retro biru.
* **Kartu Karakter & Pop-up**: Menggunakan panel perkamen (*parchment*) 9-slice dan bingkai slot avatar.

Tekan tombol **Run Project (`F5`)** di pojok kanan atas Godot dan mainkan alur berikut secara mulus:

1. **Layar Character Select (3 Anggota Tim dengan Input Dinamis):**
   * Tampil 3 kartu perkamen retro 9-slice:
     * **Kartu 1**: Mamank (Member 1 - Programmer)
     * **Kartu 2**: Member 2 (Artist)
     * **Kartu 3**: Member 3 (Level Designer)
   * Anda bisa mengetik langsung untuk mengubah Nama & NIM pada ketiga kartu.
   * Klik tombol **"PILIH HERO"** pada salah satu pahlawan pilihan Anda (misal: Member 1).
   * **2 Anggota yang tidak dipilih otomatis menjadi Bos**:
     * Anggota sisa pertama $\rightarrow$ Menjadi **Bos 1 di Level 1** (Member 2).
     * Anggota sisa kedua $\rightarrow$ Menjadi **Bos Terakhir di Level 2** (Member 3).
   * Game berpindah ke **Level 1**.
2. **Level 1 (Rute Hutan & Bos 1):**
   * Jelajahi platform hutan panjang (4280px), kalahkan monster dengan tebasan pedang (2 DMG) atau gelombang pedang (1 DMG).
   * Sentuh tiang CheckPoint di tengah rute.
   * Masuk gerbang arena dan kalahkan **Bos 1 (Member 2)**.
   * Pop-up Profil Bos 1 (Nama, NIM, Role Artist) muncul di layar $\rightarrow$ Klik **"LANJUT >>"**.
   * Pintu Goal Door terbuka $\rightarrow$ Masuk ke pintu $\rightarrow$ Game otomatis lanjut ke **Level 2**!
3. **Level 2 (Kastil Goa Lava & Bos Terakhir):**
   * Suasana kastil gelap dengan jurang lahar membara (*lava hazards*) di bawah platform batu abu-abu (`brick_grey.png`) dan merah (`brick_red.png`).
   * Lompati anak tangga batu dan hadapi monster penjaga kastil (Skeleton, Boar, Alien Mage, Zombie).
   * Sentuh CheckPoint tiang bendera dungeon kastil.
   * Masuk Gerbang Istana $\rightarrow$ Hadapi **Bos 2 / Bos Terakhir (Member 3 - Level Designer)** berukuran raksasa 3x!
   * Kalahkan Bos 2 $\rightarrow$ Pop-up Profil Bos Terakhir (Nama, NIM, Role Level Designer) muncul $\rightarrow$ Klik **"LANJUT >>"**.
   * Pintu Goal Door terbuka $\rightarrow$ Masuk ke pintu $\rightarrow$ Menuju **Victory Screen**!
4. **Victory Screen (Layar Kemenangan Pahlawan):**
   * Tampil teks **"★ LEVEL CLEARED! ★"**.
   * Kartu pahlawan terpilih (Member 1) ditampilkan besar memperlihatkan foto pixel, Nama, NIM, dan perannya.
   * Klik tombol **"↺ MAIN LAGI"** untuk kembali ke menu awal.

---

### 💡 Tips Tambahan Saat Merekam:
* **Resolusi Rekaman:** Disarankan menggunakan OBS Studio atau Windows Game Bar (`Win + G`) pada resolusi 1080p.
* **Kustomisasi Identitas Tim:** Jika ingin mengubah Nama & NIM menjadi data riil anggota kelompok Anda, cukup buka file [`Scripts/GameManager.gd`](file:///e:/Kuliah%20Mamank/Semester%205/05%20-%20Game/Pertemuan%20ke-10%20-%2028-10/Game%20baru%203/Scripts/GameManager.gd) dan ubah nilai pada array `team_members`.
