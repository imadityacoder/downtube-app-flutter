import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeSuggestionService {
  Future<List<String>> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=$query',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data[1]);
      } catch (e) {
        print("❌ Failed to parse suggestion JSON: $e");
        return [];
      }
    } else {
      throw Exception('❌ Suggestion API failed with status ${response.statusCode}');
    }
  }
}
