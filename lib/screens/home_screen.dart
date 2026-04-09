import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../widgets/player_widget.dart';
import 'auto_detect_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedFile;
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    // Mendengarkan intent ketika aplikasi berjalan di memori
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          _selectedFile = File(value.first.path);
        });
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // Menangkap intent media saat aplikasi pertama kali dibuka via intent
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          _selectedFile = File(value.first.path);
        });
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  // ==== [BAGIAN KODE UNTUK PRESENTASI MAHASISWA 2] ====
  // Fungsi ini bertugas membuka galeri/file manager untuk memilih file media
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.media, // Membatasi agar pengguna hanya bisa memilih media (video/audio)
    );

    if (result != null && result.files.single.path != null) {
      // Menyimpan file yang dipilih ke dalam state _selectedFile dan merefresh UI
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }
  // =======================================================

  // ==== [BAGIAN KODE UNTUK PRESENTASI MAHASISWA 1] ====
  // Membangun Antarmuka Pengguna (UI) Utama Aplikasi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Media Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jika belum ada file, tampilkan teks bimbingan
            if (_selectedFile == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Belum ada file media yang dipilih.\nSilakan tekan tombol di bawah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              // Jika ada file, tampilkan widget Player
              Expanded(
                child: PlayerWidget(file: _selectedFile!),
              ),
            
            // Tombol Pilih File
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Pilih File Media', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
            // Tombol Auto Detect Media
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AutoDetectScreen(
                        onMediaSelected: (file) {
                          setState(() {
                            _selectedFile = file;
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.library_music),
                label: const Text('Auto Detect Media / Lagu', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // =======================================================
}
