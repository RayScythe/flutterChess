import 'package:chess/models/piece.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  const Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValid,
      required this.canCapture});

  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValid;
  final bool canCapture;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if (isSelected) {
      squareColor = Colors.green;
    } else if (canCapture) {
      squareColor = Colors.red[400];
    } else if (isValid) {
      squareColor = Colors.green[200];
    } else {
      squareColor = isWhite ? Colors.grey[200] : Colors.grey[500];
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValid ? 8 : 0),
        child: piece != null ? Image.asset(piece!.imagePath) : null,
      ),
    );
  }
}
