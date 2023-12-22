import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../../../router/app_router.dart';
import '../widgets/button.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: UnityWidget(
          onUnityCreated: (_) => {},
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
