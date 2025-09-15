import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/record_detail_page.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class BrowseRecordsPage extends StatefulWidget {
  const BrowseRecordsPage({super.key});

  @override
  _BrowseRecordsPageState createState() => _BrowseRecordsPageState();
}

class _BrowseRecordsPageState extends State<BrowseRecordsPage> {
  List<Directory> _recordDirectories = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecordDirectories();
  }

  Future<void> _loadRecordDirectories() async {
    final directoryProvider = context.read<DirectoryProvider>();
    final logseqPaPath = directoryProvider.directoryPath;

    if (logseqPaPath == null) {
      if (mounted) {
        setState(() {
          _recordDirectories = [];
        });
      }
      return;
    }

    final recordsDir = Directory(p.join(logseqPaPath, 'assets', 'pa-records'));

    if (await recordsDir.exists()) {
      final directories = await recordsDir.list().where((item) => item is Directory).cast<Directory>().toList();
      directories.sort((a, b) => b.path.compareTo(a.path)); // Sort by name, descending
      if (mounted) {
        setState(() {
          _recordDirectories = directories;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _recordDirectories = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final directoryProvider = context.watch<DirectoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              await context.read<DirectoryProvider>().selectDirectory();
              // The provider will notify listeners, and the UI will rebuild automatically.
              // We can also call _loadRecordDirectories to be explicit.
              _loadRecordDirectories();
            },
          ),
        ],
      ),
      body: directoryProvider.directoryPath == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please select a logseq-pa directory.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await context.read<DirectoryProvider>().selectDirectory();
                      _loadRecordDirectories();
                    },
                    child: const Text('Select Directory'),
                  ),
                ],
              ),
            )
          : _recordDirectories.isEmpty
              ? const Center(child: Text('No records found in the selected directory.'))
              : ListView.builder(
                  itemCount: _recordDirectories.length,
                  itemBuilder: (context, index) {
                    final directory = _recordDirectories[index];
                    final directoryName = p.basename(directory.path);
                    return ListTile(
                      title: Text(directoryName),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordDetailPage(recordDirectory: directory),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
