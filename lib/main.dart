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
  int? selectedId;
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: TextField(
        controller: textController,
         ),
        ),
        body: Center(
          child: FutureBuilder<List<Namirnica>>(
              future: DatabaseHelper.instance.getNamirnice(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Namirnica>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Text('Ucitavanje...'));
                }
                return snapshot.data!.isEmpty
                    ? Center(child: Text('Nema namirnica u listi.'))
                    : ListView(
                  children: snapshot.data!.map((namirnice) {
                    return Center(
                      child: ListTile(
                        title: Text(namirnice.name),
                        onTap: () {
                          setState(() {
                            textController.text = namirnice.name;
                            selectedId = namirnice.id;
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            DatabaseHelper.instance.remove(namirnice.id!);
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () async {
            selectedId != null
                ? await DatabaseHelper.instance.update(
              Namirnica(id: selectedId, name: textController.text),
            )

            :await DatabaseHelper.instance.add(
              Namirnica(name: textController.text),
            );
            setState(() {
              textController.clear();
              selectedId = null;
            });
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
  Future<int> add(Namirnica namirnice) async {
    Database db = await instance.database;
    return await db.insert('popis', namirnice.toMap());
  }
  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('popis', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> update(Namirnica namirnice) async {
    Database db = await instance.database;
    return await db.update('popis', namirnice.toMap(),
        where: "id = ?", whereArgs: [namirnice.id]);
  }
}