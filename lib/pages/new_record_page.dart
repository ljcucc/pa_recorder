import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/hads_questionnaire.dart';
import 'package:pa_recorder/pages/edit_record_page.dart';
import 'package:pa_recorder/data/record_repository.dart'; // New import
import 'package:provider/provider.dart';

class NewRecordPage extends StatefulWidget {
  const NewRecordPage({super.key});

  @override
  NewRecordPageState createState() => NewRecordPageState();
}

class NewRecordPageState extends State<NewRecordPage> {
  final _formKey = GlobalKey<FormState>();
  String? _mood;
  final List<String> _emotions = [];
  String? _factor;
  String? _title;
  Map<String, int>? _hadsScores;
  bool _showHads = false;

  final Map<String, String> _moodScale = {
    "1": "非常愉快",
    "2": "愉快",
    "3": "有點愉快",
    "4": "中性",
    "5": "有點不愉快",
    "6": "不愉快",
    "7": "非常不愉快"
  };

  final List<String> _pleasantEmotions = ["開心", "興奮", "感激", "平靜", "滿足", "充滿希望"];
  final List<String> _neutralEmotions = ["淡定", "放鬆", "無聊", "平靜"];
  final List<String> _unpleasantEmotions = ["傷心", "憤怒", "焦慮", "擔憂", "疲憊", "失望"];

  final List<String> _factors = [
    "工作",
    "家庭",
    "健康",
    "人際關係",
    "金錢",
    "天氣",
    "休閒活動",
    "學校",
    "其他"
  ];

  List<String> get _currentEmotions {
    if (_mood == null) {
      return [];
    }
    int moodValue = int.parse(_mood!);
    if (moodValue <= 3) {
      return _pleasantEmotions;
    } else if (moodValue == 4) {
      return _neutralEmotions;
    } else {
      return _unpleasantEmotions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New PA Record'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTitleInput(),
            const SizedBox(height: 20),
            _buildMoodSelector(),
            const SizedBox(height: 20),
            _buildEmotionSelector(),
            const SizedBox(height: 20),
            _buildFactorSelector(),
            const SizedBox(height: 20),
            _buildHadsSection(),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: _saveRecord,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? '請輸入標題' : null,
      onSaved: (value) => _title = value,
    );
  }

  Widget _buildMoodSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _mood, // Changed from value
      hint: const Text('你現在的感覺如何？'),
      onChanged: (String? newValue) {
        setState(() {
          _mood = newValue;
          _emotions.clear();
        });
      },
      items: _moodScale.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      validator: (value) => value == null ? '請選擇一個心情' : null,
    );
  }

  Widget _buildEmotionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('哪些詞彙最能描述你現在的感覺？'),
        Wrap(
          spacing: 8.0,
          children: _currentEmotions.map((emotion) {
            return FilterChip(
              label: Text(emotion),
              selected: _emotions.contains(emotion),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _emotions.add(emotion);
                  } else {
                    _emotions.remove(emotion);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFactorSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _factor, // Changed from value
      hint: const Text('是什麼對你影響最大？'),
      onChanged: (String? newValue) {
        setState(() {
          _factor = newValue;
        });
      },
      items: _factors.map((factor) {
        return DropdownMenuItem<String>(
          value: factor,
          child: Text(factor),
        );
      }).toList(),
      validator: (value) => value == null ? '請選擇一個影響因素' : null,
    );
  }

  Widget _buildHadsSection() {
    if (_hadsScores != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HADS Scores:'),
          Text('Anxiety: ${_hadsScores!['A']}'),
          Text('Depression: ${_hadsScores!['D']}'),
        ],
      );
    } else if (_showHads) {
      return HADSQuestionnaire(
        onCompleted: (scores) {
          setState(() {
            _hadsScores = scores;
            _showHads = false;
          });
        },
      );
    } else {
      return FilledButton.tonal(
        onPressed: () {
          setState(() {
            _showHads = true;
          });
        },
        child: const Text('Take HADS Questionnaire'),
      );
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final recordRepository = context.read<RecordRepository>();
      final directoryProvider = context.read<DirectoryProvider>();

      if (directoryProvider.directoryPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a directory first.')),
        );
        return;
      }

      final now = DateTime.now();
      final folderStr = DateFormat('yyyy-MM-dd-HH_mm').format(now);

      final Map<String, Map<String, String>> metadata = _generateMetadata(now);

      final newRecord = Record(
        id: folderStr,
        title: _title ?? 'Untitled Record',
        content: '- Enter content here\n',
        metadata: metadata,
        directory: null, // Now nullable
      );

      try {
        await recordRepository.createRecord(newRecord);

        if (!mounted) return; // Check mounted before using context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record saved to ${newRecord.id}')),
        );

        if (!mounted) return; // Check mounted before using context
        Navigator.pop(context, newRecord); // Pop with the new record
      } catch (e) {
        if (!mounted) return; // Check mounted before using context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save record: $e')),
        );
        Navigator.pop(context, null); // Pop with null on failure
      }
    }
  }

  Map<String, Map<String, String>> _generateMetadata(DateTime now) {
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final Map<String, String> properties = {
      'pa-title': _title ?? 'Untitled Record',
      'pa-date': dateStr,
      'pa-time': DateFormat('HH:mm').format(now),
      'pa-mood': _moodScale[_mood]!,
      'pa-emotions': _emotions.join(', '),
      'pa-factor': _factor!,
      'pa-type': 'personal',
    };

    if (_hadsScores != null) {
      properties['pa-hads-a'] = _hadsScores!['A'].toString();
      properties['pa-hads-d'] = _hadsScores!['D'].toString();
      properties['pa-type'] = 'personal, clinical';
    }

    return {
      'header': {
        'template': 'pa-record',
        'schema': 'pa-record',
      },
      'properties': properties,
    };
  }
}
