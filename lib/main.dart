import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uni_walker/data/repositories/beacon_repository_impl.dart';
import 'package:uni_walker/data/repositories/beacon_repository_mock.dart';
import 'package:uni_walker/domain/repositories/beacon_repository.dart';
import 'package:uni_walker/domain/use_cases/beacon_use_case.dart';
import 'package:uni_walker/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  BeconRepository beconRepository = BeaconRepositoryImpl();

  await Future.wait([
    beconRepository.initi(),
  ]);

  BeaconUseCase beconUseCase = BeaconUseCase(
    beaconRepository: beconRepository,
  );

  runApp(MyApp(
    beconUseCase: beconUseCase,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    required BeaconUseCase beconUseCase,
    super.key,
  }) : _beconUseCase = beconUseCase;

  final BeaconUseCase _beconUseCase;
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider.value(value: _beconUseCase)],
      child: MaterialApp.router(
        title: 'UniWalker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
