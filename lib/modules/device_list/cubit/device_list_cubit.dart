import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/entities.dart';
import '../../../domain/use_cases/beacon_use_case.dart';

part 'device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit({
    required BeconUseCase beconUseCase,
  })  : _beconUseCase = beconUseCase,
        super(const DeviceListLoadingState());

  final BeconUseCase _beconUseCase;
  StreamSubscription<List<Device>>? _subscription;

  Future<void> init() async {
    await _subscription?.cancel();
    _subscription = _beconUseCase.deviceStream.listen(_onData);
    await _beconUseCase.startScan();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _beconUseCase.stopScan();
    await super.close();
  }

  void _onData(List<Device> devices) {
    emit(DeviceListLoadedState(devices: devices));
  }
}
