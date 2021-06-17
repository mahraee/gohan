import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../dish.dart';
import '../widgets/drawer.dart';
import '../dish_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Adddish extends StatefulWidget {
  static const routeName = '/add_new';

  @override
  _AdddishState createState() => _AdddishState();
}

class _AdddishState extends State<Adddish> {
  File _storedImage;
  final picker = ImagePicker();
  Database database;
  List<Dish> availabledishs = AllDishes;
  String paths;
  List<Map> dishs;

  void creatDatabase() async {
    database = await openDatabase('dishs.db', version: 1,
        onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE dishs (id INTEGER PRIMARY KEY, title TEXT, imageUrl TEXT, ingredients TEXT, steps TEXT, cal TEXT, fav TEXT )')
          .then((value) => print('table created'));
    }, onOpen: (database) {
      getData(database);
      print('database opend');
    });
  }

  void insertToDatabase(tit, path, ingr, step, cal, fov) {
    database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO dishs (title, imageUrl, ingredients, steps, cal, fav) VALUES ("$tit","$path","$ingr","$step","$cal", "$fov")')
          .then((value) => print('insert done'));
      return null;
    });
  }

  void initState() {
    super.initState();
    creatDatabase();
  }

  Future<void> _takePictureFromCamera() async {
    final imageFile = await picker.getImage(
      source: ImageSource.camera,
    );
    setState(() {
      paths = imageFile.path;
      _storedImage = File(imageFile.path);
    });
  }

  Future<void> _takePictureFromGallary() async {
    final imageFile = await picker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  Future<void> _sendReq(File imgs) async {
    print(imgs.path);
    final urs = 'http://192.168.1.7:5000/';
    // ignore: unnecessary_cast
    String base64Image = base64Encode(imgs.readAsBytesSync());

    final response = await http.post(
      Uri.parse(urs),
      body: jsonEncode(
        {'image': base64Image},
      ),
      headers: {'Content-Type': "application/json"},
    );
    // ignore: await_only_futures
    final existingIndex =
        availabledishs.indexWhere((dish) => dish.id == response.body);
    insertToDatabase(
        availabledishs[existingIndex].title,
        imgs.path,
        availabledishs[existingIndex].ingredients,
        availabledishs[existingIndex].steps,
        availabledishs[existingIndex].cal,
        "false");

    print('Response body: ${response.body}');
    print('Response body: $existingIndex');
  }

  Future<List<Map>> getData(database) async {
    return dishs = await database.rawQuery('SELECT * FROM dishs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new dish'),
      ),
      drawer: MainDrawer(),
      body: Column(
        children: [
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: _takePictureFromCamera, child: Text('From Camera')),
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: _takePictureFromGallary, child: Text('From Gallary')),
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: _storedImage != null
                ? Image.file(
                    _storedImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Text(
                    'No Image Taken',
                    textAlign: TextAlign.center,
                  ),
            alignment: Alignment.center,
          ),
          SizedBox(
            height: 30,
            width: double.infinity,
          ),
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: () {
                _sendReq(_storedImage).then((value) {
                  getData(database).then((value) =>
                      {Navigator.of(context).pushReplacementNamed('/')});
                });
              },
              child: Text('search')),
        ],
      ),
    );
  }
}
