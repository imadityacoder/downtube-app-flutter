import 'package:downtube_app/viewmodels/search_viewmodel.dart';
import 'package:downtube_app/viewmodels/suggestion_viewmodel.dart';
import 'package:downtube_app/views/widgets/searchbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool showSuggestions = true;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = controller.text.trim();

    if (query.isEmpty) {
      setState(() => showSuggestions = true);
      ref.read(searchProvider.notifier).clear();
      return;
    }

    setState(() => showSuggestions = true);
    ref.read(searchProvider.notifier).clear();
    ref.read(suggestionProvider.notifier).getSuggestions(query);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(suggestionProvider);
    final results = ref
        .watch(searchProvider)
        .maybeWhen(data: (data) => data, orElse: () => []);

    return Scaffold(
      body: Column(
        children: [
          SearchBarWidget(
            controller: controller,
            onChanged: (query) {
              _onSearchChanged();
            },
            onSubmitted: (query) {
              setState(() => showSuggestions = false);
              ref.read(searchProvider.notifier).search(query);
            },
            onClear: () {
              controller.clear();
              setState(() => showSuggestions = true);
              ref.read(searchProvider.notifier).clear();
            },
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: showSuggestions ? suggestions.length : results.length,
              itemBuilder: (_, index) {
                if (showSuggestions) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.search_rounded),
                    title: Text(suggestion),
                    onTap: () {
                      controller.text = suggestion;
                      setState(() => showSuggestions = false);
                      ref.read(searchProvider.notifier).search(suggestion);
                    },
                  );
                } else {
                  final video = results[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            video.thumbnailUrl,
                            width: 160,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 150,
                                  height: 100,
                                  color: Colors.grey[300],
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.duration == null
                                              ? "00:00"
                                              : video.duration.toString().split(
                                                  '.',
                                                )[0],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          video.author,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // TODO: Open download UI
                                      },
                                      icon: const Icon(Icons.download_rounded),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
