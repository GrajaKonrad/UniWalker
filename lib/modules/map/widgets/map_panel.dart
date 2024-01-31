import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/map/room.dart';
import '../../../domain/repositories/map_repository.dart';
import '../../../logger.dart';
import '../../../ui/colors.dart';
import '../cubit/map_cubit.dart';
import 'map_widget.dart';

class MapPanel extends StatelessWidget {
  const MapPanel({
    required this.floors,
    super.key,
  });

  final List<Floor> floors;

  @override
  Widget build(BuildContext context) {
    final options = floors.map((e) => e.rooms).expand((e) => e);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButton<Room?>(
            isExpanded: true,
            selectedItemBuilder: (_) => options
                .map(
                  (e) => Text(
                    e.name,
                    style: const TextStyle(color: AppColors.grayscale100),
                  ),
                )
                .toList(),
            items: options
                .map(
                  (e) => DropdownMenuItem<Room?>(
                    value: e,
                    child: Text(
                      e.name,
                      style: const TextStyle(color: AppColors.grayscale100),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              context.read<MapCubit>().findPath(to: value);
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: context.read<MapRepository>().getMap(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Logger.success('done');
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return MapWidget(
                      mapLayers: snapshot.data!,
                      constraints: constraints,
                    );
                  },
                );
              }

              if (snapshot.hasError) {
                Logger.error(snapshot.error);
                return const Center(
                  child: Text('Ups! Coś poszło nie tak!'),
                );
              }

              Logger.warning('loading');
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}
