import 'package:downtube_app/core/constants.dart';
import 'package:downtube_app/views/widgets/downtube_appbar.dart';

import 'package:downtube_app/views/widgets/downtube_intro.dart';
import 'package:downtube_app/views/widgets/downtube_navbar.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: DowntubeNavbar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface.withValues(alpha: 0.8),
              AppColors.surface.withValues(alpha: 0.5),
              AppColors.surface.withValues(alpha: 0.8),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DowntubeAppbar(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height:
                    MediaQuery.of(context).size.height -
                    280, // Adjust for app bar height
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: Offset(2, 4), // Shadow position
                    ),
                  ],
                ),
                child: HomeIntroSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 