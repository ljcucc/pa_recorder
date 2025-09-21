import 'package:flutter/material.dart';
import 'package:pa_recorder/data/record_repository.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_markdown/flutter_markdown.dart'; // New import

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

  String _getContentPreview(String content, { int maxLines = 3}) {
    final lines = content.split('\n');
    if (lines.length <= maxLines) {
      return content.trim();
    }
    return '${lines.take(maxLines).join('\n').trim()}...';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _getFormattedDate(record.metadata);
    final contentPreview = _getContentPreview(record.content);

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
            MarkdownBody(
              data: contentPreview,
              shrinkWrap: true,
              softLineBreak: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: Colors.grey[700]),
              ),
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
