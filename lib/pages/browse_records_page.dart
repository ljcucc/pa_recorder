import 'package:flutter/material.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/pages/record_detail_page.dart';
import 'package:pa_recorder/data/record_repository.dart'; // New import
import 'package:pa_recorder/pages/new_record_page.dart';
import 'package:pa_recorder/widgets/record_list_item.dart'; // New import
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
    fetchedRecords.sort((a, b) {
      final propertiesA = a.metadata['properties'] ?? {};
      final dateA = propertiesA['pa-date'] ?? '';
      final timeA = propertiesA['pa-time'] ?? '00:00'; // Default to midnight if time is missing
      final dateTimeA = DateTime.tryParse('$dateA $timeA');

      final propertiesB = b.metadata['properties'] ?? {};
      final dateB = propertiesB['pa-date'] ?? '';
      final timeB = propertiesB['pa-time'] ?? '00:00'; // Default to midnight if time is missing
      final dateTimeB = DateTime.tryParse('$dateB $timeB');

      if (dateTimeA == null && dateTimeB == null) {
        return 0;
      } else if (dateTimeA == null) {
        return 1; // Null dates go to the end
      } else if (dateTimeB == null) {
        return -1; // Null dates go to the end
      } else {
        return dateTimeB.compareTo(dateTimeA); // Sort in descending order (newest first)
      }
    });
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

    return directoryProvider.directoryPath == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please select a logseq-pa directory.'),
                const SizedBox(height: 20),
                FilledButton.tonal(
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
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return RecordListItem(
                        record: record,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecordDetailPage(record: record),
                            ),
                          );
                          _loadRecordDirectories(); // Refresh records after returning from RecordDetailPage
                        },
                      );
                    },
                  ),
                ),
              );
  }
}
