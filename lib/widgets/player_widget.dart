import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWidget extends StatefulWidget {
  final File file;

  const PlayerWidget({super.key, required this.file});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

// ==== [BAGIAN KODE UNTUK PRESENTASI MAHASISWA 3] ====
// Ini adalah logika pemutaran media menggunakan paket video_player
class _PlayerWidgetState extends State<PlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  // Jika pengguna memilih file lain sementara video sedang diputar, 
  // kita perlu memuat ulang controller dengan file baru.
  @override
  void didUpdateWidget(PlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _controller.dispose(); // Hancurkan controller lama
      _initController();     // Inisialisasi controller baru
    }
  }

  // Logika inisialisasi VideoPlayerController
  void _initController() {
    _isError = false;
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        // Jika inisialisasi sukses, perbarui state & mulai memutar
        setState(() {});
        _controller.play(); 
      }).catchError((error) {
        // Jika format tidak didukung atau terjadi kesalahan
        setState(() {
          _isError = true;
        });
      });
  }

  // Penting untuk membersihkan memori (mencegah memory leak)
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Penanganan Error
    if (_isError) {
      return const Center(
        child: Text(
          'Gagal memuat. Format media mungkin tidak didukung.',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // Indikator Loading saat media sedang diinisialisasi
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tampilan Player Utama
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mengatur rasio aspek agar video tidak teregang
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        const SizedBox(height: 16),
        
        // Indikator Progress (Garis Waktu Media)
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true, // Memungkinkan pengguna menarik slider
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          colors: VideoProgressColors(
            playedColor: Theme.of(context).colorScheme.primary,
            bufferedColor: Colors.grey,
          ),
        ),
        
        // Tombol Play / Pause
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              ),
              iconSize: 64,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                // Logika toggle pemutaran
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
// =======================================================
