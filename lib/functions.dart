bool isWhite({required index}) {
  int x = index ~/ 8, y = index % 8; // x = rows and y = columns
  bool isWhite = (x + y) % 2 == 0;
  if (isWhite) {
    return true;
  } else {
    return false;
  }
}

bool isInBoard(int row, int col) {
  return (row >= 0 && row < 8 && col >= 0 && col < 8);
}
