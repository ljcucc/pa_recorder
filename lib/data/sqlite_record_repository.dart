import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'record_repository.dart';

class SqliteRecordRepository implements RecordRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> createRecord(Record record) async {
    final db = await _dbHelper.getDb();
    await db.transaction((txn) async {
      await txn.insert('records', {
        'id': record.id,
        'title': record.title,
        'content': record.content,
      });
      for (final sectionEntry in record.metadata.entries) {
        for (final metadataEntry in sectionEntry.value.entries) {
          await txn.insert('metadata', {
            'record_id': record.id,
            'section': sectionEntry.key,
            'key': metadataEntry.key,
            'value': metadataEntry.value,
          });
        }
      }
    });
  }

  @override
  Future<List<Record>> getAllRecords() async {
    final db = await _dbHelper.getDb();
    final List<Map<String, dynamic>> recordMaps = await db.query('records');
    
    final List<Record> records = [];
    for (final recordMap in recordMaps) {
      final record = await _mapToRecord(db, recordMap);
      records.add(record);
    }
    return records;
  }

  @override
  Future<Record?> getRecordById(String id) async {
    final db = await _dbHelper.getDb();
    final List<Map<String, dynamic>> recordMaps = await db.query(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (recordMaps.isNotEmpty) {
      return await _mapToRecord(db, recordMaps.first);
    }
    return null;
  }

  @override
  Future<void> updateRecordContent(String id, String content) async {
    final db = await _dbHelper.getDb();
    await db.update(
      'records',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Record> _mapToRecord(DatabaseExecutor db, Map<String, dynamic> recordMap) async {
    final List<Map<String, dynamic>> metadataMaps = await db.query(
      'metadata',
      where: 'record_id = ?',
      whereArgs: [recordMap['id']],
    );

    final metadata = <String, Map<String, String>>{};
    for (final metaMap in metadataMaps) {
      final section = metaMap['section'] as String;
      final key = metaMap['key'] as String;
      final value = metaMap['value'] as String;
      metadata.putIfAbsent(section, () => {})[key] = value;
    }

    return Record(
      id: recordMap['id'],
      title: recordMap['title'],
      content: recordMap['content'],
      metadata: metadata,
      directory: null, // Not applicable for SQLite implementation
    );
  }
}

class DatabaseHelper {
  static const _databaseName = "records.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> getDb() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  void setDb(Database? db) {
    _database = db;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
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
}
