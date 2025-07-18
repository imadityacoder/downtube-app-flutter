import 'package:downtube/core/constants.dart';
import 'package:downtube/views/widgets/downtube_appbar.dart';

import 'package:downtube/views/widgets/downtube_navbar.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: DowntubeNavbar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface.withValues(alpha: 0.6),
                AppColors.surface.withValues(alpha: 0.7),
                AppColors.surface.withValues(alpha: 0.8),
                AppColors.surface,
                AppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.topCenter,
          child: DowntubeAppbar(),
        ),
      ),
    );
  }
}
