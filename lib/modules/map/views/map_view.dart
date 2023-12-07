import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/map_panel.dart';

@RoutePage()
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapPanel(),
    );
  }
}
