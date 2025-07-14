import 'package:downtube_app/viewmodels/search_viewmodel.dart';
import 'package:downtube_app/viewmodels/suggestion_viewmodel.dart';
import 'package:downtube_app/views/widgets/download_sheet.dart';
import 'package:downtube_app/views/widgets/searchbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

  String? extractVideoId(String url) {
    final RegExp regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([^\s&]+)',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  void _onSearchSubmitted(String query) async {
    final videoId = extractVideoId(query.trim());

    if (videoId != null) {
      // It’s a YouTube URL → fetch video and open bottom sheet
      final yt = YoutubeExplode();
      try {
        final video = await yt.videos.get(videoId);
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DownloadBottomSheet(
              title: video.title,
              videoId: video.id.value,
              thumbnailUrl: video.thumbnails.highResUrl,
              author: video.author,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Invalid video link")));
        }
      } finally {
        yt.close();
      }
    } else {
      // Normal keyword search
      setState(() => showSuggestions = false);
      ref.read(searchProvider.notifier).search(query);
    }
    ;
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
              _onSearchSubmitted(query);
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
                  return InkWell(
                    child: Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              video.duration == null
                                                  ? "00:00"
                                                  : video.duration
                                                        .toString()
                                                        .split('.')[0],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              video.author,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.download_rounded),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) => DownloadBottomSheet(
                          title: video.title,
                          videoId: video.videoId,
                          thumbnailUrl: video.thumbnailUrl,
                          author: video.author,
                        ),
                      );
                    },
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
