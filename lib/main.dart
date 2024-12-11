import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(color: Colors.white),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '0';

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
      } else if (value == '=') {
        try {
          String expression = input.replaceAll('×', '*').replaceAll('÷', '/');

          // Handle division by zero
          if (expression.contains('/0')) {
            throw Exception('Division by zero');
          }

          // Replace 22/7 for pi approximation with full precision
          expression = expression.replaceAll('22/7', (22 / 7).toString());

          // Handle square root symbol
          while (expression.contains('√')) {
            final sqrtMatch = RegExp(r'√(\d+(\.\d+)?)').firstMatch(expression);
            if (sqrtMatch != null) {
              final number = double.parse(sqrtMatch.group(1)!);
              final sqrtValue = sqrt(number);
              expression = expression.replaceFirst(sqrtMatch.group(0)!, sqrtValue.toString());
            } else {
              throw Exception('Invalid square root operation');
            }
          }

          Parser parser = Parser();
          Expression exp = parser.parse(expression);
          ContextModel cm = ContextModel();

          double eval = exp.evaluate(EvaluationType.REAL, cm);
          result = eval.toString(); // Full precision
        } catch (e) {
          result = 'Error';
        }
      } else if (value == '⌫') {
        input = input.isNotEmpty ? input.substring(0, input.length - 1) : '';
      } else if (value == '%') {
        // Percentage Functionality
        try {
          if (input.isNotEmpty) {
            double num = double.parse(input);
            result = (num / 100).toString();
            input = result; // Update input to reflect percentage calculation
          }
        } catch (e) {
          result = 'Error';
        }
      } else if (value == '√') {
        if (input.isEmpty || _isLastCharOperator(input)) {
          input += '√';
        } else {
          input += '×√'; // Allow square root after ×
        }
      } else if (_isOperator(value)) {
        if (input.isEmpty || _isLastCharOperator(input)) return; // Prevent invalid input
        input += value;
      } else if (value == '.') {
        if (input.isEmpty || _isLastCharOperator(input)) {
          input += '0.';
        } else {
          final lastNumber = _getLastNumber(input);
          if (!lastNumber.contains('.')) {
            input += '.';
          }
        }
      } else {
        input += value;
      }
    });
  }

  bool _isLastCharOperator(String input) {
    const operators = ['+', '-', '×', '÷'];
    return operators.contains(input[input.length - 1]);
  }

  bool _isOperator(String value) {
    const operators = ['+', '-', '×', '÷'];
    return operators.contains(value);
  }

  String _getLastNumber(String input) {
    const operators = ['+', '-', '×', '÷'];
    for (int i = input.length - 1; i >= 0; i--) {
      if (operators.contains(input[i])) {
        return input.substring(i + 1);
      }
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      input,
                      style: const TextStyle(fontSize: 32),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return CalculatorButton(
                  label: buttons[index],
                  onPressed: () => buttonPressed(buttons[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final List<String> buttons = [
  'C', '%', '√', '⌫',
  '7', '8', '9', '÷',
  '4', '5', '6', '×',
  '1', '2', '3', '-',
  '0', '.', '=', '+'
];

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CalculatorButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: label == '⌫' ? Colors.red[200] : Colors.blue[100],
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

