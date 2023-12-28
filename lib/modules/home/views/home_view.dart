import 'package:auto_route/auto_route.dart';
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
              HomeButton(
                text: 'AR',
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.secondary600,
                ),
                onTap: () => context.navigateTo(const CameraRoute()),
              ),
            ],
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: SafeArea(
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Stack(
    //             children: [
    //               SizedBox(
    //                 child: Icon(
    //                   Icons.map_outlined,
    //                   size: 196,
    //                   color: Colors.deepOrangeAccent.shade100,
    //                 ),
    //               ),
    //               const Positioned(
    //                 top: 75,
    //                 child: Text(
    //                   'UniWalker',
    //                   style: TextStyle(
    //                     color: Colors.deepPurpleAccent,
    //                     fontSize: 40,
    //                     fontWeight: FontWeight.w600,
    //                     height: 1.25,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           const SizedBox(height: 64),
    //           HomeButton(
    //             text: 'AR',
    //             icon: const Icon(
    //               Icons.camera_alt_outlined,
    //               color: Colors.white,
    //             ),
    //             onTap: () => context.navigateTo(const CameraRoute()),
    //           ),
    //           const SizedBox(height: 16),
    //           HomeButton(
    //             text: 'Bluetooth',
    //             icon: const Icon(
    //               Icons.bluetooth,
    //               color: Colors.white,
    //             ),
    //             onTap: () => context.navigateTo(const DeviceListRoute()),
    //           ),
    //           const SizedBox(height: 16),
    //           HomeButton(
    //             text: 'Mapa',
    //             icon: const Icon(
    //               Icons.map_outlined,
    //               color: Colors.white,
    //             ),
    //             onTap: () => context.navigateTo(const MapRoute()),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
