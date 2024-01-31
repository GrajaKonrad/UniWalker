import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../domain/entities/device.dart';
import '../../domain/repositories/beacon_repository.dart';

class BeaconRepositoryMock implements BeconRepository {
  BeaconRepositoryMock()
      : _deviceStreamController = BehaviorSubject<List<Device>>.seeded([
          const Device(id: '123456789', name: 'urzadzenie', rssi: -100),
          const Device(id: '000000000', name: 'test', rssi: -20),
          const Device(id: '236754921', name: 'bluetooth', rssi: -52),
        ]);

  late final BehaviorSubject<List<Device>> _deviceStreamController;

  @override
  ValueStream<List<Device>> get deviceStream => _deviceStreamController.stream;

  @override
  Future<void> initi() async {}

  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}

  @override
  (double, double, int, double, bool) deviceLocation() {
    return (-16908.1087, -9686.3175, 0, 1.0, false);
  }
}
