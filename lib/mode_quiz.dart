import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ModeQuiz extends StatefulWidget {
  const ModeQuiz({Key? key}) : super(key: key);

  @override
  _ModeQuizState createState() => _ModeQuizState();
}

class _ModeQuizState extends State<ModeQuiz> {
  final Map<String, Color> colorMap = {
    'あか': Colors.red,
    'あお': Colors.blue,
    'きいろ': Colors.yellow,
    'みどり': Colors.green,
    'くろ': Colors.black,
    'しろ': Colors.white,
    'ピンク': Colors.pink.shade100,
    'オレンジ': Colors.orange,
    'むらさき': Colors.purple,
    'ちゃいろ': Colors.brown,
    'はいいろ': Colors.grey,
  };

  final Map<String, String> soundMap = {
    'あか': 'sounds/aka.mp3',
    'あお': 'sounds/ao.mp3',
    'きいろ': 'sounds/kiiro.mp3',
    'みどり': 'sounds/midori.mp3',
    'くろ': 'sounds/kuro.mp3',
    'しろ': 'sounds/shiro.mp3',
    'ピンク': 'sounds/pink.mp3',
    'オレンジ': 'sounds/orange.mp3',
    'むらさき': 'sounds/murasaki.mp3',
    'ちゃいろ': 'sounds/chairo.mp3',
    'はいいろ': 'sounds/haiiro.mp3',
  };

  final AudioPlayer labelPlayer = AudioPlayer();
  final AudioPlayer resultPlayer = AudioPlayer();

  late String correctColorName;
  late List<String> options;
  List<String> remainingColors = [];
  int totalQuestions = 0;
  int totalCorrect = 0;
  bool isQuizFinished = false;
  bool isWaiting = false;
  String? feedback;

  @override
  void initState() {
    super.initState();
    remainingColors = colorMap.keys.toList();
    _generateNewCard();
  }

  void _generateNewCard() {
    final random = Random();
    if (remainingColors.isEmpty) return;

    correctColorName = remainingColors.removeAt(random.nextInt(remainingColors.length));

    options = [correctColorName];
    final otherOptions = colorMap.keys.where((c) => c != correctColorName).toList();
    while (options.length < 3) {
      String option = otherOptions[random.nextInt(otherOptions.length)];
      if (!options.contains(option)) {
        options.add(option);
      }
    }
    options.shuffle();
    feedback = null;
  }

  void _checkAnswer(String selected) async {
    if (isQuizFinished || isWaiting) return;
    isWaiting = true;

    if (selected == correctColorName) {
      await resultPlayer.play(AssetSource('sounds/pinpon.mp3'));
      setState(() {
        feedback = '○　すごいね！';
        totalCorrect++;
      });
    } else {
      await resultPlayer.play(AssetSource('sounds/bubuu.mp3'));
      setState(() {
        feedback = '×';
      });
    }

    totalQuestions++;

   Future.delayed(const Duration(seconds: 2), () async {
  if (totalQuestions >= 10) {
    final isPerfect = totalCorrect == 10;
    final imagePath = isPerfect
        ? 'assets/images/clear.png'
        : 'assets/images/goodjob.png';
    final soundPath = isPerfect
        ? 'sounds/clear.mp3'
        : 'sounds/goodjob.mp3';

    // 音を再生（非同期）
    resultPlayer.play(AssetSource(soundPath));

    // ダイアログ表示
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('せいかい: $totalCorrect / 10',
                    style: const TextStyle(fontSize: 28, color: Colors.black)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ダイアログを閉じる
                    setState(() {
                      totalCorrect = 0;
                      totalQuestions = 0;
                      isQuizFinished = false;
                      remainingColors = colorMap.keys.toList();
                      _generateNewCard();
                    });
                  },
                  child: const Text('もういちどあそぶ'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ダイアログを閉じる
                    Navigator.of(context).pop(); // メニューに戻る
                  },
                  child: const Text('メニューにもどる'),
                ),
              ],
            ),
          )
        ],
      ),
    );

    // ダイアログ閉じたあとは終了フラグ不要
    // isQuizFinished = true; ←これ削除してOK
    isWaiting = false;
  } else {
    setState(() {
      _generateNewCard();
      isWaiting = false;
    });
  }
});
}

  Future<void> _playLabelSound(String label) async {
    if (isWaiting || isQuizFinished) return;
    await labelPlayer.stop();
    final path = soundMap[label];
    if (path != null) {
      await labelPlayer.play(AssetSource(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: isQuizFinished
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('おわり！', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 16),
                  Text('せいかい: $totalCorrect / 10', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        totalCorrect = 0;
                        totalQuestions = 0;
                        isQuizFinished = false;
                        remainingColors = colorMap.keys.toList();
                        _generateNewCard();
                      });
                    },
                    child: const Text('もういちどあそぶ'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('メニューにもどる'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(10, (index) {
                      bool filled = index < totalQuestions;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? Colors.deepPurple : Colors.grey[300],
                          border: Border.all(color: Colors.grey),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  const Text('なにいろ？', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    color: colorMap[correctColorName],
                  ),
                  const SizedBox(height: 20),
                  ...options.map((opt) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: MouseRegion(
                          onEnter: (_) => _playLabelSound(opt),
                          child: ElevatedButton(
                            onPressed: () => _checkAnswer(opt),
                            child: Text(opt, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      )),
                  if (feedback != null) ...[
                    const SizedBox(height: 20),
                    Text(feedback!,
                        style: const TextStyle(
                            fontSize: 24, color: Colors.deepPurple)),
                  ],
                ],
              ),
      ),
    );
  }
}
