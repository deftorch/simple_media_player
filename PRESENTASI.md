# Panduan Presentasi: Aplikasi Simple Media Player

Aplikasi ini dibagi menjadi 3 komponen utama. Setiap anggota kelompok dapat menjelaskan satu bagian untuk presentasi yang adil dan terstruktur.

## Anggota 1: Antarmuka Pengguna Utama (UI)
*Fokus File: `lib/screens/home_screen.dart` (Bagian fungsi `build`)*

**Poin Penjelasan:**
1. **Scaffold & AppBar**: Aplikasi menggunakan `Scaffold` sebagai fondasi, yang memiliki `AppBar` di bagian atas dengan judul aplikasi.
2. **Kondisi Tampilan (If-Else)**:
   - Jika `_selectedFile` bernilai `null` (belum ada yang dipilih), antarmuka hanya akan menampilkan Teks "Belum ada file media yang dipilih".
   - Jika pengguna sudah memilih file, maka aplikasi me- render `PlayerWidget` untuk memutar video/audio.
3. **ElevatedButton**: Tombol dibagian bawah digunakan untuk memicu logika pemilihan media melalui metode `_pickFile()`.

---

## Anggota 2: Logika I/O dan Pemilihan File
*Fokus File: `lib/screens/home_screen.dart` (Bagian fungsi `_pickFile()`)*

**Poin Penjelasan:**
1. **Plugin File Picker**: Aplikasi menggunakan package `file_picker` untuk memudahkan akses storage perangkat.
2. **Filter Ekstensi**: Pada perintah `FilePicker.platform.pickFiles()`, parameter `type: FileType.media` diterapkan. Ini membuat galeri/pencari file hanya menampilkan file media (seperti `.mp4`, `.mp3`) tanpa menyertakan ekstensi yang tidak relevan (seperti dokumen word).
3. **Pembaruan State (setState)**: Jika terdapat hasil tangkapan file, aplikasi menggunakan blok `setState()` untuk mengganti `_selectedFile`. Pemanggilan `setState` ini yang akan memicu Anggota 1 (UI) untuk mengubah visual dari Teks menjadi Pemutar Media.

---

## Anggota 3: Pemutar Media Utama (Player Widget)
*Fokus File: `lib/widgets/player_widget.dart`*

**Poin Penjelasan:**
1. **VideoPlayerController**: Otak utamanya adalah `VideoPlayerController`. Widget ini menginisialisasi controller menggunakan sinkronisasi `File` dari perangkat lokal.
2. **Siklus Hidup (Lifecycle)**: 
   - `initState`: Dijalankan pertama kali saat widget dibangun. Memulai video dengan fungsi `play()`.
   - `didUpdateWidget`: Dijalankan jika file yang dipilih pengguna tiba-tiba berubah (misalnya pengguna memencet tombol pilih file kembali).
   - `dispose`: Controller dihancurkan apabila tidak terpakai untuk menyelamatkan pemakaian memori perangkat.
3. **Progress Indicator**: Kita memasang `VideoProgressIndicator` yang dikaitkan ke controller sehingga timeline garis video tersebut bisa digeser kanan/kiri (di-scrub).
4. **Tombol Jeda/Putar**: Terdapat `IconButton` yang logikanya sangat sederhana. Ia selalu memeriksa `isPlaying` (jika main, jeda. Jika jeda, mainkan).
