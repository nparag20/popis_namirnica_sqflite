import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(PopisNamirnica());
}

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
class Namirnica {
  final int? id;
  final String name;

  Namirnica({this.id, required this.name});

  factory Namirnica.fromMap(Map<String, dynamic> json) => new Namirnica(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'namirnice.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE popis(
          id INTEGER PRIMARY KEY,
          name TEXT
      )
      ''');
  }
  Future<List<Namirnica>> getNamirnice() async {
    Database db = await instance.database;
    var namirnice = await db.query('popis', orderBy: 'name');
    List<Namirnica> listanamirnica = namirnice.isNotEmpty
        ? namirnice.map((c) => Namirnica.fromMap(c)).toList()
        : [];
    return listanamirnica;
  }
}