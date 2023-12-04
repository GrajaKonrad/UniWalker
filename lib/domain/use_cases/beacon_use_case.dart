import 'package:rxdart/rxdart.dart';
import 'package:uni_walker/domain/entities/device.dart';
import 'package:uni_walker/domain/repositories/beacon_repository.dart';

class BeaconUseCase {
  BeaconUseCase({
    required BeconRepository beaconRepository,
  }) : _beaconRepository = beaconRepository;

  final BeconRepository _beaconRepository;

  ValueStream<List<Device>> get deviceStream => _beaconRepository.deviceStream;
  Future<void> startScan() => _beaconRepository.startScan();
  Future<void> stopScan() => _beaconRepository.stopScan();
  (double, double, int) deviceLocation() => _beaconRepository.deviceLocation();
}
