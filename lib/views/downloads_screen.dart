import 'package:downtube/viewmodels/downloader_viewmodel.dart';
import 'package:downtube/views/widgets/downtube_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadListProvider);

    return Scaffold(
      bottomNavigationBar: DowntubeNavbar(),
      appBar: AppBar(title: const Text('Downloads'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final item = downloads[index];

                return ListTile(
                  title: Text(item.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.error
                              ? Colors.red
                              : (item.completed ? Colors.green : Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.error
                            ? 'Error'
                            : item.completed
                            ? 'Completed'
                            : '${(item.progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: item.completed
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : item.error
                      ? const Icon(Icons.error, color: Colors.red)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
