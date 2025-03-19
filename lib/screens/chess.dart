import 'package:chess/functions.dart';
import 'package:chess/widgets/dead_piece.dart';
import 'package:chess/models/piece.dart';
import 'package:chess/widgets/square.dart';
import 'package:flutter/material.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1, selectedCol = -1;
  List<List<int>> validMoves = [];
  List<ChessPiece> whiteTakenPieces = [];
  List<ChessPiece> blackTakenPieces = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;
  bool stalemateStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));

    //initialize pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] =
          ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'lib/images/black-pieces/BlackPawn.png');
      newBoard[6][i] =
          ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'lib/images/white-pieces/WhitePawn.png');
    }

    //initialize bishops
    newBoard[0][2] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/black-pieces/BlackBishop.png');
    newBoard[0][5] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/black-pieces/BlackBishop.png');
    newBoard[7][2] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteBishop.png');
    newBoard[7][5] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteBishop.png');

    //initialize knights
    newBoard[0][1] =
        ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/black-pieces/BlackKnight.png');
    newBoard[0][6] =
        ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/black-pieces/BlackKnight.png');
    newBoard[7][1] =
        ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteKnight.png');
    newBoard[7][6] =
        ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteKnight.png');

    //initialize rooks
    newBoard[0][0] =
        ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/black-pieces/BlackRook.png');
    newBoard[0][7] =
        ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/black-pieces/BlackRook.png');
    newBoard[7][0] =
        ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteRook.png');
    newBoard[7][7] =
        ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteRook.png');

    //initialize queens
    newBoard[0][3] =
        ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'lib/images/black-pieces/BlackQueen.png');
    newBoard[7][3] =
        ChessPiece(type: ChessPieceType.queen, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteQueen.png');

    //initialize kings
    newBoard[0][4] =
        ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: 'lib/images/black-pieces/BlackKing.png');
    newBoard[7][4] =
        ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: 'lib/images/white-pieces/WhiteKing.png');

    board = newBoard;
  }

  void selectPiece(int row, int col) {
    setState(() {
      //first time selection
      if (selectedPiece == null && board[row][col] != null) {
        if (isWhiteTurn == board[row][col]!.isWhite) {
          selectedPiece = board[row][col];
          selectedCol = col;
          selectedRow = row;
        }
      }
      //piece already selected but they want to select another piece
      else if (board[row][col] != null && selectedPiece!.isWhite == board[row][col]!.isWhite) {
        selectedPiece = board[row][col];
        selectedCol = col;
        selectedRow = row;
      } else if (selectedPiece != null) {
        if (validMoves.any((element) => element[0] == row && element[1] == col)) {
          movePiece(row, col);
        } else {
          selectedPiece = null;
          selectedCol = -1;
          selectedRow = -1;
        }
      }
      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  bool isStalemate(bool whiteTurn) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != whiteTurn) {
          continue;
        } else {
          List<List<int>> validMoves = calculateRealValidMoves(i, j, board[i][j], true);
          if (validMoves.isNotEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }
    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawn goes forward 1 move
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        //pawn goes forward 2 moves if its in initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        //pawn capturess diagonally and En Passant
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        break;
      case ChessPieceType.bishop:
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            int newRow = row + i * direction[0];
            int newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (piece.isWhite != board[newRow][newCol]!.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        var moves = [
          [-2, -1], //up 2 left 1
          [-2, 1], //up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], //up 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
        ];
        for (var move in moves) {
          int newRow = row + move[0];
          int newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.rook:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            int newRow = row + i * direction[0];
            int newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (piece.isWhite != board[newRow][newCol]!.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            int newRow = row + i * direction[0];
            int newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (piece.isWhite != board[newRow][newCol]!.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          int newRow = row + direction[0];
          int newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (piece.isWhite != board[newRow][newCol]!.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }

    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (isSimulatedMoveSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  bool isSimulatedMoveSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;
    bool kingInCheck = isKingInCheck(piece.isWhite);
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  void movePiece(int newRow, int newCol) async {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whiteTakenPieces.add(capturedPiece);
      } else {
        blackTakenPieces.add(capturedPiece);
      }
    }
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }
    if (selectedPiece!.type == ChessPieceType.pawn && (newRow == 0 || newRow == 7)) {
      ChessPiece newChessPiece = await pickPieceDialog(context, selectedPiece!.isWhite);
      board[newRow][newCol] = newChessPiece;
    } else {
      board[newRow][newCol] = selectedPiece;
    }
    board[selectedRow][selectedCol] = null;
    checkStatus = isKingInCheck(!isWhiteTurn);
    setState(() {
      selectedPiece = null;
      selectedCol = -1;
      selectedRow = -1;
      validMoves = [];
      whiteTakenPieces = [];
      blackTakenPieces = [];
    });
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('CHECK MATE!'),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
    isWhiteTurn = !isWhiteTurn;
    stalemateStatus = isStalemate(isWhiteTurn);
    if (stalemateStatus) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('STALE MATE!'),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  void resetGame() {
    Navigator.of(context).pop();
    _initializeBoard();
    checkStatus = false;
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!checkStatus) {
      return false;
    }
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> enemyValidMoves = calculateRealValidMoves(i, j, board[i][j], false);
        if (enemyValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  Future<ChessPiece> pickPieceDialog(BuildContext ctx, bool isWhite) async {
    String path = '';
    String pieceColor = '';
    List<ChessPieceType> chessPieces = [
      ChessPieceType.bishop,
      ChessPieceType.knight,
      ChessPieceType.rook,
      ChessPieceType.queen,
    ];
    List<String> chessPiecesNames = [
      'Bishop',
      'Knight',
      'Rook',
      'Queen',
    ];
    if (isWhite) {
      path = 'lib/images/white-pieces';
      pieceColor = 'White';
    } else {
      path = 'lib/images/black-pieces';
      pieceColor = 'Black';
    }
    ChessPiece? newChessPiece = await showDialog<ChessPiece>(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                ChessPiece newChessPiece = ChessPiece(
                    type: chessPieces[index],
                    imagePath: '$path/$pieceColor${chessPiecesNames[index]}.png',
                    isWhite: isWhite);
                Navigator.pop(context, newChessPiece);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Image.asset('$path/$pieceColor${chessPiecesNames[index]}.png'),
              ),
            ),
          ),
        ),
      ),
    );
    return newChessPiece!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whiteTakenPieces.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (ctx, index) => DeadPiece(
                imagePath: whiteTakenPieces[index].imagePath,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 64, // chess board = 8 * 8
                itemBuilder: (content, index) {
                  int row = index ~/ 8, col = index % 8;
                  bool isSelected = (row == selectedRow) && (col == selectedCol);
                  bool isValidMove = false;
                  bool canCapture = false;
                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      if (board[row][col] != null) {
                        canCapture = true;
                      }
                      isValidMove = true;
                    }
                  }
                  return Square(
                    isWhite: isWhite(index: index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValid: isValidMove,
                    canCapture: canCapture,
                    onTap: () => selectPiece(row, col),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackTakenPieces.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (ctx, index) => DeadPiece(
                imagePath: blackTakenPieces[index].imagePath,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
