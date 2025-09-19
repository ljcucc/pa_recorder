import 'package:flutter/material.dart';
import 'package:pa_recorder/pages/browse_records_page.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/pages/new_record_page.dart';
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final directoryProvider = context.watch<DirectoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PA Recorder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () =>
                context.read<DirectoryProvider>().selectDirectory(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (directoryProvider.directoryPath == null)
              const Text('Please select a logseq-pa directory.')
            else ...[
              Text('logseq-pa path: ${directoryProvider.directoryPath}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewRecordPage(),
                    ),
                  );
                },
                child: const Text('New Record'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrowseRecordsPage(),
                    ),
                  );
                },
                child: const Text('Browse Records'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
