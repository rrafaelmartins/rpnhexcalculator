import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CalculadoraHexadecimalScreen extends StatefulWidget {
  @override
  _CalculadoraHexadecimalScreenState createState() =>
      _CalculadoraHexadecimalScreenState();
}

class _CalculadoraHexadecimalScreenState extends State<CalculadoraHexadecimalScreen> {
  TextEditingController _expressionController = TextEditingController();
  String _expression = '';
  String _result = '';

  void _onDigitButtonPressed(String digit) {
    setState(() {
      _expression += digit;
    });
  }

  void _onOperatorButtonPressed(String operator) {
    setState(() {
      _expression += operator;
    });
  }

void _onEqualsButtonPressed() {
  setState(() {
    // Avalia a expressão e atualiza o resultado
    try {
      int result = eval(_expressionController.text);
      _result = result.toRadixString(16).toUpperCase();
      _expressionController.text = result.toRadixString(16).toUpperCase();
    } catch (e) {
      // Tratamento de exceção
      _result = e.toString(); // Define o erro da exceção como resultado
    }
  });
}

  void _updateExpression(String value) {
    setState(() {
      _expressionController.text += value;
    });
  }

void _onClearButtonPressed() {
    setState(() {
      _expressionController.clear();
      _result = '';
    });
  }

  void _onEnterKeyPressed() {
    setState(() {
      _onEqualsButtonPressed();
    });
  }


  int eval(String expression) {
  expression = expression.replaceAll(RegExp(r'\s+'), '');

  if (expression.startsWith('-')) {
    // Remove o sinal de negativo e avalia o restante da expressão
    int result = -eval(expression.substring(1));
    return result;
  }

  List<String> parts = expression.split(RegExp(r'[+\-*/]'));

  List<String> operators = [];
  expression.split('').forEach((char) {
    if (char == '+' || char == '-' || char == '*' || char == '/') {
      operators.add(char);
    }
  });

  int result = int.parse(parts[0], radix: 16);

  for (int i = 0; i < operators.length; i++) {
    int operand = int.parse(parts[i + 1], radix: 16);

    if (operators[i] == '+') {
      result += operand;
    } else if (operators[i] == '-') {
      result -= operand;
    } else if (operators[i] == '*') {
      result *= operand;
    } else if (operators[i] == '/') {
      result ~/= operand;
    }
  }

  return result;
}

@override
void initState() {
  super.initState();
  RawKeyboard.instance.addListener(_handleKeyPress);
}


void _handleKeyPress(RawKeyEvent event) {
  if (event.logicalKey == LogicalKeyboardKey.enter) {
    _onEnterKeyPressed();
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora Hexadecimal'),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _expressionController,
              style: TextStyle(fontSize: 24.0),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                _onEnterKeyPressed();
              },
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(16.0),
            child: Text(
              _result,
              style: TextStyle(fontSize: 24.0),
            ),
          ),
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                  _onEnterKeyPressed();
                }
              },
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 6,
                children: [
                  ...List.generate(10, (index) {
                    return CalculatorButton(
                      text: '$index',
                      onPressed: () => _updateExpression('$index'),
                    );
                  }),
                  ...List.generate(6, (index) {
                    final operators = ['A', 'B', 'C', 'D', 'E', 'F'];
                    return CalculatorButton(
                      text: operators[index],
                      onPressed: () => _updateExpression(operators[index]),
                    );
                  }),
                  CalculatorButton(
                    text: '+',
                    onPressed: () => _updateExpression('+'),
                  ),
                  CalculatorButton(
                    text: '-',
                    onPressed: () => _updateExpression('-'),
                  ),
                  CalculatorButton(
                    text: '*',
                    onPressed: () => _updateExpression('*'),
                  ),
                  CalculatorButton(
                    text: '/',
                    onPressed: () => _updateExpression('/'),
                  ),
                  CalculatorButton(
                    text: '=',
                    onPressed: _onEqualsButtonPressed,
                  ),
                  CalculatorButton(
                    text: 'Clear',
                    onPressed: _onClearButtonPressed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({
    required this.text,
    required this.onPressed,
  });

  @override
  _CalculatorButtonState createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.text,
        style: TextStyle(fontSize: 20.0),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(60.0, 60.0),
      ),
    );
  }
}