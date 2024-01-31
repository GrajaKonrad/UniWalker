import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';
import 'assets_api.dart';

class AssetsApiImpl implements AssetsApi {
  @override
  Future<List<RawBeacon>> loadBeacons() async {
    final jsonString = await rootBundle.loadString('assets/beacons.json');
    final json = jsonDecode(jsonString) as List<dynamic>;
    return json
        .map((e) => RawBeacon.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
