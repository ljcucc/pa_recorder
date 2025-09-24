import 'package:flutter/material.dart';
import 'package:pa_recorder/data/sqlite_record_repository.dart';
import 'package:provider/provider.dart';

import 'package:pa_recorder/widgets/adaptive_navigation_scaffold.dart';
import 'package:pa_recorder/data/record_repository.dart';
import 'package:pa_recorder/pages/hello_page.dart';
import 'package:pa_recorder/providers/hello_provider.dart';
import 'package:pa_recorder/providers/storage_type_provider.dart';
import 'package:pa_recorder/data/file_system_record_repository.dart';
import 'package:pa_recorder/directory_provider.dart';

void main() {
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HelloProvider()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
        ChangeNotifierProvider(create: (_) => StorageTypeProvider()),
        ProxyProvider2<StorageTypeProvider, DirectoryProvider, RecordRepository>(
          update: (context, storageTypeProvider, directoryProvider, previousRepository) {
            if (storageTypeProvider.currentStorageType == StorageType.sqlite) {
              // Initialize SQLite repository and ensure DB is ready
              DatabaseHelper.instance.getDb(); // This ensures the DB is initialized
              return SqliteRecordRepository();
            } else {
              // Initialize FileSystem repository
              return FileSystemRecordRepository(directoryProvider);
            }
          },
        ),
      ],
      child: const PARecorderApp(),
    );
  }
}

class PARecorderApp extends StatelessWidget {
  const PARecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasHello = context.watch<HelloProvider>().hasHello;
    return MaterialApp(
      title: 'PA Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
        fontFamily: 'JFOpenshuninn',
      ),
      initialRoute: hasHello ? '/' : HelloPage.routeName,
      routes: {
        '/': (context) => const AdaptiveNavigationScaffold(),
        HelloPage.routeName: (context) => const HelloPage(),
      },
    );
  }
}
