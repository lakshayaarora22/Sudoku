import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(SudokuApp());
}

int _selectedColorIndex = 0;

class SudokuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku App',
      home: SudokuHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SudokuHomePage extends StatefulWidget {
  @override
  _SudokuHomePageState createState() => _SudokuHomePageState();
}

class _SudokuHomePageState extends State<SudokuHomePage> {
  bool _isDarkMode = false;
  int _selectedColorIndex = 0;
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.yellow,
    Colors.pink,
    Colors.indigo,
  ];

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Instructions for Sudoku:'),
            SizedBox(height: 8),
            Text('- Fill the 9x9 grid with numbers 1-9.'),
            Text(
                '- Each row, column, and 3x3 subgrid must have unique numbers.'),
            Text(
                '- Some numbers are already provided; your goal is to fill the rest.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SudokuGameScreen(_selectedColorIndex, _colorOptions)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedColor = _colorOptions[_selectedColorIndex];
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lakshaya Sudoku App'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_medium),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    selectedColor,
                    BlendMode.modulate,
                  ),
                  child: Image.asset('images/sudoku.png',
                      width: 400, height: 400)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Play Sudoku',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showInstructions,
          tooltip: 'Instructions',
          child: Icon(Icons.help),
          backgroundColor: Colors.black,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(seconds: 1),
          height: min(screenHeight * 0.1, 80),
          color: _colorOptions[_selectedColorIndex],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colorOptions.map((color) {
              int index = _colorOptions.indexOf(color);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: Container(
                  width: min(screenWidth * 0.5, 30),
                  height: min(screenHeight * 0.2, 30),
                  //i have done this
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColorIndex == index
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

//2nd page starts here
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
class GridIndex {
  final int rowIndex;
  final int colIndex;

  GridIndex(this.rowIndex, this.colIndex);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GridIndex &&
        other.rowIndex == rowIndex &&
        other.colIndex == colIndex;
  }

  @override
  int get hashCode {
    return rowIndex.hashCode ^ colIndex.hashCode;
  }
}

class SudokuGameScreen extends StatefulWidget {
  final int initialColorIndex;
  final List<Color> colorOptions;

  SudokuGameScreen(this.initialColorIndex, this.colorOptions);

  @override
  _SudokuGameScreenState createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  bool _isDarkMode = false;
  Color _selectedColor = Colors.red;
  Timer? _timer;
  int _elapsedSeconds = 300;
  Timer? _countdownTimer;
  bool _showCheckMessage = false;
  List<GridIndex> initiallyEmptyCells = [];
  Set<GridIndex> selectedCells = {};
  @override
  void initState() {
    super.initState();
    _selectedColor = _colorOptions[_selectedColorIndex];
    _initializeGameBoard();
    _startTimer();
  }

  void _initializeGameBoard() {
    for (int rowIndex = 0; rowIndex < 9; rowIndex++) {
      for (int colIndex = 0; colIndex < 9; colIndex++) {
        if (_sudokuBoard[rowIndex][colIndex] == 0) {
          initiallyEmptyCells.add(GridIndex(rowIndex, colIndex));
        }
      }
    }
  }

  void _checkGame() {
    if (isValidSudoku()) {
      _showCheckMessage = false;
      if (mounted) {
        _showWinMessageAndNavigate();
      }
    } else {
      setState(() {
        _showCheckMessage = true;
      });
    }
  }

  void _startTimer() {
    const duration = Duration(seconds: 1);
    _countdownTimer = Timer.periodic(duration, _onTimerTick);
  }

  void _onTimerTick(Timer timer) {
    setState(() {
      if (_elapsedSeconds > 0) {
        _elapsedSeconds -= 1;
      } else {
        timer.cancel();
        _showLoseMessageAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.yellow,
    Colors.pink,
    Colors.indigo,
  ];

  final List<List<int>> _sudokuBoard = [
    [0, 0, 0, 0, 0, 0, 0, 4, 0],
    [4, 8, 7, 0, 0, 0, 2, 1, 3],
    [0, 0, 0, 0, 8, 4, 0, 7, 0],
    [9, 0, 0, 4, 0, 0, 0, 0, 0],
    [1, 3, 0, 0, 0, 7, 0, 0, 4],
    [0, 4, 6, 8, 0, 0, 1, 5, 0],
    [0, 0, 0, 1, 0, 0, 5, 0, 7],
    [5, 9, 0, 0, 0, 0, 0, 2, 1],
    [2, 0, 1, 5, 0, 3, 0, 0, 0],
  ];
/*
    [6, 5, 2, 3, 7, 1, 8, 4, 9],
    [4, 8, 7, 9, 5, 6, 2, 1, 3],
    [3, 1, 9, 2, 8, 4, 6, 7, 5],
    [9, 2, 8, 4, 1, 5, 7, 3, 6],
    [1, 3, 5, 6, 2, 7, 9, 8, 4],
    [7, 4, 6, 8, 3, 9, 1, 5, 2],
    [8, 6, 3, 1, 4, 2, 5, 9, 7],
    [5, 9, 4, 7, 6, 8, 3, 2, 1],
    [2, 7, 1, 5, 9, 3, 4, 6, 8],


*/
  void _resetGame() {
    setState(() {
      // Reset the Sudoku board to its initial state
      _sudokuBoard.clear();
      _sudokuBoard.addAll([
        [0, 0, 0, 0, 0, 0, 0, 4, 0],
        [4, 8, 7, 0, 0, 0, 2, 1, 3],
        [0, 0, 0, 0, 8, 4, 0, 7, 0],
        [9, 0, 0, 4, 0, 0, 0, 0, 0],
        [1, 3, 0, 0, 0, 7, 0, 0, 4],
        [0, 4, 6, 8, 0, 0, 1, 5, 0],
        [0, 0, 0, 1, 0, 0, 5, 0, 7],
        [5, 9, 0, 0, 0, 0, 0, 2, 1],
        [2, 0, 1, 5, 0, 3, 0, 0, 0],
      ]);

      // Reset other game-related variables
      _elapsedSeconds = 300;
      _showCheckMessage = false;
    });
  }

  void _showLoseMessageAndNavigate() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game Over'),
          content: const Text('Sorry, you lost the game. Retry'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
                Navigator.of(context).pop(); // Navigate back to home page
                _resetGame();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showWinMessageAndNavigate() {
    if (mounted) {
      String title = 'Congratulations';
      String message = 'You won the game!';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
                Navigator.of(context).pop(); // Navigate back to home page
                if (mounted) {
                  _resetGame();
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showErrorAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool allFilled() {
    for (int i = 0; i <= 8; i++) {
      for (int j = 0; j <= 8; j++) {
        if (_sudokuBoard[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void _autoCompleteBoard() {
    // Check rows
    for (int rowIndex = 0; rowIndex < 9; rowIndex++) {
      List<int> rowValues =
          List.generate(9, (colIndex) => _sudokuBoard[rowIndex][colIndex]);
      int emptyCellCount = rowValues.where((value) => value == 0).length;
      if (emptyCellCount == 1) {
        int remainingNumber = 45 - rowValues.reduce((a, b) => a + b);
        int emptyColIndex = rowValues.indexOf(0);
        setState(() {
          _sudokuBoard[rowIndex][emptyColIndex] = remainingNumber;
        });
      }
    }

    // Check columns
    for (int colIndex = 0; colIndex < 9; colIndex++) {
      List<int> colValues =
          List.generate(9, (rowIndex) => _sudokuBoard[rowIndex][colIndex]);
      int emptyCellCount = colValues.where((value) => value == 0).length;
      if (emptyCellCount == 1) {
        int remainingNumber = 45 - colValues.reduce((a, b) => a + b);
        int emptyRowIndex = colValues.indexOf(0);
        setState(() {
          _sudokuBoard[emptyRowIndex][colIndex] = remainingNumber;
        });
      }
    }

    // Check 3x3 grids
    for (int rowStart = 0; rowStart < 9; rowStart += 3) {
      for (int colStart = 0; colStart < 9; colStart += 3) {
        List<int> gridValues = [];
        for (int row = rowStart; row < rowStart + 3; row++) {
          for (int col = colStart; col < colStart + 3; col++) {
            gridValues.add(_sudokuBoard[row][col]);
          }
        }
        int emptyCellCount = gridValues.where((value) => value == 0).length;
        if (emptyCellCount == 1) {
          int remainingNumber = 45 - gridValues.reduce((a, b) => a + b);
          int emptyRowIndex = rowStart + gridValues.indexOf(0) ~/ 3;
          int emptyColIndex = colStart + gridValues.indexOf(0) % 3;
          setState(() {
            _sudokuBoard[emptyRowIndex][emptyColIndex] = remainingNumber;
          });
        }
      }
    }
  }

  void _showNumberSelectionDialog(int rowIndex, int colIndex) {
    // Check if the selected cell's indices are in the initially empty cell list
    if (initiallyEmptyCells.contains(GridIndex(rowIndex, colIndex))) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select a Number'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(9, (index) {
                int number = index + 1;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, number);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      number.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ).then((selectedNumber) {
        if (selectedNumber != null) {
          if (_isValidMove(rowIndex, colIndex, selectedNumber)) {
            setState(() {
              _sudokuBoard[rowIndex][colIndex] = selectedNumber;
            });
            _autoCompleteBoard();
          } else {
            _showErrorAlert('Invalid Move',
                'The selected number conflicts with the rules.');
          }
        }
      });
    }
  }

  bool _isValidMove(int row, int col, int num) {
    // Check if num exists in the same row
    for (int i = 0; i <= 8; i++) {
      if (_sudokuBoard[row][i] == num) {
        return false;
      }
    }
    // Check if num exists in the same column
    for (int i = 0; i <= 8; i++) {
      if (_sudokuBoard[i][col] == num) {
        return false;
      }
    }
    // Check if num exists in the 3x3 subgrid
    int subgridStartRow = (row ~/ 3) * 3;
    int subgridStartCol = (col ~/ 3) * 3;

    for (int i = subgridStartRow; i < subgridStartRow + 3; i++) {
      for (int j = subgridStartCol; j < subgridStartCol + 3; j++) {
        if (_sudokuBoard[i][j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  bool isValidSudoku() {
    // Check rows
    for (int row = 0; row < 9; row++) {
      if (!_isValidUnit(_sudokuBoard[row])) {
        return false;
      }
    }

    // Check columns
    for (int col = 0; col < 9; col++) {
      if (!_isValidUnit(List.generate(9, (row) => _sudokuBoard[row][col]))) {
        return false;
      }
    }

    // Check 3x3 grids
    for (int rowStart = 0; rowStart < 9; rowStart += 3) {
      for (int colStart = 0; colStart < 9; colStart += 3) {
        List<int> gridValues = [];
        for (int row = rowStart; row < rowStart + 3; row++) {
          for (int col = colStart; col < colStart + 3; col++) {
            gridValues.add(_sudokuBoard[row][col]);
          }
        }
        if (!_isValidUnit(gridValues)) {
          return false;
        }
      }
    }

    for (int i = 0; i <= 8; i++) {
      for (int j = 0; j <= 8; j++) {
        if (_sudokuBoard[i][j] == 0) {
          return false;
        }
      }
    }

    return true;
  }

  bool _isValidUnit(List<int> unit) {
    List<bool> seen = List.generate(10, (_) => false); // Index 0 is not used
    for (int num in unit) {
      if (num == 0) {
        continue; // Empty cell
      }
      if (seen[num]) {
        return false; // Duplicate number found
      }
      seen[num] = true;
    }
    return true;
  }

  bool checkColorFunction(int rowIndex, int colIndex) {
    return (rowIndex >= 0 && rowIndex <= 2 && colIndex >= 3 && colIndex <= 5) ||
        (rowIndex >= 3 && rowIndex <= 5 && colIndex >= 0 && colIndex <= 2) ||
        (rowIndex >= 6 && rowIndex <= 8 && colIndex >= 3 && colIndex <= 5) ||
        (rowIndex >= 3 && rowIndex <= 5 && colIndex >= 6 && colIndex <= 8);
  }

  String formatTime(int seconds) {
    int minutes = (seconds % 3600) ~/ 60;
    seconds = seconds % 60;
    if (minutes == 4 && seconds != 0 && seconds % 60 == 0) {
      return '$minutes minutes 60 seconds';
    }
    return '$minutes minutes $seconds seconds';
  }

  Widget _buildSudokuBoard() {
    return Center(
      child: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 20), // Add some spacing
                  Text(formatTime(_elapsedSeconds),
                      style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          Column(
            children: List.generate(9, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(9, (colIndex) {
                  int cellValue = _sudokuBoard[rowIndex][colIndex];
                  bool isColoredCell = checkColorFunction(rowIndex, colIndex);
                  bool isSelectedCell =
                      selectedCells.contains(GridIndex(rowIndex, colIndex));
                  return GestureDetector(
                    onTap: () {
                      if (cellValue == 0 ||
                          (initiallyEmptyCells.any((cell) =>
                              cell.rowIndex == rowIndex &&
                              cell.colIndex == colIndex))) {
                        setState(() {
                          if (isSelectedCell) {
                            //selectedCells.remove(GridIndex(rowIndex, colIndex));
                          } else {
                            selectedCells.add(GridIndex(rowIndex, colIndex));
                          }
                        });
                        _showNumberSelectionDialog(rowIndex, colIndex);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        color: isSelectedCell
                            ? Colors.grey.shade600
                            : (isColoredCell
                                ? _selectedColor
                                : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(cellValue != 0 ? cellValue.toString() : '',
                            style: TextStyle(
                              fontSize: 18,
                              color: _isDarkMode
                                  ? Colors.white
                                  : (isColoredCell
                                      ? Colors.white
                                      : Colors.black),
                            )),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.only(
                top: 20.0), // Adjust the bottom padding as needed
            width: 130, // Set the desired width
            height: 60, // Set the desired height
            child: ElevatedButton(
              onPressed: _checkGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Change the button color
                textStyle:
                    const TextStyle(fontSize: 18), // Change the text size
              ),
              child: const Text('Check'),
            ),
          ),
          if (_showCheckMessage)
            const Text(
              'Please complete the board correctly before checking.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sudoku Game'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_medium),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Center(
          child: _buildSudokuBoard(),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(seconds: 1),
          //height: 80,
          height: min(screenHeight * 0.2, 200),
          width: min(screenWidth * 0.5, 200),
          color: _selectedColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.colorOptions.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
