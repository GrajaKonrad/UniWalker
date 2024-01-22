import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/map_repository.dart';
import '../../../logger.dart';
import 'map_widget.dart';

class MapPanel extends StatelessWidget {
  const MapPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(labelText: 'Znajdź salę'),
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
