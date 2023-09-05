import 'package:flutter/material.dart';

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
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _colorOptions[_selectedColorIndex],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.games,
                  color: Colors.white,
                  size: 80,
                ),
              ),
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
          height: 80,
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
                  width: 30,
                  height: 30,
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

  @override
  void initState() {
    super.initState();
    _selectedColor = _colorOptions[_selectedColorIndex];
  }

  void _showLoseMessageAndNavigate() {
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
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showWinMessageAndNavigate() {
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
            },
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

void _showNumberSelectionDialog(int rowIndex, int colIndex) {
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
                  if (_isBoardFull() && _isBoardValid()) {
                    _showWinMessageAndNavigate();
                  }
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
            if (!_isBoardValid()) {
              _showLoseMessageAndNavigate();
            }
          });
        } else {
          _showErrorAlert(
              'Invalid Move', 'The selected number conflicts with the rules.');
        }
      }
    });
  }

  bool _isBoardFull() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_sudokuBoard[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
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

  bool _isValidMove(int row, int col, int num) {
    // Check if num exists in the same row
    for (int i = 0; i < 9; i++) {
      if (_sudokuBoard[row][i] == num) {
        return false;
      }
    }

    // Check if num exists in the same column
    for (int i = 0; i < 9; i++) {
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

  bool checkColorFunction(int rowIndex, int colIndex) {
    return (rowIndex >= 0 && rowIndex <= 2 && colIndex >= 3 && colIndex <= 5) ||
        (rowIndex >= 3 && rowIndex <= 5 && colIndex >= 0 && colIndex <= 2) ||
        (rowIndex >= 6 && rowIndex <= 8 && colIndex >= 3 && colIndex <= 5) ||
        (rowIndex >= 3 && rowIndex <= 5 && colIndex >= 6 && colIndex <= 8);
  }

  bool _isBoardValid() {
    // Check if the entire board is valid based on Sudoku rules
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        int num = _sudokuBoard[i][j];
        if (num != 0 && !_isValidMove(i, j, num)) {
          //return false;
        }
      }
    }
    return true;
  }

  Widget _buildSudokuBoard() {
    return Center(
      child: Column(
        children: List.generate(9, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (colIndex) {
              int cellValue = _sudokuBoard[rowIndex][colIndex];
              bool isColoredCell = checkColorFunction(rowIndex, colIndex);

              return GestureDetector(
                onTap: () {
                  if (cellValue == 0) {
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
                    color: isColoredCell ? _selectedColor : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      cellValue != 0 ? cellValue.toString() : '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sudoku Game'),
          backgroundColor: Colors.orange.shade400,
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
          height: 80,
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
