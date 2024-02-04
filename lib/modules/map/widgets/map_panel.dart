import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/entities.dart';
import '../../../ui/colors.dart';
import '../cubit/map_cubit.dart';
import 'map_widget.dart';

class MapPanel extends StatefulWidget {
  const MapPanel({
    required this.building,
    super.key,
  });

  final Building building;

  @override
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  var _floorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final options = widget.building.rooms.sorted(
      (a, b) => a.name.compareTo(b.name),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownMenu(
            menuHeight: 500,
            menuStyle: const MenuStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(AppColors.grayscale500),
            ),
            width: 240,
            label: const Text(
              'Dokąd zmierzasz?',
              style: TextStyle(color: AppColors.grayscale100),
            ),
            textStyle: const TextStyle(color: AppColors.white),
            dropdownMenuEntries: options
                .map(
                  (e) => DropdownMenuEntry(
                    value: e,
                    label: e.name,
                    style: MenuItemButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.grayscale500,
                    ),
                  ),
                )
                .toList(),
            onSelected: (value) {
              context.read<MapCubit>().findPath(to: value);
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<MapCubit, MapState>(
            builder: (context, state) => switch (state) {
              final MapLoading _ => const Center(
                  child: CircularProgressIndicator(),
                ),
              final MapError _ => const Center(
                  child: Text('Ups! Coś poszło nie tak!'),
                ),
              final MapLoaded _ => LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        MapWidget(
                          floor: state.building.floors[_floorIndex],
                          constraints: constraints,
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Material(
                                  color: _floorIndex ==
                                          widget.building.floors.length - 1
                                      ? AppColors.grayscale400
                                      : AppColors.primary600,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _floorIndex = min(
                                          _floorIndex + 1,
                                          widget.building.floors.length - 1,
                                        );
                                      });
                                    },
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.add,
                                        color: _floorIndex ==
                                                widget.building.floors.length -
                                                    1
                                            ? AppColors.grayscale200
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: Text(
                                      state.building.floors[_floorIndex].level
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Material(
                                  color: _floorIndex == 0
                                      ? AppColors.grayscale400
                                      : AppColors.primary600,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _floorIndex = max(_floorIndex - 1, 0);
                                      });
                                    },
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.remove,
                                        color: _floorIndex == 0
                                            ? AppColors.grayscale200
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            },
          ),
        ),
      ],
    );
  }
}
