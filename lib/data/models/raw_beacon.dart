import 'package:json_annotation/json_annotation.dart';

part 'raw_beacon.g.dart';

@JsonSerializable()
class RawBeacon {
  const RawBeacon({
    required this.deviceId,
    required this.name,
    required this.rssiAt1m,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.deviceFloor,
  });

  factory RawBeacon.fromJson(Map<String, dynamic> json) =>
      _$RawBeaconFromJson(json);

  @JsonKey(name: 'Device_id')
  final String deviceId;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'RSSI_at_1m')
  final int rssiAt1m;

  @JsonKey(name: 'Pos_x')
  final double posX;

  @JsonKey(name: 'Pos_y')
  final double posY;

  @JsonKey(name: 'Pos_z')
  final double posZ;

  @JsonKey(name: 'Device_floor')
  final int deviceFloor;

  Map<String, dynamic> toJson() => _$RawBeaconToJson(this);
}
