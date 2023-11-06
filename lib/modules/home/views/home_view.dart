import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:uni_walker/router/app_router.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'UniWalker',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 64),
              TextButton(
                onPressed: () => context.navigateTo(const CameraRoute()),
                child: const Text('Kamera'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.navigateTo(const DeviceListRoute()),
                child: const Text('Bluetooth'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
