import 'package:flutter/material.dart';

void main() => runApp(PopisNamirnica());

class PopisNamirnica extends StatefulWidget {
  const PopisNamirnica({Key? key}) : super(key: key);

  @override
  _SqliteAppState createState() => _SqliteAppState();
}

class _SqliteAppState extends State<PopisNamirnica> {
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: TextField(
        controller: textController,
         ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            print(textController.text);
          },
        ),
      ),
    );
  }
}