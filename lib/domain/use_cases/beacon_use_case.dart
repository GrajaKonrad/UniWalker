import 'package:rxdart/rxdart.dart';
import 'package:uni_walker/domain/entities/device.dart';
import 'package:uni_walker/domain/repositories/beacon_repository.dart';

class BeconUseCase {
  BeconUseCase({
    required BeconRepository beconRepository,
  }) : _beconRepository = beconRepository;

  final BeconRepository _beconRepository;

  ValueStream<List<Device>> get deviceStream => _beconRepository.deviceStream;
  Future<void> startScan() => _beconRepository.startScan();
  Future<void> stopScan() => _beconRepository.stopScan();
}
