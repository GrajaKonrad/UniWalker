import 'package:auto_route/auto_route.dart';

import '../modules/camera/views/camera_view.dart';
import '../modules/device_list/views/device_list_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/map/views/map_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: CameraRoute.page),
        AutoRoute(page: DeviceListRoute.page),
        AutoRoute(page: MapRoute.page),
      ];
}
