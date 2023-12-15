import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/custom_app_bar.dart';
import '../cubit/device_list_cubit.dart';
import '../widgets/device_info_tile.dart';

@RoutePage()
class DeviceListView extends StatelessWidget implements AutoRouteWrapper {
  const DeviceListView({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceListCubit(
        beconUseCase: context.read(),
      )..init(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: const Text('Lista urządzeń (debug)'),
        ),
        body: BlocBuilder<DeviceListCubit, DeviceListState>(
          builder: (context, state) {
            return switch (state) {
              DeviceListLoadingState _ => const Center(
                  child: CircularProgressIndicator(),
                ),
              DeviceListLoadedState _ => ListView.builder(
                  itemBuilder: (context, index) =>
                      DeviceInfoTile(device: state.devices[index]),
                  itemCount: state.devices.length,
                ),
              DeviceListErrorState _ => const Center(
                  child: Text('Ups! Coś poszło nie tak!'),
                ),
            };
          },
        ),
      ),
    );
  }
}
