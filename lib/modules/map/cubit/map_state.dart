part of 'map_cubit.dart';

sealed class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  const MapLoaded({
    required this.building,
    required this.path,
  });

  final Building building;
  final List<Position>? path;

  @override
  List<Object?> get props => [
        ...super.props,
        building,
        path,
      ];
}

class MapError extends MapState {
  const MapError();

  @override
  List<Object?> get props => [
        ...super.props,
      ];
}
