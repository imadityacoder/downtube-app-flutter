import 'package:flutter/material.dart';

class DownloadBottomSheet extends StatefulWidget {
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
  State<DownloadBottomSheet> createState() => _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends State<DownloadBottomSheet> {
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

  // final downloader = YoutubeDownloadService();

  _download() async {
    // if (_selectedFormat == null) return;

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (_) => const Center(child: CircularProgressIndicator()),
    // );

    // try {
    //   final path = await downloader.download(widget.videoId, _selectedFormat!);
    //   Navigator.pop(context); // Close loading dialog
    //   Navigator.pop(context); // Close bottom sheet

    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Downloaded to: $path')));
    // } catch (e) {
    //   Navigator.pop(context); // Close loading dialog
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Error: $e')));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar drag handle
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

          // Thumbnail + Title
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.thumbnailUrl,
                  width: 140,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 160,
                    height: 100,
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Options List
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Audio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                ..._audioOptions.map(
                  (option) => RadioListTile<String>(
                    value: option["value"]!,
                    groupValue: _selectedFormat,
                    onChanged: (val) {
                      setState(() => _selectedFormat = val);
                    },
                    title: Text(option["label"]!),
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Video',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                ..._videoOptions.map(
                  (option) => RadioListTile<String>(
                    value: option["value"]!,
                    groupValue: _selectedFormat,
                    onChanged: (val) {
                      setState(() => _selectedFormat = val);
                    },
                    title: Text(option["label"]!),
                  ),
                ),
              ],
            ),
          ),

          // Download Button
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
            onPressed: _selectedFormat == null ? null : _download,
            icon: const Icon(Icons.download_rounded),
            label: const Text("Download"),
          ),
        ],
      ),
    );
  }
}
