import 'dart:io';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

typedef ProgressCallback = void Function(double progress);

class YoutubeDownloadService {
  final YoutubeExplode _yt = YoutubeExplode();

  final Directory baseDir = Directory('/storage/emulated/0/Download/Downtube');

  Future<Directory> _getVideoDir() async {
    final videoDir = Directory(p.join(baseDir.path, 'media/Downtube Videos'));

    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }

    return videoDir;
  }

  Future<Directory> _getAudioDir() async {
    final audioDir = Directory(p.join(baseDir.path, 'media'));

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    return audioDir;
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) throw Exception("Storage permission denied");
  }

  Future<String> downloadAudioOnly(
    String videoId, {
    ProgressCallback? onProgress,
  }) async {
    await _requestPermissions();

    final video = await _yt.videos.get(videoId);
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);

    // Use highest bitrate audio stream (usually .webm or .m4a)
    final audio = manifest.audioOnly.withHighestBitrate();

    final audioDir = await _getAudioDir();
    final ext = audio.container.name; // Use correct extension (.webm or .m4a)
    final fileName = _sanitizeFileName('${video.title}.$ext');
    final file = File(p.join(audioDir.path, fileName));

    final stream = _yt.videos.streamsClient.get(audio);
    final total = audio.size.totalBytes;
    int received = 0;

    final sink = file.openWrite();
    await for (final chunk in stream) {
      received += chunk.length;
      sink.add(chunk);
      if (onProgress != null) {
        onProgress(received / total);
      }
    }

    await sink.flush();
    await sink.close();

    return file.path;
  }

  final platform = MethodChannel("downtube/merge");
  Future<String> downloadAndMerge(
    String videoId, {
    int quality = 720,
    ProgressCallback? onProgress,
  }) async {
    final video = await _yt.videos.get(videoId);
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);

    final videoOnlyList = manifest.videoOnly.toList();
    final videoStreamInfo = videoOnlyList.firstWhere(
      (v) => v.videoResolution.height == quality,
      orElse: () {
        videoOnlyList.sort(
          (a, b) =>
              b.videoResolution.height.compareTo(a.videoResolution.height),
        );
        return videoOnlyList.first;
      },
    );

    final audioStreamInfo = manifest.audioOnly.firstWhere(
      (a) => a.container.name.contains('mp4'),
      orElse: () => throw Exception('No supported audio format found'),
    );

    final appDir = await _getVideoDir();
    final safeTitle = _sanitizeFileName('${video.title} [$quality p]');
    final videoPath = p.join(appDir.path, '$safeTitle.video.mp4');
    final audioPath = p.join(appDir.path, '$safeTitle.audio.mp4');
    final outputPath = p.join(appDir.path, '$safeTitle.mp4');

    // Download video with progress
    final videoStream = _yt.videos.streamsClient.get(videoStreamInfo);
    final videoFile = File(videoPath).openWrite();
    final videoTotalBytes = videoStreamInfo.size.totalBytes;
    int videoDownloaded = 0;

    await for (final data in videoStream) {
      videoFile.add(data);
      videoDownloaded += data.length;
      onProgress?.call(videoDownloaded / videoTotalBytes * 0.4); // 0–0.4
    }
    await videoFile.close();

    // Download audio with progress
    final audioStream = _yt.videos.streamsClient.get(audioStreamInfo);
    final audioFile = File(audioPath).openWrite();
    final audioTotalBytes = audioStreamInfo.size.totalBytes;
    int audioDownloaded = 0;

    await for (final data in audioStream) {
      audioFile.add(data);
      audioDownloaded += data.length;
      onProgress?.call(
        0.4 + (audioDownloaded / audioTotalBytes * 0.4),
      ); // 0.4–0.8
    }
    await audioFile.close();

    // Merge (native)
    onProgress?.call(0.9); // Optional bump before native merge
    final result = await platform.invokeMethod('mergeVideoAndAudio', {
      'videoPath': videoPath,
      'audioPath': audioPath,
      'outputPath': outputPath,
    });

    if (result != true) throw Exception('Native muxing failed');
    onProgress?.call(1.0);

    File(videoPath).deleteSync();
    File(audioPath).deleteSync();

    return outputPath;
  }

  void dispose() => _yt.close();

  String _sanitizeFileName(String title) {
    return title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();
  }
}
