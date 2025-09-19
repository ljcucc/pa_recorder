import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pa_recorder/data/record_repository.dart'; // New import
import 'package:provider/provider.dart'; // New import

import 'edit_record_page.dart';

class RecordDetailPage extends StatefulWidget {
  final Record record; // Changed from Directory recordDirectory

  const RecordDetailPage({super.key, required this.record});

  @override
  RecordDetailPageState createState() => RecordDetailPageState();
}

class RecordDetailPageState extends State<RecordDetailPage> {
  late Map<String, String> _properties;
  late String _content;

  @override
  void initState() {
    super.initState();
    _properties = widget.record.metadata;
    _content = widget.record.content;
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecordPage(record: widget.record),
      ),
    );

    if (result == true) {
      if (!mounted) return; // Add this check
      final recordRepository = context.read<RecordRepository>();
      final updatedRecord =
          await recordRepository.getRecordById(widget.record.id);
      if (updatedRecord != null && mounted) {
        setState(() {
          _properties = updatedRecord.metadata;
          _content = updatedRecord.content;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_properties['pa-title'] ?? 'Record'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!mounted) return; // Add this check
          final recordRepository = context.read<RecordRepository>();
          final updatedRecord =
              await recordRepository.getRecordById(widget.record.id);
          if (updatedRecord != null && mounted) {
            setState(() {
              _properties = updatedRecord.metadata;
              _content = updatedRecord.content;
            });
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ..._properties.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value),
              );
            }), // Removed .toList()
            const Divider(),
            MarkdownBody(
              data: _content,
              selectable: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEditPage,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
