// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_beacon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawBeacon _$RawBeaconFromJson(Map<String, dynamic> json) => RawBeacon(
      deviceId: json['Device_id'] as String,
      name: json['Name'] as String,
      rssiAt1m: json['RSSI_at_1m'] as int,
      posX: (json['Pos_x'] as num).toDouble(),
      posY: (json['Pos_y'] as num).toDouble(),
      posZ: (json['Pos_z'] as num).toDouble(),
      deviceFloor: json['Device_floor'] as int,
    );

Map<String, dynamic> _$RawBeaconToJson(RawBeacon instance) => <String, dynamic>{
      'Device_id': instance.deviceId,
      'Name': instance.name,
      'RSSI_at_1m': instance.rssiAt1m,
      'Pos_x': instance.posX,
      'Pos_y': instance.posY,
      'Pos_z': instance.posZ,
      'Device_floor': instance.deviceFloor,
    };
