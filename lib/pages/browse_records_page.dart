import 'package:flutter/material.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/pages/record_detail_page.dart';
import 'package:pa_recorder/data/record_repository.dart'; // New import
import 'package:provider/provider.dart';

class BrowseRecordsPage extends StatefulWidget {
  const BrowseRecordsPage({super.key});

  @override
  BrowseRecordsPageState createState() => BrowseRecordsPageState();
}

class BrowseRecordsPageState extends State<BrowseRecordsPage> {
  List<Record> _records = []; // Changed from List<Directory>

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecordDirectories();
  }

  Future<void> _loadRecordDirectories() async {
    final recordRepository = context.read<RecordRepository>();
    final directoryProvider = context.read<DirectoryProvider>();

    if (directoryProvider.directoryPath == null) {
      if (mounted) {
        setState(() {
          _records = [];
        });
      }
      return;
    }

    final fetchedRecords = await recordRepository.getAllRecords();
    _records = [];
    if (mounted) {
      setState(() {
        _records = fetchedRecords;
      });
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
          : _records.isEmpty
              ? const Center(
                  child: Text('No records found in the selected directory.'))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return ListTile(
                      title: Text(record.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecordDetailPage(record: record),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
