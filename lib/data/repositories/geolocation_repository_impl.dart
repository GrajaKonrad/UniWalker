import 'package:geolocator/geolocator.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

Future<(double, double)> calculateGeolocationPosition(double mapStartX, double mapStartY, double mapScale)
async {
  Position currentPosition =  await _determinePosition();
  double posX = (currentPosition.latitude - mapStartX) * mapScale;
  double posY = (currentPosition.longitude - mapStartY) * mapScale;
  return (posX, posY);
}