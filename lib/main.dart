import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ColorBlocksApp());
}

class ColorBlocksApp extends StatelessWidget {
  const ColorBlocksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ColorBlocksScreen(),
    );
  }
}

class ColorBlocksScreen extends StatefulWidget {
  const ColorBlocksScreen({super.key});

  @override
  State<ColorBlocksScreen> createState() => _ColorBlocksScreenState();
}

class _ColorBlocksScreenState extends State<ColorBlocksScreen> {
  // Colores ocultos (la "respuesta" del memorama)
  late List<Color> hiddenColors;

  // Colores visibles (lo que muestra la interfaz)
  List<Color> visibleColors = List.generate(20, (index) => Colors.grey);

  // Estado de cada bloque: 0=oculto, 1=seleccionado temporalmente, 2=emparejado
  List<int> blockStates = List.generate(20, (index) => 0);

  // Índices de los bloques actualmente seleccionados
  List<int> selectedIndices = [];

  // Bloquear interacción mientras se evalúa el par
  bool isEvaluating = false;

  // Indicar si el juego ha sido completado
  bool gameCompleted = false;

  // Generar 10 colores únicos
  static List<Color> _generate10UniqueColors() {
    Set<Color> uniqueColors = <Color>{};
    final Random random = Random();

    while (uniqueColors.length < 10) {
      Color newColor = Color(0xFF000000 + random.nextInt(0x00FFFFFF));
      // Asegurarse de que los colores sean todos diferentes por que en la otra version se repetia mucho el morado y el amarillo
      if (newColor != Colors.grey &&
              (newColor.red - newColor.green).abs() > 30 ||
          (newColor.red - newColor.blue).abs() > 30 ||
          (newColor.green - newColor.blue).abs() > 30) {
        uniqueColors.add(newColor);
      }
    }

    return uniqueColors.toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    List<Color> uniqueColors = _generate10UniqueColors();
    // Crear pares de colores (10 pares para 20 bloques)
    hiddenColors = [];
    for (Color color in uniqueColors) {
      hiddenColors.add(color);
      hiddenColors.add(color);
    }
    // Mezclar los colores
    hiddenColors.shuffle();
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      visibleColors = List.generate(20, (index) => Colors.grey);
      blockStates = List.generate(20, (index) => 0);
      selectedIndices.clear();
      isEvaluating = false;
      gameCompleted = false;
    });
  }

  void onBlockTap(int index) {
    // No hacer nada si:
    // - Está evaluando un par
    // - El bloque ya está emparejado
    // - Ya hay 2 bloques seleccionados
    // - El bloque ya está seleccionado
    if (isEvaluating ||
        blockStates[index] == 2 ||
        selectedIndices.length >= 2 ||
        selectedIndices.contains(index)) {
      return;
    }

    setState(() {
      // Mostrar el color oculto y marcar como seleccionado temporalmente
      visibleColors[index] = hiddenColors[index];
      blockStates[index] = 1;
      selectedIndices.add(index);

      // Si se han seleccionado 2 bloques, evaluar el par
      if (selectedIndices.length == 2) {
        isEvaluating = true;
        _evaluatePair();
      }
    });
  }

  void _evaluatePair() {
    // Esperar 1 segundo antes de evaluar para que el usuario vea los colores
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        int first = selectedIndices[0];
        int second = selectedIndices[1];

        if (hiddenColors[first] == hiddenColors[second]) {
          // Coinciden: marcar como emparejados
          blockStates[first] = 2;
          blockStates[second] = 2;

          // Haaaber si el juego se completo
          _checkGameCompleted();
        } else {
          // No coinciden: volver a gris
          visibleColors[first] = Colors.grey;
          visibleColors[second] = Colors.grey;
          blockStates[first] = 0;
          blockStates[second] = 0;
        }

        // Limpiar selección
        selectedIndices.clear();
        isEvaluating = false;
      });
    });
  }

  //Aqui tan las funciones para resetear el juego y para checar si se completo
  void _checkGameCompleted() {
    bool allMatched = blockStates.every((state) => state == 2);
    if (allMatched) {
      gameCompleted = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        // Mostramos un orale si le sabes
        _ShowGameCompletedDialog();
      });
    }
  }

  void _ShowGameCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('¡Felicidades!'),
          content: const Text(
            'Has completado el memorama rifadito.\n¿Quieres jugar de nuevo?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Reiniciar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorama - Gabrielle Montserrat Guerra Gomez'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetGame();
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          // computar fila y columna para mostrar en el centro del bloque solo me sirve para poder debuggear jijij
          int row = index ~/ 4;
          int col = index % 4;

          return GestureDetector(
            onTap: () => onBlockTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: visibleColors[index],
                borderRadius: BorderRadius.circular(10.0),
                border: blockStates[index] == 1
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${row + 1}-${col + 1}',
                  style: TextStyle(
                    color: visibleColors[index].computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
