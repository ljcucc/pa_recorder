import 'dart:io';
import 'package:flutter/material.dart';

class EditRecordPage extends StatefulWidget {
  final File contentFile;

  const EditRecordPage({super.key, required this.contentFile});

  @override
  _EditRecordPageState createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  String _initialContent = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      if (await widget.contentFile.exists()) {
        final content = await widget.contentFile.readAsString();
        setState(() {
          _initialContent = content;
          _textController.text = content;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load content: $e')),
      );
    }
  }

  Future<void> _saveContent() async {
    try {
      await widget.contentFile.writeAsString(_textController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record saved successfully!')),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
