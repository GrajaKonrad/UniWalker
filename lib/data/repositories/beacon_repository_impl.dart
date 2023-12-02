import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:csv/csv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_walker/domain/entities/device.dart';
import 'package:uni_walker/domain/repositories/beacon_repository.dart';
import 'package:uni_walker/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show File, Platform;

class BeconRepositoryImpl implements BeconRepository {
  BeconRepositoryImpl()
      : _deviceStreamController = BehaviorSubject<List<Device>>.seeded([]);

  late final BehaviorSubject<List<Device>> _deviceStreamController;
  late final List<Map> _knownBecons;
  StreamSubscription<List<ScanResult>>? _streamSubscription;


  @override
  ValueStream<List<Device>> get deviceStream => _deviceStreamController.stream;

  @override
  Future<void> initi() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

    // check if bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      Logger.error("Bluetooth not supported by this device");
      return;
    }

    await _getBeaconFromCSV();
  }

  Future<void> _getBeaconFromCSV() async{

    var csvOutput;
    try {
      final input = await rootBundle.loadString('assets/beacons.csv');
      csvOutput = const CsvToListConverter(
          fieldDelimiter: ';'
      ).convert(input);
    }
    catch(e){
      print('Error with becon file handling: $e');
    }
    _knownBecons = <Map>[];
    for(var i = 1; i < csvOutput.length; i++){
      var map = {};
      for(var j = 0; j < csvOutput[0].length; j++)
        {
          map[csvOutput[0][j]] = csvOutput[i][j];
        }
      _knownBecons.add(map);
    }
  }

  @override
  Future<void> startScan() async {
    // return if already scanning
    if (FlutterBluePlus.isScanningNow) {
      return;
    }

    // make sure bluetooth is enabled
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        _runScan();
      } else {
        stopScan();
        //TODO: to be replaced by popup window
        print("Bluetooth has been stopped");
      }
    });


  }

  Future<void> _runScan() async {
    // wait for necessary actions
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    await FlutterBluePlus.startScan();
    // start scanning
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
    _knownBecons.forEach((beacon) {
      results.forEach((propagator) {
        if(propagator.device.remoteId.str == beacon['Device_id']){
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
      });
    });
  }
}