import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/entities.dart';
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
      final building = await _mapRepository.getMap();
      emit(MapLoaded(building: building, path: null));
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
    required Room? to,
  }) async {
    final state = this.state;
    if (state is! MapLoaded) {
      return;
    }

    if (to == null) {
      emit(MapLoaded(building: state.building, path: null));
      return;
    }

    final location = _beaconUseCase.deviceLocation();

    final level = state.building.floors
        .firstWhereOrNull((e) => e.rooms.contains(to))
        ?.level;

    if (level == null) {
      return;
    }

    final path = await _mapRepository.findPath(
      building: state.building,
      start: Position(x: location.$1, y: location.$2, level: location.$3),
      end: Position(x: to.x, y: to.y, level: level),
    );

    emit(MapLoaded(building: state.building, path: path));
  }
}
