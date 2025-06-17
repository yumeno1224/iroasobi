import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class ModeRandomTen extends StatefulWidget {
  const ModeRandomTen({super.key});

  @override
  State<ModeRandomTen> createState() => _ModeRandomTenState();
}

class _ModeRandomTenState extends State<ModeRandomTen> {
  final List<Map<String, dynamic>> _allColors = [
    {'color': Colors.red, 'label': 'あか'},
    {'color': Colors.orange, 'label': 'オレンジ'},
    {'color': Colors.yellow, 'label': 'きいろ'},
    {'color': Colors.green, 'label': 'みどり'},
    {'color': Colors.blue, 'label': 'あお'},
    {'color': Colors.white, 'label': 'しろ'},
    {'color': Colors.purple, 'label': 'むらさき'},
    {'color': Colors.pink.shade100, 'label': 'ピンク'},
    {'color': Colors.brown, 'label': 'ちゃいろ'},
    {'color': Colors.grey, 'label': 'はいいろ'},
    {'color': Colors.lightBlue, 'label': 'みずいろ'},
    {'color': Colors.black, 'label': 'くろ'},
  ];

  final Map<String, String> _labelToFilename = {
    'あか': 'aka',
    'オレンジ': 'orange',
    'きいろ': 'kiiro',
    'みどり': 'midori',
    'あお': 'ao',
    'しろ': 'shiro',
    'むらさき': 'murasaki',
    'ピンク': 'pink',
    'ちゃいろ': 'chairo',
    'はいいろ': 'haiiro',
    'みずいろ': 'mizuiro',
    'くろ': 'kuro',
  };

  late List<Map<String, dynamic>> _quizColors;
  int _currentIndex = 0;
  final AudioPlayer _player = AudioPlayer();       // 音声（色・クリア）
  final AudioPlayer _clickPlayer = AudioPlayer();  // 操作音用
  bool _clearPlayed = false;

  @override
  void initState() {
    super.initState();
    _generateRandomQuiz();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentColor(); // 最初の色の音声を再生
    });
  }

  void _generateRandomQuiz() {
    _quizColors = List<Map<String, dynamic>>.from(_allColors);
    _quizColors.shuffle(Random());
    _quizColors = _quizColors.take(10).toList();
    _currentIndex = 0;
    _clearPlayed = false;
  }

  void _playCurrentColor() async {
    final label = _quizColors[_currentIndex]['label'] as String;
    final filename = _labelToFilename[label] ?? 'default';
    await _player.stop(); // 前の音が残らないように
    await _player.play(AssetSource('sounds/$filename.mp3'));
  }

  void _nextColor() async {
    // タップ音を鳴らす
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('sounds/click.mp3'));

    // 次の色へ進むか、クリア処理
    if (_currentIndex < _quizColors.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playCurrentColor();
    } else if (!_clearPlayed) {
      _clearPlayed = true;
      await _player.play(AssetSource('sounds/clear.mp3'));
      _showClearDialog();
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ゴール！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/random_clear.png'),
            const SizedBox(height: 10),
            const Text('ぜんぶいえたかな？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _generateRandomQuiz();
                _playCurrentColor();
              });
            },
            child: const Text('もういちどあそぶ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('メニューにもどる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _quizColors[_currentIndex];
    final label = currentColor['label'] as String;
    final textColor = (label == 'くろ') ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: _nextColor,
      child: Scaffold(
        body: Container(
          color: currentColor['color'] as Color,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 48,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}