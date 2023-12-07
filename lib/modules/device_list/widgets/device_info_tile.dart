import 'package:flutter/material.dart';

import '../../../domain/entities/entities.dart';

class DeviceInfoTile extends StatelessWidget {
  const DeviceInfoTile({
    required this.device,
    super.key,
  });

  final Device device;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(device.id),
          ),
          Expanded(
            flex: 2,
            child: Text(device.name),
          ),
          Expanded(
            child: Text(device.rssi.toString()),
          ),
        ],
      ),
    );
  }
}
