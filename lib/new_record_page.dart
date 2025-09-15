import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pa_recorder/directory_provider.dart';
import 'package:pa_recorder/hads_questionnaire.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class NewRecordPage extends StatefulWidget {
  const NewRecordPage({super.key});

  @override
  _NewRecordPageState createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
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

  final List<String> _factors = ["工作", "家庭", "健康", "人際關係", "金錢", "天氣", "休閒活動", "學校", "其他"];

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
            ElevatedButton(
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
      value: _mood,
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
      value: _factor,
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
      return ElevatedButton(
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

      final directoryProvider = context.read<DirectoryProvider>();
      final logseqPaPath = directoryProvider.directoryPath;

      if (logseqPaPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a directory first.')),
        );
        return;
      }

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final folderStr = DateFormat('yyyy-MM-dd-HH_mm').format(now);
      
      final outputDir = Directory(p.join(logseqPaPath, 'assets', 'pa-records', folderStr));

      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final iniContent = _generateIniContent(dateStr, now);
      final iniFile = File(p.join(outputDir.path, 'index.ini'));
      await iniFile.writeAsString(iniContent);

      final contentFile = File(p.join(outputDir.path, 'content.md'));
      await contentFile.writeAsString('- Enter content here\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record saved to ${outputDir.path}')),
      );

      Navigator.pop(context);
    }
  }

  String _generateIniContent(String dateStr, DateTime now) {
    final properties = {
      'template': 'pa-record',
      'pa-title': _title,
      'pa-date': '[[$dateStr]]',
      'pa-time': DateFormat('HH:mm').format(now),
      'pa-mood': '[[pa-mood/${_moodScale[_mood]!}]]',
      'pa-emotions': _emotions.map((e) => '[[pa-emotions/$e]]').join(', '),
      'pa-factor': '[[pa-factor/$_factor]]',
      'pa-type': 'personal'
    };

    if (_hadsScores != null) {
      properties['pa-hads-a'] = _hadsScores!['A'].toString();
      properties['pa-hads-d'] = _hadsScores!['D'].toString();
      properties['pa-type'] = 'personal [[pa-type/Clinical]]';
    }

    final buffer = StringBuffer();
    buffer.writeln('[header]');
    buffer.writeln('template = pa-record');
    buffer.writeln('[properties]');
    properties.forEach((key, value) {
      if (key != 'template') {
        buffer.writeln('$key = $value');
      }
    });

    return buffer.toString();
  }
}