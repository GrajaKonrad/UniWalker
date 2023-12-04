import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uni_walker/domain/entities/entities.dart';
import 'package:uni_walker/domain/use_cases/beacon_use_case.dart';

part 'device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit({
    required BeaconUseCase beconUseCase,
  })  : _beconUseCase = beconUseCase,
        super(const DeviceListLoadingState());

  final BeaconUseCase _beconUseCase;
  StreamSubscription<List<Device>>? _subscription;

  Future<void> init() async {
    _subscription?.cancel();
    _subscription = _beconUseCase.deviceStream.listen(_onData);
    await _beconUseCase.startScan();
  }

  @override
  Future<void> close() async {
    _subscription?.cancel();
    _beconUseCase.stopScan();
    await super.close();
  }

  void _onData(List<Device> devices) {
    emit(DeviceListLoadedState(devices: devices));
    _beconUseCase.deviceLocation();
  }
}
