import 'dart:ui';

import '../domain/entities/map/map_element.dart';

extension PathExt on Path {
  void addMapElement({required MapElement mapElement}) =>
      mapElement.add(path: this);
}
