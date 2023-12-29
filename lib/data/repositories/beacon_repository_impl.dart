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
    _deviceStreamController.add(
        results.where(
          (e) => _knownBeacons.containsKey(e.device.remoteId.str)
        ).map(
          (e) => Device(
            id: e.device.remoteId.str,
            name: e.advertisementData.localName,
            rssi: e.rssi,
          )
        ).toList()
    );
  }

  //Location calculation variables
  late Map<String, List<int>> _closestRssiValues;
  bool _flagIntersectDown = false;
  bool _flagIntersectUp = false;
  late int _defaultN;
  List<double> lastKnownPosition = [0, 0];


  num _calculateMetersFromRssi(double measuredRssi, num meterRssi, {int n = 3}) {
    num power = (meterRssi - measuredRssi) / (10 * n);
    return pow(10, power);
  }

  num _calculateRealDistance(String id, double mapScale, int n, {double defaultUserPhoneZ = 1.4}){
    var mean = _closestRssiValues[id]!.reduce((a, b) => a + b) / _closestRssiValues[id]!.length;
    num distanceMeters = 0.0;
    if (mean <= _knownBeacons[id]?['RSSI_at_1m']){
        distanceMeters = _calculateMetersFromRssi(
          mean,
          _knownBeacons[id]?['RSSI_at_1m'] as num,
          n: n);
    } else{
        distanceMeters = _calculateMetersFromRssi(
          mean,
          _knownBeacons[id]?['RSSI_at_1m'] as num,
          n: _defaultN + (_defaultN - n));
    }
    //adjusting for beacon height in relation to user phone
    double heightDifference = _knownBeacons[id]?['Pos_z'] - defaultUserPhoneZ;
    if(distanceMeters > heightDifference.abs()) {
      distanceMeters = sqrt(pow(distanceMeters, 2) - pow(heightDifference, 2));
    }
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
    // Area according to Heron's formula
    double a1 = d + r1 + r2;
    double a2 = d + r1 - r2;
    double a3 = d - r1 + r2;
    double a4 = -d + r1 + r2;
    // C
    if(0 > a2){a2 = 0;}
    if(0 > a3){a3 = 0;}
    if(0 > a4){a4 = 0;}
    double area = sqrt(a1 * a2 * a3 * a4) / 4;

    // Calculating x axis intersection values
    double xP1 = (x1 + x2) / 2 + (x2 - x1) * (pow(r1, 2) - pow(r2, 2)) / (2 * pow(d, 2));
    double xP2 = 2 * (y1 - y2) * area / pow(d, 2);

    double xIntersection1 = xP1 + xP2;
    double xIntersection2 = xP1 - xP2;

    // Calculating y axis intersection values
    double yP1 = (y1 + y2) / 2 + (y2 - y1) * (pow(r1, 2) - pow(r2, 2)) / (2 * pow(d, 2));
    double yP2 = 2 * (x1 - x2) * area / pow(d, 2);

    double yIntersection1 = yP1 - yP2;
    double yIntersection2 = yP1 + yP2;

    double test = ((xIntersection1 - x1) * (xIntersection1 - x1) + (yIntersection1 - y1) * (yIntersection1 - y1) - pow(r1, 2)).abs();
    if(test > 0.0000001){
      double tmp = yIntersection1;
      yIntersection1 = yIntersection2;
      yIntersection2 = tmp;
    }
    return [xIntersection1, yIntersection1, xIntersection2, yIntersection2];
  }

  @override
  (double, double, int) deviceLocation({double mapScale = 1, int defaultN = 3}) {
    //returns
    _defaultN = defaultN;
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

        // print("Raw distance");
        // print(realDistance);

        intersectionPoints.add(
            _calculateCircleIntersection(x1, y1, realDistance[i], x2, y2, realDistance[j]));
        // if circles radius is too small both are sized up in the same proportion to previous size
        int addToN = -1;
        while (_flagIntersectUp && defaultN  + addToN > 0){
          //print("Step-up distance");
          _flagIntersectUp = false;
          num newDistance1 = _calculateRealDistance(foundBeacons[i].id, mapScale, defaultN + addToN);
          num newDistance2 = _calculateRealDistance(foundBeacons[j].id, mapScale, defaultN + addToN);
          // var name1=foundBeacons[i].id;
          // var name2=foundBeacons[j].id;
          //print("Distance $name1: $newDistance1 Distance $name2: $newDistance2");
          intersectionPoints[i] = _calculateCircleIntersection(x1, y1, newDistance1, x2, y2, newDistance2);
          addToN--;
        }
        // if circles radius is too big both are sized down in the same proportion to previous size
        addToN = 1;
        while (_flagIntersectDown && defaultN  + addToN < 5){
          //print("Step-down distance");
          _flagIntersectDown = false;
          num newDistance1 = _calculateRealDistance(foundBeacons[i].id, mapScale, defaultN + addToN);
          num newDistance2 = _calculateRealDistance(foundBeacons[j].id, mapScale, defaultN + addToN);
          // var name1=foundBeacons[i].id;
          // var name2=foundBeacons[j].id;
          //print("Distance $name1: $newDistance1 Distance $name2: $newDistance2");
          intersectionPoints[i] = _calculateCircleIntersection(x1, y1, newDistance1, x2, y2, newDistance2);
          addToN++;
        }

        // if above fails we get points that are closest to the middle of both circles and take point between as an intersection
        if(_flagIntersectUp){
          _flagIntersectUp = false;
          double d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
          List <num> closesPointCircle1 = _calculateCircleIntersection(x1, y1, realDistance[i], x2, y2, d - realDistance[i]);
          List <num> closesPointCircle2 = _calculateCircleIntersection(x1, y1, d - realDistance[j], x2, y2, realDistance[j]);
          List <num> middlePoint = [(closesPointCircle1[0] + closesPointCircle2[0]) / 2, (closesPointCircle1[1] + closesPointCircle2[1]) / 2];
          intersectionPoints[i] = middlePoint + middlePoint;
        }
        if(_flagIntersectDown)
          {
            _flagIntersectDown = false;
            double d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
              if(realDistance[i] > realDistance[j])
                {
                  List <num> closesPointCircle1 = _calculateCircleIntersection(x1, y1, d + realDistance[j], x2, y2,realDistance[j]);
                  List <num> closesPointCircle2 = _calculateCircleIntersection(x1, y1, realDistance[i], x2, y2,realDistance[i] - d);
                  List <num> middlePoint = [(closesPointCircle1[0] + closesPointCircle2[0]) / 2, (closesPointCircle1[1] + closesPointCircle2[1]) / 2];
                  intersectionPoints[i] = middlePoint + middlePoint;
                }
              else
                {
                  List <num> closesPointCircle1 = _calculateCircleIntersection(x1, y1, realDistance[i], x2, y2, d + realDistance[i]);
                  List <num> closesPointCircle2 = _calculateCircleIntersection(x1, y1, realDistance[j] - d, x2, y2,realDistance[j]);
                  List <num> middlePoint = [(closesPointCircle1[0] + closesPointCircle2[0]) / 2, (closesPointCircle1[1] + closesPointCircle2[1]) / 2];
                  intersectionPoints[i] = middlePoint + middlePoint;
                }
          }

        // calculate user floor
        userFloor += _knownBeacons[foundBeacons[i].id]!['Device_floor'] as int;
      }
      userFloor = (userFloor / 3).round();

      //print(intersectionPoints);
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
    else if(foundBeacons.length == 2){
      //only two beacons found - Use last known position
      _flagIntersectUp = false;
      _flagIntersectDown = false;
      num x1 = _knownBeacons[foundBeacons[0].id]?['Pos_x'] as num;
      num x2 = _knownBeacons[foundBeacons[1].id]?['Pos_x'] as num;
      num y1 = _knownBeacons[foundBeacons[0].id]?['Pos_y'] as num;
      num y2 = _knownBeacons[foundBeacons[1].id]?['Pos_y'] as num;

      intersectionPoints.add(
          _calculateCircleIntersection(x1, y1, realDistance[0], x2, y2, realDistance[1]));

      int addToN = -1;
      while (_flagIntersectUp && defaultN  + addToN > 0){
        //print("Step-up distance");
        _flagIntersectUp = false;
        num newDistance1 = _calculateRealDistance(foundBeacons[0].id, mapScale, defaultN + addToN);
        num newDistance2 = _calculateRealDistance(foundBeacons[1].id, mapScale, defaultN + addToN);
        intersectionPoints[0] = _calculateCircleIntersection(x1, y1, newDistance1, x2, y2, newDistance2);
        addToN--;
      }
      // if circles radius is too big both are sized down in the same proportion to previous size
      addToN = 1;
      while (_flagIntersectDown && defaultN  + addToN < 5){
        //print("Step-down distance");
        _flagIntersectDown = false;
        num newDistance1 = _calculateRealDistance(foundBeacons[0].id, mapScale, defaultN + addToN);
        num newDistance2 = _calculateRealDistance(foundBeacons[1].id, mapScale, defaultN + addToN);
        intersectionPoints[0] = _calculateCircleIntersection(x1, y1, newDistance1, x2, y2, newDistance2);
        addToN++;
      }
      // if above fails we get points that are closest to the middle of both circles and take point between as an intersection
      if(_flagIntersectUp){
        _flagIntersectUp = false;
        double d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
        List <num> closesPointCircle1 = _calculateCircleIntersection(x1, y1, realDistance[0], x2, y2, d - realDistance[0]);
        List <num> closesPointCircle2 = _calculateCircleIntersection(x1, y1, d - realDistance[1], x2, y2, realDistance[1]);
        List <num> middlePoint = [(closesPointCircle1[0] + closesPointCircle2[0]) / 2, (closesPointCircle1[1] + closesPointCircle2[1]) / 2];
        intersectionPoints[0] = middlePoint + middlePoint;
      }
      if(_flagIntersectDown)
      {
        _flagIntersectDown = false;
        double d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
        if(realDistance[0] > realDistance[1])
        {
          List <num> closesPointCircle1 = _calculateCircleIntersection(x1, y1, d + realDistance[1], x2, y2,realDistance[1]);
          List <num> closesPointCircle2 = _calculateCircleIntersection(x1, y1, realDistance[0], x2, y2,realDistance[0] - d);
          List <num> middlePoint = [(closesPointCircle1[0] + closesPointCircle2[0]) / 2, (closesPointCircle1[1] + closesPointCircle2[1]) / 2];
          intersectionPoints[0] = middlePoint + middlePoint;
        }
        else
        {
          List <num> closesPointCircle1 = _calculateCircleIntersection(x1, y1, realDistance[0], x2, y2, d + realDistance[0]);
          List <num> closesPointCircle2 = _calculateCircleIntersection(x1, y1, realDistance[1] - d, x2, y2,realDistance[1]);
          List <num> middlePoint = [(closesPointCircle1[0] + closesPointCircle2[0]) / 2, (closesPointCircle1[1] + closesPointCircle2[1]) / 2];
          intersectionPoints[0] = middlePoint + middlePoint;
        }
      }

      //calculate which intersection point is closest to last known position
      double distance = sqrt(pow(intersectionPoints[0][0] - lastKnownPosition[0], 2) + pow(intersectionPoints[0][1] - lastKnownPosition[1], 2));
      double newDistance = sqrt(pow(intersectionPoints[0][3] - lastKnownPosition[0], 2) + pow(intersectionPoints[0][4] - lastKnownPosition[1], 2));
      if (distance <= newDistance ){
        userPosX = intersectionPoints[0][1].toDouble();
        userPosY = intersectionPoints[0][2].toDouble();
      } else{
        userPosX = intersectionPoints[0][3].toDouble();
        userPosY = intersectionPoints[0][4].toDouble();
      }
      userFloor = _knownBeacons[foundBeacons[0].id]?['Device_floor'] as int;
    }

    lastKnownPosition = [userPosX, userPosY];
    //print("User position coordinates \nX: $userPosX \nY: $userPosY \n Floor: $userFloor");
    //X value, Y value, Floor number (from 0)
    return (userPosX, userPosY ,userFloor);
  }
}


//TODO: remove all prints - in comments too