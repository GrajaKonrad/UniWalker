part of 'device_list_cubit.dart';

@immutable
sealed class DeviceListState extends Equatable {
  const DeviceListState();
}

final class DeviceListLoadingState extends DeviceListState {
  const DeviceListLoadingState();

  @override
  List<Object?> get props => [];
}

final class DeviceListLoadedState extends DeviceListState {
  const DeviceListLoadedState({required this.devices});

  final List<Device> devices;

  @override
  List<Object?> get props => [devices];
}

final class DeviceListErrorState extends DeviceListState {
  const DeviceListErrorState();

  @override
  List<Object?> get props => [];
}
