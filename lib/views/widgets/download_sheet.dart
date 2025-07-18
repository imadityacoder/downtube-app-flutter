import 'package:downtube/core/constants.dart';
import 'package:downtube/viewmodels/downloader_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DownloadBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final String videoId;
  final String thumbnailUrl;
  final String author;

  const DownloadBottomSheet({
    super.key,
    required this.title,
    required this.videoId,
    required this.thumbnailUrl,
    required this.author,
  });

  @override
  ConsumerState<DownloadBottomSheet> createState() =>
      _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends ConsumerState<DownloadBottomSheet> {
  String? _selectedFormat;

  final List<Map<String, String>> _audioOptions = [
    {"label": "Fast Audio", "value": "audio_fast"},
    {"label": "Classic MP3", "value": "audio_mp3"},
  ];

  final List<Map<String, String>> _videoOptions = [
    {"label": "Fast [360p]", "value": "video_360"},
    {"label": "High Quality [720p]", "value": "video_720"},
    {"label": "Full HD [1080p]", "value": "video_1080"},
  ];

  Future<void> _download(WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (_selectedFormat == null) return;

    final format = _selectedFormat!;
    int? quality;

    // Extract quality if it's a video format
    if (format.startsWith("video_")) {
      quality = int.tryParse(format.split("_").last);
    }
    context.pop();
    context.pop();

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Started Downloading : ${widget.title}"),
          backgroundColor: AppColors.accent,
        ),
      );

      await ref
          .read(downloadListProvider.notifier)
          .download(
            videoId: widget.videoId,
            title: widget.title,
            thumbnailUrl: widget.thumbnailUrl,
            format: format,
            onProgress: (progress) {
              if (mounted) {
                ref
                    .read(downloadListProvider.notifier)
                    .updateProgress(widget.videoId, progress);
              }
            },
          );

      ref.read(downloadListProvider.notifier).complete(widget.videoId);
      // Optional: show success UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Download Completed : ${widget.title}"),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (e) {
      ref.read(downloadListProvider.notifier).setError(widget.videoId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong! while downloading ${widget.title}",
          ),
          backgroundColor: AppColors.error,
        ),
      );
      print("Download error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.thumbnailUrl,
                  width: 140,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 140,
                    height: 80,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Download as',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 10),
                const Text(
                  ' Audio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                ..._audioOptions.map(
                  (option) => RadioListTile<String>(
                    value: option["value"]!,
                    groupValue: _selectedFormat,
                    onChanged: (val) {
                      setState(() => _selectedFormat = val);
                    },
                    title: Text(
                      option["label"]!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),

                const Text(
                  ' Video',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                ..._videoOptions.map(
                  (option) => RadioListTile<String>(
                    value: option["value"]!,
                    groupValue: _selectedFormat,
                    onChanged: (val) {
                      setState(() => _selectedFormat = val);
                    },
                    title: Text(
                      option["label"]!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedFormat == null
                  ? Colors.grey[400]
                  : Colors.green[700],
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _selectedFormat == null ? null : () => _download(ref),
            icon: const Icon(Icons.download_rounded),
            label: const Text("Download"),
          ),
        ],
      ),
    );
  }
}
