import 'dart:async';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:csv/csv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_walker/domain/entities/device.dart';
import 'package:uni_walker/domain/repositories/beacon_repository.dart';
import 'package:uni_walker/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show File, Platform;

class BeaconRepositoryImpl implements BeconRepository {
  BeaconRepositoryImpl()
      : _deviceStreamController = BehaviorSubject<List<Device>>.seeded([]);

  late final BehaviorSubject<List<Device>> _deviceStreamController;
  late final Map<dynamic, Map<dynamic, dynamic>> _knownBeacons;
  late Map<String, List<int>> _closestRssiValues;
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
      print('Error with beacon file handling: $e');
    }
    _knownBeacons = {};
    for(var i = 1; i < csvOutput.length; i++){
      var map = {};
      for(var j = 1; j < csvOutput[0].length; j++)
        {
          map[csvOutput[0][j]] = csvOutput[i][j];
        }
      _knownBeacons[csvOutput[i][0]] = map;
    }
  }

  @override
  Future<void> startScan() async {
    // return if already scanning
    if (FlutterBluePlus.isScanningNow) {
      return;
    }
    _closestRssiValues = {};
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
      _deviceCallback,
      onDone: () => _deviceCallback([]),
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

  void _deviceCallback(List<ScanResult> results) {
      for (var propagator in results) {
        if(_knownBeacons.containsKey(propagator.device.remoteId.str)){
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
  }

  num _calculateMetersFromRssi(double measuredRssi, int meterRssi, {int n = 3}) {
    num power = (meterRssi - measuredRssi) / (10 * n);
    return pow(10, power);
  }

  @override
  (double, double, int) deviceLocation({double mapScale = 1}) {
    List<Device> foundBeacons = _deviceStreamController.value;
    foundBeacons.sort((rssia, rssib) => rssia.rssi < rssib.rssi ? 1 : -1 );

    // remembers latest 3 measured signal strength to smooth out  outliers - in testing phase
    for(int i = 0; i<foundBeacons.length && i<6 ; i++){
      if(_closestRssiValues.containsKey(foundBeacons[i].id)){
        if(_closestRssiValues[foundBeacons[i].id]!.length >= 3){
          _closestRssiValues[foundBeacons[i].id]?.removeAt(0);
        }
        _closestRssiValues[foundBeacons[i].id]?.add(foundBeacons[i].rssi);
      }else{
        _closestRssiValues[foundBeacons[i].id] = [foundBeacons[i].rssi];
      }
    }
    print("sssssssssssssssssss ${foundBeacons.length}");
    //calculate device position
    if (foundBeacons.length >= 3){
      for(int i = 0; i < 3; i++) {
          var mean = _closestRssiValues[foundBeacons[i].id]!.reduce((a, b) => a + b) / _closestRssiValues[foundBeacons[i].id]!.length;
          var distanceMeters = _calculateMetersFromRssi(mean, _knownBeacons[foundBeacons[i].id]?['RSSI_at_1m'] as int);
          print(distanceMeters);
        }
    }

    //X value, Y value, Floor number (from 0)
    return (0, 0 ,0);
  }
}
