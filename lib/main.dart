import 'package:flutter/material.dart';
import 'package:chess/screens/chess.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FlutterChess',
      debugShowCheckedModeBanner: false,
      home: ChessScreen(),
    );
  }
}