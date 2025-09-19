import 'dart:io';

abstract class RecordRepository {
  Future<List<Record>> getAllRecords();
  Future<Record?> getRecordById(String id); // Assuming record ID is the directory name
  Future<void> createRecord(Record record);
  Future<void> updateRecordContent(String id, String content);
  // Potentially add deleteRecord, updateRecordMetadata if needed later
}

// A simple data class to represent a record
class Record {
  final String id; // Directory name
  final String title;
  final String content;
  final Map<String, String> metadata; // From index.ini
  final Directory? directory; // Reference to the record's directory, now nullable

  Record({
    required this.id,
    required this.title,
    required this.content,
    required this.metadata,
    this.directory, // Made optional
  });
}
