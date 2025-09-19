import 'package:flutter/material.dart';

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
  // 5 rows x 4 columns = 20 blocks, all gray
  List<Color> colors = List.generate(20, (index) => Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorama - Gabrielle Montserrat Guerra Gomez'),
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
          int row = index ~/ 4;
          int col = index % 4;

          return Container(
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(10.0),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
