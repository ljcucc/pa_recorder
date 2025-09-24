import 'package:flutter_test/flutter_test.dart';
import 'package:pa_recorder/data/record_repository.dart';
import 'package:pa_recorder/data/sqlite_record_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  // Set the database factory to the FFI factory
  databaseFactory = databaseFactoryFfi;

  late SqliteRecordRepository repository;
  late Database database;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await _createTables(database);
    repository = SqliteRecordRepository();
    DatabaseHelper.instance.setDb(database);
  });

  tearDown(() async {
    await database.close();
    DatabaseHelper.instance.setDb(null);
  });

  test('createRecord and getRecordById', () async {
    final record = Record(
      id: '1',
      title: 'Test Title',
      content: 'Test Content',
      metadata: {
        'section1': {'key1': 'value1'}
      },
    );

    await repository.createRecord(record);
    final retrievedRecord = await repository.getRecordById('1');

    expect(retrievedRecord, isNotNull);
    expect(retrievedRecord!.title, 'Test Title');
    expect(retrievedRecord.content, 'Test Content');
    expect(retrievedRecord.metadata['section1']?['key1'], 'value1');
  });

  test('getAllRecords', () async {
    final record1 = Record(id: '1', title: 'Title 1', content: 'Content 1', metadata: {});
    final record2 = Record(id: '2', title: 'Title 2', content: 'Content 2', metadata: {});

    await repository.createRecord(record1);
    await repository.createRecord(record2);

    final records = await repository.getAllRecords();

    expect(records.length, 2);
    expect(records.any((r) => r.id == '1'), isTrue);
    expect(records.any((r) => r.id == '2'), isTrue);
  });

  test('updateRecordContent', () async {
    final record = Record(id: '1', title: 'Test Title', content: 'Initial Content', metadata: {});
    await repository.createRecord(record);

    await repository.updateRecordContent('1', 'Updated Content');
    final updatedRecord = await repository.getRecordById('1');

    expect(updatedRecord, isNotNull);
    expect(updatedRecord!.content, 'Updated Content');
  });

  test('getRecordById returns null for non-existent record', () async {
    final record = await repository.getRecordById('non-existent-id');
    expect(record, isNull);
  });
}

Future<void> _createTables(Database db) async {
  await db.execute('''
    CREATE TABLE records (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE metadata (
      record_id TEXT NOT NULL,
      section TEXT NOT NULL,
      key TEXT NOT NULL,
      value TEXT NOT NULL,
      PRIMARY KEY (record_id, section, key),
      FOREIGN KEY (record_id) REFERENCES records (id) ON DELETE CASCADE
    )
  ''');
}
