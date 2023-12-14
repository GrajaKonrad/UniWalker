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

  //Location calculation variables
  late Map<String, List<int>> _closestRssiValues;
  bool _flagIntersectDown = false;
  bool _flagIntersectUp = false;


  num _calculateMetersFromRssi(double measuredRssi, num meterRssi, {int n = 3}) {
    num power = (meterRssi - measuredRssi) / (10 * n);
    return pow(10, power);
  }

  num _calculateRealDistance(String id, double mapScale, int n){
    var mean = _closestRssiValues[id]!.reduce((a, b) => a + b) / _closestRssiValues[id]!.length;
    var distanceMeters = _calculateMetersFromRssi(
        mean,
        _knownBeacons[id]?['RSSI_at_1m'] as num,
        n: n);
    distanceMeters *= mapScale;

    return distanceMeters;
  }

  List<num> _calculateCircleIntersection(num x1, num y1, num r1, num x2, num y2, num r2){
    double d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    //check id circles intersect with each other
    if(d > r1 + r2) {
      _flagIntersectUp = true;
      return [0.0, 0.0, 0.0, 0.0];
    }
    if(d < (r1 - r2).abs()){
      _flagIntersectDown = true;
      return [0.0, 0.0, 0.0, 0.0];
    }

    //continue calculating intersection points
    num l = (pow(r1, 2) - pow(r2, 2) + pow(d, 2)) / (2 * d);
    double h = sqrt(pow(r1, 2) - pow(l, 2));
    double xPart1 = (l / d) * (x2 - x1);
    double xPart2 = (h / d) * (y2 - y1) + x1;
    double yPart1 = (l / d) * (y2 - y1);
    double yPart2 = (h / d) * (x2 - x1) + y1;

    return [xPart1 + xPart2, yPart1 - yPart2, xPart1 - xPart2, yPart1 + yPart2];
  }


  @override
  (double, double, int) deviceLocation({double mapScale = 1, int defaultN = 3}) {
    //returns
    double userPosX = 0;
    double userPosY = 0;
    int userFloor = 0;

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

    //calculate device position
    List<num> realDistance = [];
    List<List<num>> intersectionPoints = [];
    for(int i = 0; i<foundBeacons.length && i < 3 ; i++) {
        num distanceMeters = _calculateRealDistance(foundBeacons[i].id, mapScale, defaultN);
        realDistance.add(distanceMeters);
    }
    //calculate circle intersection
    if (foundBeacons.length >= 3){
      for(int i = 0; i < 3; i++){
        _flagIntersectUp = false;
        _flagIntersectDown = false;
        int j = i + 1;
        if (j == 3) j = 0;
        num x1 = _knownBeacons[foundBeacons[i].id]?['Pos_x'] as num;
        num x2 = _knownBeacons[foundBeacons[j].id]?['Pos_x'] as num;
        num y1 = _knownBeacons[foundBeacons[i].id]?['Pos_y'] as num;
        num y2 = _knownBeacons[foundBeacons[j].id]?['Pos_y'] as num;

        print("Raw distance");
        print(realDistance);

        intersectionPoints.add(
            _calculateCircleIntersection(x1, y1, realDistance[i], x2, y2, realDistance[j]));
        int addToN = -1;
        while (_flagIntersectUp && defaultN  + addToN > 0){
          print("Step-up distance");
          _flagIntersectUp = false;
          num newDistance1 = _calculateRealDistance(foundBeacons[i].id, mapScale, defaultN + addToN);
          num newDistance2 = _calculateRealDistance(foundBeacons[j].id, mapScale, defaultN + addToN);
          print("Distance 1: $newDistance1 Distance 2: $newDistance2");
          intersectionPoints[i] = _calculateCircleIntersection(x1, y1, newDistance1, x2, y2, newDistance2);
          addToN--;
        }
        addToN = 1;
        while (_flagIntersectDown && defaultN  + addToN < 5){
          print("Step-down distance");
          _flagIntersectDown = false;
          num newDistance1 = _calculateRealDistance(foundBeacons[i].id, mapScale, defaultN + addToN);
          num newDistance2 = _calculateRealDistance(foundBeacons[j].id, mapScale, defaultN + addToN);
          print("Distance 1: $newDistance1 Distance 2: $newDistance2");
          intersectionPoints[i] = _calculateCircleIntersection(x1, y1, newDistance1, x2, y2, newDistance2);
          addToN--;
        }
        if(_flagIntersectUp || _flagIntersectDown){
          print("flags");
        }
      }
      print(intersectionPoints);
      //calculate position
      List<List<double>> middlePoints = [[0, 0], [0, 0], [0, 0]];
      for(int i = 0; i < 3; i++){
        double minDistance = 1000000;

        int j = i - 1;
        if( j < 0) j = 2;

        for(int x = 0; x < 2; x++){
          for(int y = 0; y < 2; y++){
              double distance = sqrt(pow(intersectionPoints[i][x * 2] - intersectionPoints[j][y * 2], 2)
                  + pow(intersectionPoints[i][x * 2 + 1] - intersectionPoints[j][y * 2 + 1], 2));
              if(minDistance > distance){
                minDistance = distance;
                middlePoints[i][0] = (intersectionPoints[i][x * 2] + intersectionPoints[j][y * 2]) / 2;
                middlePoints[i][1] = (intersectionPoints[i][x * 2 + 1] + intersectionPoints[j][y * 2 + 1]) / 2;
              }
          }
        }
      }
      // calculate middle of the triangle - user position
      for(List <double> point in middlePoints){
        userPosX += point[0];
        userPosY += point[1];
      }
      userPosX /= 3;
      userPosY /= 3;
    }

    print("User position coordinates \nX: $userPosX \nY: $userPosY \n Floor: $userFloor");
    //X value, Y value, Floor number (from 0)
    return (userPosX, userPosY ,userFloor);
  }
}
