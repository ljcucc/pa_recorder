import 'package:flutter/material.dart';

class HADSQuestion {
  final String scale;
  final String text;
  final List<Map<String, Object>> choices;

  HADSQuestion({required this.scale, required this.text, required this.choices});
}

final List<HADSQuestion> hadsQuestions = [
  HADSQuestion(scale: "A", text: "我感到緊張或「精神緊繃」：", choices: [
    {"score": 3, "text": "大部分時間"},
    {"score": 2, "text": "很多時間"},
    {"score": 1, "text": "時常，偶爾"},
    {"score": 0, "text": "完全沒有"}
  ]),
  HADSQuestion(scale: "A", text: "我會感到莫名的恐懼，好像「心裡七上八下」的感覺：", choices: [
    {"score": 0, "text": "完全沒有"},
    {"score": 1, "text": "偶爾"},
    {"score": 2, "text": "相當頻繁"},
    {"score": 3, "text": "非常頻繁"}
  ]),
  HADSQuestion(scale: "A", text: "我有一種恐懼的感覺，好像有可怕的事情要發生：", choices: [
    {"score": 3, "text": "非常肯定且相當嚴重"},
    {"score": 2, "text": "是的，但不太嚴重"},
    {"score": 1, "text": "有一點，但我不擔心"},
    {"score": 0, "text": "完全沒有"}
  ]),
  HADSQuestion(scale: "A", text: "我感到煩躁不安，好像必須要動個不停：", choices: [
    {"score": 3, "text": "確實非常嚴重"},
    {"score": 2, "text": "相當多"},
    {"score": 1, "text": "不太嚴重"},
    {"score": 0, "text": "完全沒有"}
  ]),
  HADSQuestion(scale: "A", text: "擔憂的念頭縈繞在我腦海中：", choices: [
    {"score": 3, "text": "絕大部分時間"},
    {"score": 2, "text": "很多時間"},
    {"score": 1, "text": "時常，但不太頻繁"},
    {"score": 0, "text": "只有偶爾"}
  ]),
  HADSQuestion(scale: "A", text: "我會突然感到恐慌：", choices: [
    {"score": 3, "text": "確實非常頻繁"},
    {"score": 2, "text": "相當頻繁"},
    {"score": 1, "text": "不常"},
    {"score": 0, "text": "完全沒有"}
  ]),
  HADSQuestion(scale: "A", text: "我能夠安坐並感到放鬆：", choices: [
    {"score": 0, "text": "當然可以"},
    {"score": 1, "text": "通常可以"},
    {"score": 2, "text": "不常"},
    {"score": 3, "text": "完全不能"}
  ]),
  HADSQuestion(scale: "D", text: "我感覺自己好像慢了下來：", choices: [
    {"score": 3, "text": "幾乎所有時間"},
    {"score": 2, "text": "很頻繁"},
    {"score": 1, "text": "有時候"},
    {"score": 0, "text": "完全沒有"}
  ]),
  HADSQuestion(scale: "D", text: "我仍然能享受我過去喜歡做的事：", choices: [
    {"score": 0, "text": "當然和以前一樣"},
    {"score": 1, "text": "不像以前那麼多"},
    {"score": 2, "text": "只有一點點"},
    {"score": 3, "text": "幾乎完全不能"}
  ]),
  HADSQuestion(scale: "D", text: "我對自己的外表失去了興趣：", choices: [
    {"score": 3, "text": "完全是"},
    {"score": 2, "text": "我沒有像我應該的那樣在意"},
    {"score": 1, "text": "我可能沒有那麼在意"},
    {"score": 0, "text": "我和以前一樣在意"}
  ]),
  HADSQuestion(scale: "D", text: "我能夠開懷大笑並看到事情有趣的一面：", choices: [
    {"score": 0, "text": "和以前一樣"},
    {"score": 1, "text": "現在不像以前那麼多了"},
    {"score": 2, "text": "現在肯定沒那麼多了"},
    {"score": 3, "text": "完全不能"}
  ]),
  HADSQuestion(scale: "D", text: "我能愉快地期待事情：", choices: [
    {"score": 0, "text": "和以前一樣"},
    {"score": 1, "text": "比以前少一些"},
    {"score": 2, "text": "肯定比以前少"},
    {"score": 3, "text": "幾乎完全不能"}
  ]),
  HADSQuestion(scale: "D", text: "我感到心情愉快：", choices: [
    {"score": 3, "text": "完全沒有"},
    {"score": 2, "text": "不常"},
    {"score": 1, "text": "有時候"},
    {"score": 0, "text": "大部分時間"}
  ]),
  HADSQuestion(scale: "D", text: "我能享受一本好書、廣播或電視節目：", choices: [
    {"score": 0, "text": "時常"},
    {"score": 1, "text": "有時候"},
    {"score": 2, "text": "不常"},
    {"score": 3, "text": "極少"}
  ]),
];

class HADSQuestionnaire extends StatefulWidget {
  final Function(Map<String, int>) onCompleted;

  const HADSQuestionnaire({super.key, required this.onCompleted});

  @override
  HADSQuestionnaireState createState() => HADSQuestionnaireState();
}

class HADSQuestionnaireState extends State<HADSQuestionnaire> {
  final List<HADSQuestion> _questions = List.from(hadsQuestions)..shuffle();
  final Map<int, int> _answers = {};
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= _questions.length) {
      return _buildResult();
    }

    final question = _questions[_currentQuestionIndex];
    final shuffledChoices = List.from(question.choices)..shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HADS Questionnaire (${_currentQuestionIndex + 1}/${_questions.length})'),
        const SizedBox(height: 10),
        Text(question.text),
        const SizedBox(height: 10),
        ...shuffledChoices.map((choice) {
          final score = choice['score'] as int;
          final text = choice['text'] as String;
          return ListTile(
            title: Text(text),
            leading: Radio<int>(
              value: score,
              groupValue: _answers[_currentQuestionIndex],
              onChanged: (int? newValue) {
                setState(() {
                  _answers[_currentQuestionIndex] = newValue!;
                  _nextQuestion();
                });
              },
            ),
            onTap: () {
              setState(() {
                _answers[_currentQuestionIndex] = score;
                _nextQuestion();
              });
            },
          );
        }),
      ],
    );
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _calculateResult();
    }
  }

  void _calculateResult() {
    Map<String, int> scores = {'A': 0, 'D': 0};
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final score = _answers[i]!;
      scores[question.scale] = scores[question.scale]! + score;
    }
    widget.onCompleted(scores);
  }

  Widget _buildResult() {
    // This widget will be built by the parent
    return Container();
  }
}
