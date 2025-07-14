import 'package:downtube_app/services/youtube_suggestion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final suggestionProvider =
    StateNotifierProvider<SuggestionViewModel, List<String>>(
  (ref) => SuggestionViewModel(),
);

class SuggestionViewModel extends StateNotifier<List<String>> {
  SuggestionViewModel() : super([]);
  final _service = YouTubeSuggestionService();

  Future<void> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      state = [];
      return;
    }

    final suggestions = await _service.fetchSuggestions(query);
    state = suggestions;
  }
}
