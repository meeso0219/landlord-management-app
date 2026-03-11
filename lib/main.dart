import 'package:flutter/material.dart';
import 'package:landlord_management_app/data_sources/shared_prefs_unit_lease_local_data_source.dart';
import 'package:landlord_management_app/repositories/in_memory_unit_lease_repository.dart';
import 'package:landlord_management_app/repositories/unit_lease_repository.dart';
import 'package:landlord_management_app/screens/home_screen.dart';
import 'package:landlord_management_app/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();

  final localDataSource = await SharedPrefsUnitLeaseLocalDataSource.create();
  final repository = await InMemoryUnitLeaseRepository.create(
    localDataSource: localDataSource,
    fallbackSampleLeases: InMemoryUnitLeaseRepository.buildSampleLeases(),
  );

  runApp(App(repository: repository));
}

class App extends StatelessWidget {
  const App({super.key, required this.repository});

  final UnitLeaseRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landlord Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(repository: repository),
    );
  }
}
