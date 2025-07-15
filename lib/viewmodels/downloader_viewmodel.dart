import 'package:downtube_app/models/video_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadListNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadListNotifier() : super([]);

  void addDownload(DownloadItem item) {
    if (!state.any((e) => e.videoId == item.videoId)) {
      state = [...state, item];
    }
  }

  void updateProgress(String videoId, double progress) {
    state = [
      for (final item in state)
        if (item.videoId == videoId)
          item.copyWith(progress: progress)
        else
          item,
    ];
  }

  void complete(String videoId) {
    state = [
      for (final item in state)
        if (item.videoId == videoId)
          item.copyWith(progress: 1.0, completed: true)
        else
          item,
    ];
  }

  void setError(String videoId) {
    state = [
      for (final item in state)
        if (item.videoId == videoId)
          item.copyWith(error: true)
        else
          item,
    ];
  }

  void remove(String videoId) {
    state = state.where((item) => item.videoId != videoId).toList();
  }

  void clear() => state = [];
}

final downloadListProvider =
    StateNotifierProvider<DownloadListNotifier, List<DownloadItem>>(
  (ref) => DownloadListNotifier(),
);

