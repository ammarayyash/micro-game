# 🎬 PANDUAN REKAMAN PRAKTEK (SCREEN RECORDING CHEAT SHEET)
## Game: "Pixel Intro Bros" (Godot Engine 4)

Dokumen ini disusun sebagai panduan lengkap rekaman layar (*screen recording*) untuk pemenuhan bukti pengerjaan tugas kuliah sesuai pembagian peran tim (**Artist**, **Level Designer**, dan **Programmer**).

> [!IMPORTANT]
> **Game utama Anda sudah 100% SELESAI dan STABIL.**
> Seluruh kegiatan demonstrasi praktek pembuatan game dilakukan di dalam folder khusus **`Bahan_Praktek_Rekaman/`** dan diuji menggunakan tombol **F6** (*Run Current Scene*). Dengan demikian, **game utama Anda sama sekali tidak akan terpengaruh atau rusak**.

---

## 👥 IDENTITAS TIM & PEMBAGIAN TUGAS

| Peran | Nama Anggota | NIM | Tugas Praktek yang Direkam |
| :--- | :--- | :--- | :--- |
| **Artist** | **Habibulloh Zamzami** | **240533607478** | Impor aset mentahan wajah tim, tileset, dan setting Texture Filter Retro (*Nearest*). |
| **Level Designer** | **Mohammad Afton Ilman H** | **240533608523** | Menata platform, posisi Player & rintangan di `Scene_Demo_Praktek.tscn` (Uji coba via **F6**). |
| **Programmer** | **Muhammad Ammar A** | **240533606050** | Penjelasan Autoload `GameManager.gd` dan koding logika pergerakan di `Latihan_Script_Programmer.gd`. |

---

## 🎥 SKENARIO 1: PRAKTEK ARTIST (Estimasi: 1 - 2 Menit)

### A. Tujuan Rekaman:
Membuktikan bahwa Artist telah menyiapkan aset grafis pixel art (wajah 3 anggota tim, animasi gerak, tileset, dan UI) serta mengaturnya di Godot agar pixel tidak buram (*blurry*).

### B. Langkah Aksi di Layar Godot:
1. **Buka Aset Mentahan di Folder Praktek:**
   * Di panel **FileSystem** (kiri bawah), buka folder `res://Bahan_Praktek_Rekaman/Aset_Mentahan/`.
   * Klik file:
     * `raw_member_1.png`
     * `raw_member_2.png`
     * `raw_member_3.png`
     * `sample_tile_grass.png`
     * `sample_ui_panel.png`
   * *(Narasi contoh: "Di sini saya sebagai Artist telah menyiapkan aset visual pixel art mentahan untuk wajah ketiga anggota tim, tekstur platform tanah, dan panel UI.")*
2. **Tunjukkan Pengaturan Texture Filter Retro (Nearest):**
   * Klik menu atas: **Project -> Project Settings**.
   * Buka tab **General -> Rendering -> Textures -> Canvas Textures**.
   * Sorot opsi **Default Texture Filter** yang diset ke **Nearest**.
   * *(Narasi contoh: "Kita menggunakan filter Nearest agar grafis pixel art tetap tajam dan mempertahankan estetika retro 16-bit tanpa blur.")*
3. **Showcase Aset yang Telah Terintegrasi:**
   * Buka folder `res://Assets/Profiles/` untuk menunjukkan avatar final.
   * Buka folder `res://Assets/Characters/Composite/` untuk menunjukkan animasi jalan, lompat, tebasan pedang, dan animasi pusing (*dizzy*) bos.

---

## 🎥 SKENARIO 2: PRAKTEK LEVEL DESIGNER (Estimasi: 1.5 - 2 Menit)

### A. Tujuan Rekaman:
Membuktikan kemampuan menyusun level permainan secara visual di editor 2D menggunakan scene latihan tanpa mengubah level utama.

### B. Langkah Aksi di Layar Godot:
1. **Buka Scene Latihan:**
   * Di FileSystem, klik dua kali file `res://Bahan_Praktek_Rekaman/Scene_Demo_Praktek.tscn`.
2. **Praktek Menata Platform & Objek:**
   * Di panel **Scene Tree** (kiri atas), klik node `DemoGround`.
   * Tunjukkan cara menduplikasi platform (`Ctrl + D`) atau geser posisi platform untuk membuat rintangan loncatan baru di Viewport 2D.
   * Tunjukkan cara menempatkan karakter `Player` pada koordinat start.
   * *(Narasi contoh: "Sebagai Level Designer, di scene demo praktek ini saya menyusun struktur platform, mengatur jarak lompatan pemain, dan menentukan titik awal permainan.")*
