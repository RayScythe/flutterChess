enum ChessPieceType { king, queen, rook, bishop, knight, pawn }

class ChessPiece {
  ChessPiece({required this.type, required this.imagePath, required this.isWhite});
  final ChessPieceType type;
  final String imagePath;
  final bool isWhite;
}
