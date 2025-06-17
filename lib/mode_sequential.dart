import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ModeSequential extends StatefulWidget {
  const ModeSequential({super.key});

  @override
  State<ModeSequential> createState() => _ModeSequentialState();
}

class _ModeSequentialState extends State<ModeSequential> {
  final List<Map<String, dynamic>> _colors = [
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

  int _currentIndex = 0;
  final AudioPlayer _player = AudioPlayer();
  bool _clearPlayed = false;

  @override
  void initState() {
    super.initState();
    _playCurrentColor(); // 最初の音を再生
  }

  Future<void> _playCurrentColor() async {
    final label = _colors[_currentIndex]['label'] as String;
    final filename = _labelToFilename[label] ?? 'default';

    await _player.stop();
    await _player.play(AssetSource('sounds/$filename.mp3'));
  }

  void _nextColor() async {
    if (_currentIndex < _colors.length - 1) {
      setState(() {
        _currentIndex++;
      });
      await _playCurrentColor();
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
        title: const Text('おめでとう！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/clear.png'),
            const SizedBox(height: 10),
            const Text('ぜんぶのいろをクリアしたよ！'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _clearPlayed = false;
              });
              _playCurrentColor(); // 最初から再生
            },
            child: const Text('もういちどあそぶ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログ閉じる
              Navigator.pop(context); // ホームに戻る
            },
            child: const Text('メニューにもどる'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _colors[_currentIndex];
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
