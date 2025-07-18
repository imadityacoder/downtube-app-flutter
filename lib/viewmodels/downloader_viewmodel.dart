import 'package:downtube/models/video_model.dart';
import 'package:downtube/services/youtube_download_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloaderViewModel extends StateNotifier<List<DownloadItem>> {
  DownloaderViewModel() : super([]);

  final YoutubeDownloadService _service = YoutubeDownloadService();

  Future<void> download({
    required String videoId,
    required String title,
    required String thumbnailUrl,
    required String? format,
    required void Function(double)? onProgress,
  }) async {
    if (format == null) return;

    int? quality;
    if (format.startsWith("video_")) {
      quality = int.tryParse(format.split("_").last);
    }

    final downloadItem = DownloadItem(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      quality: quality ?? 720,
    );

    state = [...state, downloadItem];

    try {
      if (format.startsWith("audio_")) {
        await _service.downloadAudioOnly(
          videoId,
          onProgress: (p) => updateProgress(videoId, p),
        );
      } else {
        await _service.downloadAndMerge(
          videoId,
          quality: quality ?? 720,
          onProgress: (p) => updateProgress(videoId, p),
        );
      }
      complete(videoId);
    } catch (e) {
      setError(videoId);
      rethrow;
    }
  }

  void updateProgress(String videoId, double progress) {
    state = [
      for (final d in state)
        if (d.videoId == videoId) d.copyWith(progress: progress) else d,
    ];
  }

  void complete(String videoId) {
    updateProgress(videoId, 1.0);
  }

  void setError(String videoId) {
    state = [
      for (final d in state)
        if (d.videoId == videoId) d.copyWith(error: true) else d,
    ];
  }
}

final downloadListProvider =
    StateNotifierProvider<DownloaderViewModel, List<DownloadItem>>((ref) {
  return DownloaderViewModel();
});