3. **Uji Coba Langsung dengan F6 (Aman & Terisolasi):**
   * Tekan tombol **F6** (atau klik ikon papan klapper kecil di pojok kanan atas: *Run Current Scene*).
   * Gerakkan Player berjalan dan melompat di atas platform yang baru ditata.
   * Tutup jendela uji coba. *(Game utama tetap utuh!)*
4. **Showcase Level Game Jadi:**
   * Klik tab `res://Scenes/Level1.tscn` (tunjukkan rute hutan, checkpoint, dan arena Bos 1).
   * Klik tab `res://Scenes/Level2.tscn` (tunjukkan rute kastil yang lebih panjang, jurang berbahaya, dan arena Bos 2).

---

## 🎥 SKENARIO 3: PRAKTEK PROGRAMMER (Estimasi: 1.5 - 2 Menit)

### A. Tujuan Rekaman:
Membuktikan penerapan skrip logika: Singleton Autoload, fisika pergerakan pemain, dan sistem pergantian Hero vs Bos dinamis.

### B. Langkah Aksi di Layar Godot:
1. **Buka Bukti Autoload Global Singleton:**
   * Buka menu atas: **Project -> Project Settings -> Globals -> Autoload**.
   * Perlihatkan bahwa `GameManager` aktif sebagai Singleton universal (`res://Scripts/GameManager.gd`).
   * *(Narasi contoh: "Sebagai Programmer, saya mengonfigurasi GameManager sebagai Autoload agar data pemilihan hero, alokasi bos, dan pemutar SFX dapat diakses dari seluruh scene.")*
2. **Praktek Koding Fisika Karakter di Skrip Latihan:**
   * Di FileSystem, buka skrip `res://Bahan_Praktek_Rekaman/Latihan_Script_Programmer.gd`.
   * Jelaskan bagian-bagian kuncinya:
     * **Gravitasi**: `velocity.y += gravity * delta`
     * **Lompatan**: `velocity.y = JUMP_VELOCITY` saat tombol ditekan di lantai.
     * **Pergerakan Horizontal**: `Input.get_axis("ui_left", "ui_right") * SPEED`
     * **Pantulan Injak Kepala (Stomp Bounce)**: fungsi `bounce()` yang memberi gaya pantul ke atas.
3. **Showcase Logika Hero vs Bos Dinamis di `GameManager.gd`:**
   * Buka `res://Scripts/GameManager.gd`.
   * Tunjukkan fungsi `assign_roles(hero_index)`:
     ```gdscript
     selected_hero = team_members[hero_index]
     boss_1 = remaining[0]
     boss_2 = remaining[1]
     ```
   * *(Narasi contoh: "Fungsi ini secara otomatis menugaskan 1 anggota tim pilihan pemain menjadi Hero, sedangkan 2 anggota tim lainnya otomatis menjadi Bos Level 1 dan Bos Level 2.")*

---

## 🎮 SKENARIO 4: DEMONSTRASI GAMEPLAY LENGKAP (Durasi: ~2 Menit)

Setelah mendemonstrasikan praktek pembuatan di atas, akhiri video dengan menekan tombol **Run Project (`F5`)** untuk membuktikan bahwa game utuhnya berjalan sempurna:

1. **Menu Pemilihan Karakter (`CharacterSelect.tscn`)**:
   * Tunjukkan 3 kartu profil lengkap dengan nama, NIM, foto avatar, dan role:
     * **Muhammad Ammar A** (240533606050)
     * **Habibulloh Zamzami** (240533607478)
     * **Mohammad Afton Ilman H** (240533608523)
   * Tunjukkan bahwa kursor hover menghasilkan SFX, dan nama/NIM dapat diedit secara real-time.
   * Klik **"PILIH HERO"** pada salah satu karakter.
2. **Level 1**:
   * Hero berjalan, melompat, dan menebas musuh / menembak gelombang pedang.
   * Sentuh tiang CheckPoint (SFX koin) dan buka pop-up profil in-game.
   * Masuk arena Bos 1, kalahkan bos dengan menginjak atau menebasnya hingga bos mengalami animasi pusing (*dizzy*), jatuh, dan pintu Level 2 terbuka.
3. **Level 2**:
   * Lintasi platform kastil lava yang panjang dan rintangan jurang.
   * Hadapi Bos Level 2 yang memiliki AI pintar anti-jurang (bisa parkour melompati jurang) dan jurus **Tebasan Pedang Raksasa (*Giant Sword Slash*)**.
   * Kalahkan Bos Level 2 hingga pintu finish terbuka.
4. **Victory Screen**:
   * Tampil layar kemenangan dengan kartu pahlawan terpilih secara detail.
   * Klik tombol **"↺ MAIN LAGI"** untuk kembali ke menu awal.
