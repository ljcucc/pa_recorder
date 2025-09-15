import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;

import 'edit_record_page.dart';

class RecordDetailPage extends StatefulWidget {
  final Directory recordDirectory;

  const RecordDetailPage({super.key, required this.recordDirectory});

  @override
  _RecordDetailPageState createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  Map<String, String> _properties = {};
  String _content = '';
  File? _contentFile;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final iniFile = File(p.join(widget.recordDirectory.path, 'index.ini'));
    _contentFile = File(p.join(widget.recordDirectory.path, 'content.md'));

    Map<String, String> properties = {};
    if (await iniFile.exists()) {
      final config = Config.fromStrings(await iniFile.readAsLines());
      properties = (config.items('properties') ?? []).fold<Map<String, String>>(
        {},
        (map, item) {
          if (item.length >= 2 && item[0] != null) {
            map[item[0]!] = item[1] ?? '';
          }
          return map;
        },
      );
    }

    String content = '';
    if (await _contentFile!.exists()) {
      content = await _contentFile!.readAsString();
    }

    if (mounted) {
      setState(() {
        _properties = properties;
        _content = content;
      });
    }
  }

  void _navigateToEditPage() async {
    if (_contentFile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecordPage(contentFile: _contentFile!),
      ),
    );

    if (result == true) {
      _loadRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_properties['pa-title'] ?? 'Record'),
      ),
      body: _properties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadRecord,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ..._properties.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value),
              );
            }).toList(),
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
