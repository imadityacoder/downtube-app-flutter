import 'package:flutter/material.dart';

class HomeIntroSection extends StatelessWidget {
  const HomeIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Downtube 👋',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Downtube lets you download YouTube videos directly to your device in high quality — fast, easy, and distraction-free. Perfect for offline viewing, content saving, and clean archives.",
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "⚠️ Warning:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Downloading copyrighted videos without permission may violate YouTube’s terms of service. Use this app responsibly for educational, personal, or non-commercial purposes only.",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "📄 Disclaimer:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Downtube is an independent tool not affiliated with or endorsed by YouTube or Google. All video copyrights belong to their respective owners.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
