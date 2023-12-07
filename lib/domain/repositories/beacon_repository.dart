import 'package:rxdart/rxdart.dart';

import '../entities/entities.dart';

abstract interface class BeconRepository {
  ValueStream<List<Device>> get deviceStream;

  Future<void> initi();
  Future<void> startScan();
  Future<void> stopScan();
}
