class DownloadItem {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final int quality;
  double progress;
  bool completed;
  bool error;

  DownloadItem({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.quality,
    this.progress = 0.0,
    this.completed = false,
    this.error = false,
  });

  DownloadItem copyWith({
    double? progress,
    bool? completed,
    bool? error,
  }) {
    return DownloadItem(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      quality: quality,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      error: error ?? this.error,
    );
  }
}
