import 'package:flutter/material.dart';
import 'package:pa_recorder/pages/browse_records_page.dart';
import 'package:pa_recorder/directory_provider.dart';

import 'package:pa_recorder/data/record_repository.dart';
import 'package:pa_recorder/data/file_system_record_repository.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DirectoryProvider()),
        Provider<RecordRepository>(
          create: (context) => FileSystemRecordRepository(
            context.read<DirectoryProvider>(),
          ),
        ),
      ],
      child: const PARecorderApp(),
    ),
  );
}

class PARecorderApp extends StatelessWidget {
  const PARecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PA Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BrowseRecordsPage(),
    );
  }
}


