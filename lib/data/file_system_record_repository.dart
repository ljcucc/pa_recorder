import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ini/ini.dart';

import 'package:pa_recorder/data/record_repository.dart';
import 'package:pa_recorder/directory_provider.dart'; // Import DirectoryProvider

class FileSystemRecordRepository implements RecordRepository {
  final DirectoryProvider _directoryProvider;

  FileSystemRecordRepository(this._directoryProvider);

  String? get _logseqPaPath => _directoryProvider.directoryPath;

  @override
  Future<List<Record>> getAllRecords() async {
    if (_logseqPaPath == null) {
      return []; // No directory selected
    }
    final recordsDir = Directory(p.join(_logseqPaPath!, 'assets', 'pa-records'));
    if (!await recordsDir.exists()) {
      return [];
    }

    final directories = await recordsDir.list().where((item) => item is Directory).cast<Directory>().toList();

    final List<Record> records = [];
    for (final dir in directories) {
      final id = dir.uri.pathSegments.where((e) => e.isNotEmpty).last;
      final iniFile = File(p.join(dir.path, 'index.ini'));
      final contentFile = File(p.join(dir.path, 'pa-records___${id}___content.md'));

      String title = id; // Default title
      Map<String, Map<String, String>> metadata = {};
      if (await iniFile.exists()) {
        final config = Config.fromStrings(await iniFile.readAsLines());
        for (final section in config.sections()) {
          metadata[section] = {};
          for (final item in config.items(section) ?? []) {
            if (item.length == 2 && item[0] != null && item[1] != null) {
              metadata[section]![item[0]!] = item[1]!;
            }
          }
        }
        title = metadata['properties']?['pa-title'] ?? id;
      }

      String content = '';
      if (await contentFile.exists()) {
        content = await contentFile.readAsString();
      }

      records.add(Record(
        id: id,
        title: title,
        content: content,
        metadata: metadata,
        directory: dir,
      ));
    }
    return records;
  }

  @override
  Future<Record?> getRecordById(String id) async {
    if (_logseqPaPath == null) {
      return null; // No directory selected
    }
    final recordDirPath = p.join(_logseqPaPath!, 'assets', 'pa-records', id);
    final recordDir = Directory(recordDirPath);

    if (!await recordDir.exists()) {
      return null;
    }

    final iniFile = File(p.join(recordDir.path, 'index.ini'));
    final contentFile = File(p.join(recordDir.path, 'pa-records___${id}___content.md'));

    String title = id;
    Map<String, Map<String, String>> metadata = {};
    if (await iniFile.exists()) {
      final config = Config.fromStrings(await iniFile.readAsLines());
      for (final section in config.sections()) {
        metadata[section] = {};
        for (final item in config.items(section) ?? []) {
          if (item.length == 2 && item[0] != null && item[1] != null) {
            metadata[section]![item[0]!] = item[1]!;
          }
        }
      }
      title = metadata['properties']?['pa-title'] ?? id;
    }

    String content = '';
    if (await contentFile.exists()) {
      content = await contentFile.readAsString();
    }

    return Record(
      id: id,
      title: title,
      content: content,
      metadata: metadata,
      directory: recordDir,
    );
  }

  @override
  Future<void> createRecord(Record record) async {
    if (_logseqPaPath == null) {
      throw Exception('Logseq PA directory not selected.');
    }
    final outputDir = Directory(p.join(_logseqPaPath!, 'assets', 'pa-records', record.id));
    await outputDir.create(recursive: true);

    final iniFile = File(p.join(outputDir.path, 'index.ini'));
    final StringBuffer buffer = StringBuffer();
    record.metadata.forEach((section, properties) {
      buffer.writeln('[$section]');
      properties.forEach((key, value) {
        buffer.writeln('$key = $value');
      });
    });
    await iniFile.writeAsString(buffer.toString());

    final contentFile = File(p.join(outputDir.path, 'pa-records___${record.id}___content.md'));
    await contentFile.writeAsString(record.content);
  }

  @override
  Future<void> updateRecordContent(String id, String content) async {
    if (_logseqPaPath == null) {
      throw Exception('Logseq PA directory not selected.');
    }
    final recordDirPath = p.join(_logseqPaPath!, 'assets', 'pa-records', id);
    final contentFile = File(p.join(recordDirPath, 'pa-records___${id}___content.md'));
    if (await contentFile.exists()) {
      await contentFile.writeAsString(content);
    } else {
      throw Exception('Content file for record $id not found.');
    }
  }
}
