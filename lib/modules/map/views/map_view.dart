import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';
import '../widgets/map_panel.dart';

@RoutePage()
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: const Text('Mapa'),
        ),
        body: const MapPanel(),
      ),
    );
  }
}
