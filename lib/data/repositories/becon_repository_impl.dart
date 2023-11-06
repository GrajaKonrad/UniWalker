import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_walker/domain/entities/device.dart';
import 'package:uni_walker/domain/repositories/becon_repository.dart';
import 'package:uni_walker/logger.dart';

class BeconRepositoryImpl implements BeconRepository {
  BeconRepositoryImpl()
      : _deviceStreamController = BehaviorSubject<List<Device>>.seeded([]);

  late final BehaviorSubject<List<Device>> _deviceStreamController;
  StreamSubscription<List<ScanResult>>? _streamSubscription;

  @override
  ValueStream<List<Device>> get deviceStream => _deviceStreamController.stream;

  @override
  Future<void> initi() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);

    // check if bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      Logger.error("Bluetooth not supported by this device");
      return;
    }
  }

  @override
  Future<void> startScan() async {
    // return if already scanning
    if (FlutterBluePlus.isScanningNow) {
      return;
    }

    // start scanning
    await FlutterBluePlus.startScan();
    _streamSubscription?.cancel();
    _streamSubscription = FlutterBluePlus.scanResults.listen(
      _deviceCallbeck,
      onDone: () => _deviceCallbeck([]),
    );
  }

  @override
  Future<void> stopScan() async {
    // return if not scanning
    if (!FlutterBluePlus.isScanningNow) {
      return;
    }

    // stop scanning
    _streamSubscription?.cancel();
    await FlutterBluePlus.stopScan();
  }

  void _deviceCallbeck(List<ScanResult> results) {
    _deviceStreamController.add(
      results
          .map(
            (e) => Device(
              id: e.device.remoteId.str,
              name: e.advertisementData.localName,
              rssi: e.rssi,
            ),
          )
          .toList(),
    );
  }
}
