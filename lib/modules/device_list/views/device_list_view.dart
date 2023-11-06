import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_walker/modules/device_list/cubit/device_list_cubit.dart';
import 'package:uni_walker/modules/device_list/widgets/device_info_tile.dart';

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
        appBar: AppBar(
          title: const Text("Lista urządzeń"),
          elevation: 0.5,
          shadowColor: Colors.black,
        ),
        body: BlocBuilder<DeviceListCubit, DeviceListState>(
          builder: (context, state) {
            return switch (state) {
              DeviceListLoadingState _ => const Center(
                  child: CircularProgressIndicator(),
                ),
              DeviceListLoadedState _ => Column(
                  children: state.devices
                      .map(
                        (e) => DeviceInfoTile(device: e),
                      )
                      .toList(),
                ),
              DeviceListErrorState _ => const Center(
                  child: Text("Ups! Coś poszło nie tak!"),
                ),
            };
          },
        ),
      ),
    );
  }
}
