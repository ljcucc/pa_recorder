import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:path/path.dart' as p;

class RecordDetailPage extends StatefulWidget {
  final Directory recordDirectory;

  const RecordDetailPage({super.key, required this.recordDirectory});

  @override
  _RecordDetailPageState createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  Map<String, String> _properties = {};
  String _content = '';

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final iniFile = File(p.join(widget.recordDirectory.path, 'index.ini'));
    final contentFile = File(p.join(widget.recordDirectory.path, 'content.md'));

    if (await iniFile.exists()) {
      final config = Config.fromStrings(await iniFile.readAsLines());
      setState(() {
        _properties = (config.items('properties') ?? []).fold<Map<String, String>>(
          {},
          (map, item) {
            if (item.length >= 2 && item[0] != null) {
              map[item[0]!] = item[1] ?? '';
            }
            return map;
          },
        );
      });
    }

    if (await contentFile.exists()) {
      setState(() {
        _content = contentFile.readAsStringSync();
      });
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
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ..._properties.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  );
                }).toList(),
                const Divider(),
                const Text('Content:'),
                Text(_content),
              ],
            ),
    );
  }
}
