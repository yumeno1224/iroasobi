import 'package:flutter/material.dart'; 
import 'mode_sequential.dart';
import 'mode_random.dart';
import 'mode_quiz.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('いろあそび')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('じゅんばんモード'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModeSequential(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16), // ボタン間の余白
            ElevatedButton(
              child: const Text('ばらばらモード'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModeRandomTen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16), // ここも余白
            ElevatedButton(
              child: const Text('クイズモード'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModeQuiz(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ); // ← return される Scaffold の終わり
  }
}
