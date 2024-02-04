import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui/colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../cubit/map_cubit.dart';
import '../widgets/map_panel.dart';

@RoutePage()
class MapView extends StatelessWidget implements AutoRouteWrapper {
  const MapView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              title: const Text('Znajdź salę'),
            ),
            body: switch (state) {
              final MapLoaded _ => MapPanel(building: state.building),
              final MapLoading _ =>
                const Center(child: CircularProgressIndicator()),
              final MapError _ => const Center(
                  child: Text(
                    'Ups! Coś poszło nie tak!',
                    style: TextStyle(
                      color: AppColors.secondary400,
                      fontSize: 24,
                    ),
                  ),
                ),
            },
          ),
        );
      },
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(
        mapRepository: context.read(),
        beaconUseCase: context.read(),
      )..loadMap(),
      child: this,
    );
  }
}
