import 'package:downtube/views/downloads_screen.dart';
import 'package:downtube/views/home_screen.dart';
import 'package:downtube/views/search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    debugLogDiagnostics: true,
  );
});
