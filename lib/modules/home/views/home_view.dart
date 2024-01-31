import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../router/app_router.dart';
import '../../../ui/colors.dart';
import '../widgets/home_button.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_walk_outlined,
                size: 96,
                color: AppColors.primary600,
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Uni',
                      style: TextStyle(
                        color: AppColors.primary600,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    TextSpan(
                      text: 'Walker',
                      style: TextStyle(
                        color: AppColors.secondary600,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              HomeButton(
                text: 'Znajdź salę',
                icon: const Icon(
                  Icons.map_outlined,
                  color: AppColors.secondary600,
                ),
                onTap: () => context.navigateTo(const MapRoute()),
              ),
              const SizedBox(height: 16),
              if (kDebugMode)
                HomeButton(
                  text: 'Beacony',
                  icon: const Icon(
                    Icons.bluetooth,
                    color: AppColors.secondary600,
                  ),
                  onTap: () => context.navigateTo(const DeviceListRoute()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
