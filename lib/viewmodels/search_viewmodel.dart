import 'package:downtube/services/youtube_search_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final searchProvider = StateNotifierProvider<SearchViewModel, AsyncValue<List<YouTubeSearchResult>>>(
  (ref) => SearchViewModel(),
);

class SearchViewModel extends StateNotifier<AsyncValue<List<YouTubeSearchResult>>> {
  SearchViewModel() : super(const AsyncValue.data([]));

  final _service = YouTubeSearchService();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final results = await _service.search(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      print("❌ Search error: $e");
      state = AsyncValue.error(e, st);
    }
  }
  void clear() {
  state = const AsyncValue.data([]);
}

}
