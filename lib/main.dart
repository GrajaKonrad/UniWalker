import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/api/assers_api_impl.dart';
import 'data/repositories/beacon_repository_impl.dart';
import 'data/repositories/map_repository_impl.dart';
import 'domain/repositories/map_repository.dart';
import 'domain/use_cases/beacon_use_case.dart';
import 'router/app_router.dart';
import 'ui/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final assetsApi = AssetsApiImpl();
  final beaconRepository = BeaconRepositoryImpl(assetsApi: assetsApi);

  await Future.wait([
    beaconRepository.initi(),
  ]);

  final beconUseCase = BeaconUseCase(
    beaconRepository: beaconRepository,
  );

  final mapRepository = MapRepositoryImpl();

  runApp(
    MyApp(
      beconUseCase: beconUseCase,
      mapRepository: mapRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    required BeaconUseCase beconUseCase,
    required MapRepository mapRepository,
    super.key,
  })  : _mapRepository = mapRepository,
        _beconUseCase = beconUseCase;

  final BeaconUseCase _beconUseCase;
  final MapRepository _mapRepository;

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _beconUseCase),
        Provider.value(value: _mapRepository),
      ],
      child: MaterialApp.router(
        title: 'UniWalker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary800,
            background: AppColors.grayscale600,
          ),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
