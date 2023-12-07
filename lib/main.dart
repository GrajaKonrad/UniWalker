import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/repositories/beacon_repository_impl.dart';
import 'domain/repositories/beacon_repository.dart';
import 'domain/use_cases/beacon_use_case.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final BeconRepository beconRepository = BeconRepositoryImpl();

  await Future.wait([
    beconRepository.initi(),
  ]);

  final beconUseCase = BeconUseCase(
    beconRepository: beconRepository,
  );

  runApp(
    MyApp(
      beconUseCase: beconUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    required BeconUseCase beconUseCase,
    super.key,
  }) : _beconUseCase = beconUseCase;

  final BeconUseCase _beconUseCase;
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
