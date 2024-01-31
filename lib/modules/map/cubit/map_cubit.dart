import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/entities/map/room.dart';
import '../../../domain/repositories/map_repository.dart';
import '../../../domain/use_cases/beacon_use_case.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit({
    required MapRepository mapRepository,
    required BeaconUseCase beaconUseCase,
  })  : _mapRepository = mapRepository,
        _beaconUseCase = beaconUseCase,
        super(const MapLoading());

  final MapRepository _mapRepository;
  final BeaconUseCase _beaconUseCase;

  Future<void> loadMap() async {
    try {
      await _beaconUseCase.startScan();
      final floors = await _mapRepository.getMap();
      emit(MapLoaded(floors: floors, path: null));
    } catch (_) {
      emit(const MapError());
    }
  }

  @override
  Future<void> close() async {
    await _beaconUseCase.stopScan();
    await super.close();
  }

  Future<void> findPath({
    required Room to,
  }) async {
    final state = this.state;
    if (state is! MapLoaded) {
      return;
    }

    final location = _beaconUseCase.deviceLocation();

    final path = await _mapRepository.findPath(
      layer: state.floors[0],
      start: Offset(location.$1, location.$2),
      end: Offset(to.x, to.y),
    );

    emit(MapLoaded(floors: state.floors, path: path));
  }
}
