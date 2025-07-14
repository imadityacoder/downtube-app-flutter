import 'package:downtube_app/viewmodels/navbar_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class DowntubeNavbar extends ConsumerWidget {
  const DowntubeNavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navbarIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(navbarIndexProvider.notifier).state = index;

        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/downloads');
            break;
          case 2:
            context.go('/settings');
            break;
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_outlined),
          activeIcon: Icon(Icons.download),
          label: 'Downloads',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
