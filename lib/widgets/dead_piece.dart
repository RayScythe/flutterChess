import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  const DeadPiece({super.key, required this.imagePath});
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Image.asset(
        imagePath,
      ),
    );
  }
}
