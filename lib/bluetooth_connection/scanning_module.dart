import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io' show Platform;

class BluetoothScanner {
  const BluetoothScanner();

  Future startBluetooth() async
  {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color:false);
    print("DONE2");

    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        _scanBluetooth();
      } else {
        unawaited(FlutterBluePlus.stopScan());
        print("Bluetooth Stopped");
      }
    });

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future _scanBluetooth() async
  {
    // Setup Listener for scan results.
    // device not found? see "Common Problems" in the README
    Set<DeviceIdentifier> seen = {};
    var subscription = FlutterBluePlus.scanResults.listen(
            (results) {
              for (ScanResult r in results) {
                if (seen.contains(r.device.remoteId) == false) {
                  print('${r.device.remoteId}: "${r.advertisementData.localName}" found! rssi: ${r.rssi}');
                  //seen.add(r.device.remoteId);
                }
              }
            },
          onError: (e) => print(e)
      );

    // Start scanning
    await FlutterBluePlus.startScan();
  }
}
