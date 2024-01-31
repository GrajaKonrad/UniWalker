import 'package:flutter/material.dart';

import '../../../domain/entities/entities.dart';
import '../../../ui/colors.dart';

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
            child: Text(
              device.id,
              style: const TextStyle(color: AppColors.grayscale100),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              device.name,
              style: const TextStyle(color: AppColors.grayscale100),
            ),
          ),
          Expanded(
            child: Text(
              device.rssi.toString(),
              style: const TextStyle(color: AppColors.grayscale100),
            ),
          ),
        ],
      ),
    );
  }
}
