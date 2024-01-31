import '../models/models.dart';

// ignore: one_member_abstracts
abstract interface class AssetsApi {
  Future<List<RawBeacon>> loadBeacons();
}
