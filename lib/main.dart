import 'package:flutter/material.dart';
import 'package:pa_recorder/data/sqlite_record_repository.dart';
import 'package:provider/provider.dart';

import 'package:pa_recorder/widgets/adaptive_navigation_scaffold.dart';
import 'package:pa_recorder/data/record_repository.dart';

void main() {
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<RecordRepository> _recordRepositoryFuture;

  @override
  void initState() {
    super.initState();
    _recordRepositoryFuture = _initRepository();
  }

  Future<RecordRepository> _initRepository() async {
    final repository = SqliteRecordRepository();
    await DatabaseHelper.instance.getDb(); // Ensure database is initialized
    return repository;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecordRepository>(
      future: _recordRepositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: [
              Provider<RecordRepository>(
                create: (context) => snapshot.data!,
              ),
            ],
            child: const PARecorderApp(),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing database: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class PARecorderApp extends StatelessWidget {
  const PARecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PA Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'JFOpenshuninn',
      ),
      home: const AdaptiveNavigationScaffold(),
    );
  }
}


