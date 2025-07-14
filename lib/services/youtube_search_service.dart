import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeSearchResult {
  final String title;
  final String videoId;
  final String thumbnailUrl;
  final String author;
  final Duration? duration;
  

  YouTubeSearchResult({
    required this.title,
    required this.videoId,
    required this.thumbnailUrl,
    required this.author,
    required this.duration,
  });
}

class YouTubeSearchService {
  final yt = YoutubeExplode();

  Future<List<YouTubeSearchResult>> search(String query) async {
    final searchResults = await yt.search.search(query);

    return searchResults
        .whereType<Video>()
        .map((video) => YouTubeSearchResult(
              title: video.title,
              videoId: video.id.value,
              thumbnailUrl: video.thumbnails.mediumResUrl,
              author: video.author,
              duration: video.duration,
            ))
        .toList();
  }
}
