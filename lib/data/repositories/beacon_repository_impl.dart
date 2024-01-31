import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_kalman/simple_kalman.dart';

import '../../domain/entities/device.dart';
import '../../domain/repositories/beacon_repository.dart';
import '../../logger.dart';
import '../api/assets_api.dart';
import '../models/raw_beacon.dart';

class BeaconRepositoryImpl implements BeconRepository {
  BeaconRepositoryImpl({
    required AssetsApi assetsApi,
  })  : _assetsApi = assetsApi,
        _deviceStreamController = BehaviorSubject<List<Device>>.seeded([]);

  final AssetsApi _assetsApi;

  late final BehaviorSubject<List<Device>> _deviceStreamController;
  late final List<RawBeacon> _knownBeacons;
  StreamSubscription<List<ScanResult>>? _streamSubscription;

  @override
  ValueStream<List<Device>> get deviceStream => _deviceStreamController.stream;

  @override
  Future<void> initi() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose);

    // check if bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      Logger.error('Bluetooth not supported by this device');
      return;
    }

    await _getBeaconFromCSV();
  }

  Future<void> _getBeaconFromCSV() async {
    try {
      _knownBeacons = await _assetsApi.loadBeacons();
    } catch (e) {
      Logger.error('Error with beacon file handling: $e');
    }
  }

  @override
  Future<void> startScan() async {
    // return if already scanning
    if (FlutterBluePlus.isScanningNow) {
      return;
    }
    _kalmanFilter = {};
    _lastFilteredValue = {};
    // make sure bluetooth is enabled
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        _runScan();
      } else {
        stopScan();
        throw Exception('Bluetooth is off');
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
    await _streamSubscription?.cancel();
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
    await _streamSubscription?.cancel();
    await FlutterBluePlus.stopScan();
  }

  void _deviceCallback(List<ScanResult> results) {
    final currentTime = DateTime.now();
    _deviceStreamController.add(
      results
          .where(
            (e) =>
                _knownBeacons.any((b) => e.device.remoteId.str == b.deviceId) &&
                currentTime.difference(e.timeStamp).inSeconds < 2,
          )
          .map(
            (e) => Device(
              id: e.device.remoteId.str,
              name: e.advertisementData.advName,
              rssi: e.rssi,
            ),
          )
          .toList(),
    );
  }

  //Location calculation variables
  late Map<String, double> _lastFilteredValue;
  late Map<String, SimpleKalman> _kalmanFilter;
  bool _flagIntersectDown = false;
  bool _flagIntersectUp = false;
  late int _defaultN;
  List<double> lastKnownPosition = [0, 0];
  int lastKnownFloor = 0;
  double lastLocalizationError = 0;

  double _calculateMetersFromRssi(
    double measuredRssi,
    double meterRssi, {
    int n = 3,
  }) {
    final power = (meterRssi - measuredRssi) / (10 * n);
    return pow(10, power) as double;
  }

  double _calculateRealDistance(
    String id,
    double mapScale,
    int n, {
    double defaultUserPhoneZ = 1.4,
  }) {
    var distanceMeters = 0.0;
    final beacon = _knownBeacons.firstWhere((e) => e.deviceId == id);

    if (_lastFilteredValue[id]! <= beacon.rssiAt1m) {
      distanceMeters = _calculateMetersFromRssi(
        _lastFilteredValue[id]!,
        beacon.rssiAt1m.toDouble(),
        n: n,
      );
    } else {
      distanceMeters = _calculateMetersFromRssi(
        _lastFilteredValue[id]!,
        beacon.rssiAt1m.toDouble(),
        n: _defaultN + (_defaultN - n),
      );
    }

    //adjusting for beacon height in relation to user phone
    final heightDifference = beacon.posZ - defaultUserPhoneZ;
    if (distanceMeters > heightDifference.abs()) {
      distanceMeters = sqrt(pow(distanceMeters, 2) - pow(heightDifference, 2));
    }

    return distanceMeters * mapScale;
  }

  List<double> _calculateCircleIntersection(
    double x1,
    double y1,
    double r1,
    double x2,
    double y2,
    double r2,
  ) {
    final d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    //check id circles intersect with each other
    if (d > r1 + r2) {
      _flagIntersectUp = true;
      return [0.0, 0.0, 0.0, 0.0];
    }
    if (d < (r1 - r2).abs()) {
      _flagIntersectDown = true;
      return [0.0, 0.0, 0.0, 0.0];
    }
    // Area according to Heron's formula
    final a1 = d + r1 + r2;
    var a2 = d + r1 - r2;
    var a3 = d - r1 + r2;
    var a4 = -d + r1 + r2;
    // C
    if (0 > a2) {
      a2 = 0;
    }
    if (0 > a3) {
      a3 = 0;
    }
    if (0 > a4) {
      a4 = 0;
    }
    final area = sqrt(a1 * a2 * a3 * a4) / 4;

    // Calculating x axis intersection values
    final xP1 =
        (x1 + x2) / 2 + (x2 - x1) * (pow(r1, 2) - pow(r2, 2)) / (2 * pow(d, 2));
    final xP2 = 2 * (y1 - y2) * area / pow(d, 2);

    final xIntersection1 = xP1 + xP2;
    final xIntersection2 = xP1 - xP2;

    // Calculating y axis intersection values
    final yP1 =
        (y1 + y2) / 2 + (y2 - y1) * (pow(r1, 2) - pow(r2, 2)) / (2 * pow(d, 2));
    final yP2 = 2 * (x1 - x2) * area / pow(d, 2);

    var yIntersection1 = yP1 - yP2;
    var yIntersection2 = yP1 + yP2;

    final test = ((xIntersection1 - x1) * (xIntersection1 - x1) +
            (yIntersection1 - y1) * (yIntersection1 - y1) -
            pow(r1, 2))
        .abs();
    if (test > 0.0000001) {
      final tmp = yIntersection1;
      yIntersection1 = yIntersection2;
      yIntersection2 = tmp;
    }
    return [
      xIntersection1,
      yIntersection1,
      xIntersection2,
      yIntersection2,
    ];
  }

  int _iterator = 0;
  @override
  (double, double, int, double, bool) deviceLocation({
    double mapScale = 1,
    int defaultN = 4,
  }) {
    //returns
    _defaultN = defaultN;
    var userPosX = 0.0;
    var userPosY = 0.0;
    var userFloor = 0;
    var localizationError = 0.0;
    var noBeaconsFound = false;

    final foundBeacons = _deviceStreamController.value;
    if (_iterator < foundBeacons.length) {
      _iterator++;
      return (
        lastKnownPosition[0],
        lastKnownPosition[1],
        lastKnownFloor,
        lastLocalizationError,
        true
      );
    } else {
      _iterator = 0;
    }
    foundBeacons.sort((rssia, rssib) => rssia.rssi < rssib.rssi ? 1 : -1);

    // remembers latest 3 measured signal strength
    // to smooth out  outliers - in testing phase
    for (var i = 0; i < foundBeacons.length && i < 6; i++) {
      if (_kalmanFilter.containsKey(foundBeacons[i].id)) {
        _lastFilteredValue[foundBeacons[i].id] =
            _kalmanFilter[foundBeacons[i].id]!
                .filtered(foundBeacons[i].rssi * 1.0);
        Logger.trace(
          'Got: ${foundBeacons[i].rssi} '
          'filtered: ${_lastFilteredValue[foundBeacons[i].id]}',
        );
      } else {
        _kalmanFilter[foundBeacons[i].id] =
            SimpleKalman(errorMeasure: 10, errorEstimate: 15, q: 0.8);
        _lastFilteredValue[foundBeacons[i].id] =
            _kalmanFilter[foundBeacons[i].id]!
                .filtered(foundBeacons[i].rssi * 1.0);
      }
    }

    //calculate device position
    final realDistance = <double>[];
    final intersectionPoints = <List<double>>[];
    for (var i = 0; i < foundBeacons.length && i < 3; i++) {
      final distanceMeters =
          _calculateRealDistance(foundBeacons[i].id, mapScale, defaultN);
      realDistance.add(distanceMeters);
    }
    //calculate circle intersection
    if (foundBeacons.length >= 3) {
      for (var i = 0; i < 3; i++) {
        _flagIntersectUp = false;
        _flagIntersectDown = false;
        var j = i + 1;
        if (j == 3) j = 0;

        final beaconI = _knownBeacons.firstWhere(
          (e) => e.deviceId == foundBeacons[i].id,
        );
        final beaconJ = _knownBeacons.firstWhere(
          (e) => e.deviceId == foundBeacons[j].id,
        );

        final x1 = beaconI.posX;
        final x2 = beaconJ.posX;
        final y1 = beaconI.posY;
        final y2 = beaconJ.posY;

        Logger.trace('Raw distance: $realDistance');

        intersectionPoints.add(
          _calculateCircleIntersection(
            x1,
            y1,
            realDistance[i],
            x2,
            y2,
            realDistance[j],
          ),
        );
        // if circles radius is too small both are sized
        // up in the same proportion to previous size
        var addToN = -1;
        while (_flagIntersectUp && defaultN + addToN > 3) {
          //print("Step-up distance");
          _flagIntersectUp = false;
          final newDistance1 = _calculateRealDistance(
            foundBeacons[i].id,
            mapScale,
            defaultN + addToN,
          );
          final newDistance2 = _calculateRealDistance(
            foundBeacons[j].id,
            mapScale,
            defaultN + addToN,
          );
          final name1 = foundBeacons[i].id;
          final name2 = foundBeacons[j].id;
          Logger.trace(
            'Distance $name1: $newDistance1 Distance $name2: $newDistance2',
          );
          intersectionPoints[i] = _calculateCircleIntersection(
            x1,
            y1,
            newDistance1,
            x2,
            y2,
            newDistance2,
          );
          addToN--;
        }
        // if circles radius is too big both are sized down
        // in the same proportion to previous size
        addToN = 1;
        while (_flagIntersectDown && defaultN + addToN < 4) {
          //print("Step-down distance");
          _flagIntersectDown = false;
          final newDistance1 = _calculateRealDistance(
            foundBeacons[i].id,
            mapScale,
            defaultN + addToN,
          );
          final newDistance2 = _calculateRealDistance(
            foundBeacons[j].id,
            mapScale,
            defaultN + addToN,
          );
          final name1 = foundBeacons[i].id;
          final name2 = foundBeacons[j].id;
          Logger.trace(
            'Distance $name1: $newDistance1 Distance $name2: $newDistance2',
          );
          intersectionPoints[i] = _calculateCircleIntersection(
            x1,
            y1,
            newDistance1,
            x2,
            y2,
            newDistance2,
          );
          addToN++;
        }

        // if above fails we get points that are closest to the middle
        // of both circles and take point between as an intersection

        if (_flagIntersectUp) {
          Logger.trace('flags');
          _flagIntersectUp = false;
          final d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
          final closesPointCircle1 = _calculateCircleIntersection(
            x1,
            y1,
            realDistance[i],
            x2,
            y2,
            d - realDistance[i],
          );
          final closesPointCircle2 = _calculateCircleIntersection(
            x1,
            y1,
            d - realDistance[j],
            x2,
            y2,
            realDistance[j],
          );
          final middlePoint = [
            (closesPointCircle1[0] + closesPointCircle2[0]) / 2,
            (closesPointCircle1[1] + closesPointCircle2[1]) / 2,
          ];
          intersectionPoints[i] = middlePoint + middlePoint;
        }
        if (_flagIntersectDown) {
          Logger.trace('flags');
          _flagIntersectDown = false;
          final d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
          if (realDistance[i] > realDistance[j]) {
            final closesPointCircle1 = _calculateCircleIntersection(
              x1,
              y1,
              d + realDistance[j],
              x2,
              y2,
              realDistance[j],
            );
            final closesPointCircle2 = _calculateCircleIntersection(
              x1,
              y1,
              realDistance[i],
              x2,
              y2,
              realDistance[i] - d,
            );
            final middlePoint = [
              (closesPointCircle1[0] + closesPointCircle2[0]) / 2,
              (closesPointCircle1[1] + closesPointCircle2[1]) / 2,
            ];
            intersectionPoints[i] = middlePoint + middlePoint;
          } else {
            final closesPointCircle1 = _calculateCircleIntersection(
              x1,
              y1,
              realDistance[i],
              x2,
              y2,
              d + realDistance[i],
            );
            final closesPointCircle2 = _calculateCircleIntersection(
              x1,
              y1,
              realDistance[j] - d,
              x2,
              y2,
              realDistance[j],
            );
            final middlePoint = [
              (closesPointCircle1[0] + closesPointCircle2[0]) / 2,
              (closesPointCircle1[1] + closesPointCircle2[1]) / 2,
            ];
            intersectionPoints[i] = middlePoint + middlePoint;
          }
        }

        // calculate user floor
        final beacon = _knownBeacons.firstWhere(
          (e) => e.deviceId == foundBeacons[i].id,
        );

        userFloor += beacon.deviceFloor;
      }
      userFloor = (userFloor / 3).round();

      Logger.trace(intersectionPoints);

      //calculate position
      final middlePoints = [
        [0.0, 0.0],
        [0.0, 0.0],
        [0.0, 0.0],
      ];
      for (var i = 0; i < 3; i++) {
        var minDistance = double.maxFinite;

        var j = i - 1;
        if (j < 0) j = 2;

        for (var x = 0; x < 2; x++) {
          for (var y = 0; y < 2; y++) {
            final distance = sqrt(
              pow(
                    intersectionPoints[i][x * 2] - intersectionPoints[j][y * 2],
                    2,
                  ) +
                  pow(
                    intersectionPoints[i][x * 2 + 1] -
                        intersectionPoints[j][y * 2 + 1],
                    2,
                  ),
            );
            if (minDistance > distance) {
              minDistance = distance;
              middlePoints[i][0] = (intersectionPoints[i][x * 2] +
                      intersectionPoints[j][y * 2]) /
                  2;
              middlePoints[i][1] = (intersectionPoints[i][x * 2 + 1] +
                      intersectionPoints[j][y * 2 + 1]) /
                  2;
            }
          }
        }
      }
      // calculate middle of the triangle - user position
      for (final point in middlePoints) {
        userPosX += point[0];
        userPosY += point[1];
      }
      userPosX /= 3;
      userPosY /= 3;

      localizationError = sqrt(
        pow(middlePoints[0][0] - userPosX, 2) +
            pow(middlePoints[0][1] - userPosY, 2),
      );
    } else if (foundBeacons.length == 2) {
      //only two beacons found - Use last known position
      _flagIntersectUp = false;
      _flagIntersectDown = false;

      final beacon0 = _knownBeacons.firstWhere(
        (e) => e.deviceId == foundBeacons[0].id,
      );

      final beacon1 = _knownBeacons.firstWhere(
        (e) => e.deviceId == foundBeacons[1].id,
      );

      final x1 = beacon0.posX;
      final x2 = beacon1.posX;
      final y1 = beacon0.posY;
      final y2 = beacon1.posY;

      intersectionPoints.add(
        _calculateCircleIntersection(
          x1,
          y1,
          realDistance[0],
          x2,
          y2,
          realDistance[1],
        ),
      );

      var addToN = -1;
      while (_flagIntersectUp && defaultN + addToN > 0) {
        //print("Step-up distance");
        _flagIntersectUp = false;
        final newDistance1 = _calculateRealDistance(
          foundBeacons[0].id,
          mapScale,
          defaultN + addToN,
        );
        final newDistance2 = _calculateRealDistance(
          foundBeacons[1].id,
          mapScale,
          defaultN + addToN,
        );
        intersectionPoints[0] = _calculateCircleIntersection(
          x1,
          y1,
          newDistance1,
          x2,
          y2,
          newDistance2,
        );
        addToN--;
      }
      // if circles radius is too big both are sized down
      // in the same proportion to previous size
      addToN = 1;
      while (_flagIntersectDown && defaultN + addToN < 5) {
        //print("Step-down distance");
        _flagIntersectDown = false;
        final newDistance1 = _calculateRealDistance(
          foundBeacons[0].id,
          mapScale,
          defaultN + addToN,
        );
        final newDistance2 = _calculateRealDistance(
          foundBeacons[1].id,
          mapScale,
          defaultN + addToN,
        );
        intersectionPoints[0] = _calculateCircleIntersection(
          x1,
          y1,
          newDistance1,
          x2,
          y2,
          newDistance2,
        );
        addToN++;
      }
      // if above fails we get points that are closest to the middle of both
      // circles and take point between as an intersection
      if (_flagIntersectUp) {
        _flagIntersectUp = false;
        final d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
        final closesPointCircle1 = _calculateCircleIntersection(
          x1,
          y1,
          realDistance[0],
          x2,
          y2,
          d - realDistance[0],
        );
        final closesPointCircle2 = _calculateCircleIntersection(
          x1,
          y1,
          d - realDistance[1],
          x2,
          y2,
          realDistance[1],
        );
        final middlePoint = [
          (closesPointCircle1[0] + closesPointCircle2[0]) / 2,
          (closesPointCircle1[1] + closesPointCircle2[1]) / 2,
        ];
        intersectionPoints[0] = middlePoint + middlePoint;
      }
      if (_flagIntersectDown) {
        _flagIntersectDown = false;
        final d = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
        if (realDistance[0] > realDistance[1]) {
          final closesPointCircle1 = _calculateCircleIntersection(
            x1,
            y1,
            d + realDistance[1],
            x2,
            y2,
            realDistance[1],
          );
          final closesPointCircle2 = _calculateCircleIntersection(
            x1,
            y1,
            realDistance[0],
            x2,
            y2,
            realDistance[0] - d,
          );
          final middlePoint = [
            (closesPointCircle1[0] + closesPointCircle2[0]) / 2,
            (closesPointCircle1[1] + closesPointCircle2[1]) / 2,
          ];
          intersectionPoints[0] = middlePoint + middlePoint;
        } else {
          final closesPointCircle1 = _calculateCircleIntersection(
            x1,
            y1,
            realDistance[0],
            x2,
            y2,
            d + realDistance[0],
          );
          final closesPointCircle2 = _calculateCircleIntersection(
            x1,
            y1,
            realDistance[1] - d,
            x2,
            y2,
            realDistance[1],
          );
          final middlePoint = [
            (closesPointCircle1[0] + closesPointCircle2[0]) / 2,
            (closesPointCircle1[1] + closesPointCircle2[1]) / 2,
          ];
          intersectionPoints[0] = middlePoint + middlePoint;
        }
      }

      //calculate which intersection point is closest to last known position
      final distance = sqrt(
        pow(intersectionPoints[0][0] - lastKnownPosition[0], 2) +
            pow(intersectionPoints[0][1] - lastKnownPosition[1], 2),
      );
      final newDistance = sqrt(
        pow(intersectionPoints[0][2] - lastKnownPosition[0], 2) +
            pow(intersectionPoints[0][3] - lastKnownPosition[1], 2),
      );
      if (distance <= newDistance) {
        userPosX = intersectionPoints[0][0];
        userPosY = intersectionPoints[0][1];
      } else {
        userPosX = intersectionPoints[0][2];
        userPosY = intersectionPoints[0][3];
      }

      final beacon = _knownBeacons.firstWhere(
        (e) => e.deviceId == foundBeacons[0].id,
      );

      userFloor = beacon.deviceFloor;
      localizationError = sqrt(
        pow(lastKnownPosition[0] - userPosX, 2) +
            pow(lastKnownPosition[1] - userPosY, 2),
      );
      localizationError += sqrt(
        pow(intersectionPoints[0][0] - intersectionPoints[0][2], 2) +
            pow(intersectionPoints[0][1] - intersectionPoints[0][3], 2),
      );
    } else {
      userPosX = lastKnownPosition[0];
      userPosY = lastKnownPosition[1];
      localizationError = lastLocalizationError;
      noBeaconsFound = true;
    }
    lastKnownPosition = [userPosX, userPosY];
    lastKnownFloor = userFloor;

    Logger.trace(
      'User position coordinates - '
      'X: $userPosX '
      'Y: $userPosY '
      'Floor: $userFloor '
      'Localization error: $localizationError',
    );
    //X value, Y value, Floor number (from 0)
    return (userPosX, userPosY, userFloor, localizationError, noBeaconsFound);
  }
}
