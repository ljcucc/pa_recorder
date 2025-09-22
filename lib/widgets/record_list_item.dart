import 'package:flutter/material.dart';
import 'package:pa_recorder/data/record_repository.dart';
import 'package:intl/intl.dart'; // For date formatting

class RecordListItem extends StatelessWidget {
  final Record record;
  final VoidCallback onTap;

  const RecordListItem({
    super.key,
    required this.record,
    required this.onTap,
  });

  String _getFormattedDate(Map<String, Map<String, String>> metadata) {
    final properties = metadata['properties'] ?? {};
    final dateString = properties['pa-date'] ?? properties['date'];
    if (dateString != null && dateString.isNotEmpty) {
      try {
        // Assuming date format is YYYY-MM-DD
        final dateTime = DateTime.parse(dateString);
        return DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        // Fallback if parsing fails
        return 'Invalid Date';
      }
    }
    return 'No Date';
  }

  String _getMood(Map<String, Map<String, String>> metadata) {
    final properties = metadata['properties'] ?? {};
    return 'Mood: ${properties['pa-mood'] ?? 'N/A'}';
  }

  String _getFactor(Map<String, Map<String, String>> metadata) {
    final properties = metadata['properties'] ?? {};
    return 'Factor: ${properties['pa-factor'] ?? 'N/A'}';
  }

  String _getEmotions(Map<String, Map<String, String>> metadata) {
    final properties = metadata['properties'] ?? {};
    return 'Emotions: ${properties['pa-emotions'] ?? 'N/A'}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _getFormattedDate(record.metadata);

    return Card.filled(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          record.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              _getMood(record.metadata),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _getFactor(record.metadata),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              _getEmotions(record.metadata),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Created: $formattedDate',
              style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}