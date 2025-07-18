import 'package:downtube/viewmodels/search_viewmodel.dart';
import 'package:downtube/viewmodels/suggestion_viewmodel.dart';
import 'package:downtube/views/widgets/download_sheet.dart';
import 'package:downtube/views/widgets/downtube_navbar.dart';
import 'package:downtube/views/widgets/searchbar_widget.dart';
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

  String? extractVideoId(String input) {
    final Uri? uri = Uri.tryParse(input.trim());

    if (uri == null) return null;

    // Case: https://www.youtube.com/watch?v=VIDEO_ID
    if ((uri.host.contains('youtube.com') ||
            uri.host.contains('www.youtube.com')) &&
        uri.queryParameters['v'] != null) {
      return uri.queryParameters['v'];
    }

    // Case: https://youtu.be/VIDEO_ID
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first.split('?').first
          : null;
    }

    // Fallback for direct ID (if user enters just ID)
    final reg = RegExp(r'^[\w-]{11}$');
    if (reg.hasMatch(input)) return input;

    return null;
  }

  void _onSearchSubmitted(String query) async {
    final videoId = extractVideoId(query.trim());
    final yt = YoutubeExplode();

    if (videoId != null) {
      // It's a YouTube link or ID
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final video = await yt.videos.get(videoId);

        if (!context.mounted) return;
        Navigator.pop(context); // Close loading spinner

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
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading spinner
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Invalid video link!")));
        }
      } finally {
        yt.close();
      }
    } else {
      // Not a link, do normal search
      setState(() => showSuggestions = false);
      ref.read(searchProvider.notifier).search(query);
    }
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
      bottomNavigationBar: DowntubeNavbar(),
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
                    radius: 12,
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
                                      fontSize: 15,
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
