import 'package:flutter/material.dart';
import 'package:pa_recorder/data/record_repository.dart'; // New import
import 'package:provider/provider.dart'; // New import

class EditRecordPage extends StatefulWidget {
  final Record record; // Changed from File contentFile

  const EditRecordPage({super.key, required this.record});

  @override
  EditRecordPageState createState() => EditRecordPageState();
}

class EditRecordPageState extends State<EditRecordPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.record.content;
  }

  Future<void> _saveContent() async {
    try {
      await context.read<RecordRepository>().updateRecordContent(
            widget.record.id,
            _textController.text,
          );
      if (!mounted) return; // Check mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record saved successfully!')),
      );
      if (!mounted) return; // Check mounted before using context
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return; // Check mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save content: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveContent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          maxLines: null, // Allows for multiline input
          expands: true, // Expands to fill the available space
          decoration: const InputDecoration(
            hintText: 'Enter your content here...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
