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
    required this.floors,
    required this.path,
  });

  final List<Floor> floors;
  final List<Offset>? path;

  @override
  List<Object?> get props => [
        ...super.props,
        floors,
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
