import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AutoDetectScreen extends StatefulWidget {
  final Function(File) onMediaSelected;

  const AutoDetectScreen({super.key, required this.onMediaSelected});

  @override
  State<AutoDetectScreen> createState() => _AutoDetectScreenState();
}

class _AutoDetectScreenState extends State<AutoDetectScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool hasPermission = await _audioQuery.permissionsStatus();
    if (!hasPermission) {
      bool status = await _audioQuery.permissionsRequest();
      if (!status) {
        // Fallback for Android 13+ or other missing handled requests
        PermissionStatus permStatus = await Permission.audio.request();
        if (permStatus.isGranted) status = true;
      }
      setState(() {
        _hasPermission = status;
      });
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text('Auto Detect Media')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Aplikasi butuh izin untuk membaca media.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Minta Izin'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Perangkat'),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (item.hasError) {
            return Center(child: Text('Error: ${item.error}'));
          }
          if (item.data == null || item.data!.isEmpty) {
            return const Center(child: Text('Tidak ada media (lagu) ditemukan.'));
          }

          return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              final song = item.data![index];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(song.title),
                subtitle: Text(song.artist ?? 'Unknown Artist'),
                onTap: () {
                  // Berikan File kembali dan kembali ke layar sebelumnya
                  if (song.data != null) {
                    widget.onMediaSelected(File(song.data));
                    Navigator.pop(context);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
