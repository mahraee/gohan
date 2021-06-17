import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

// ignore: camel_case_types
class dishDetailScreen extends StatefulWidget {
  static const routeName = '/dish-detail';

  @override
  _dishDetailScreenState createState() => _dishDetailScreenState();
}

class _dishDetailScreenState extends State<dishDetailScreen> {
  Database database;
  List<Map> dishs;
  Map<dynamic, dynamic> selecteddish = {};
  var isfav;
  List<Map> avldishs;
  var dataloaded = 0;

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

  void initState() {
    super.initState();
    avldishs = [];
    dishs = [];

    creatDatabase();
  }

  void getData(database) async {
    dishs = await database.rawQuery('SELECT * FROM dishs');
    setState(() {
      avldishs = dishs;
    });
  }

  Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        // ignore: deprecated_member_use
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget buildContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 150,
      width: 300,
      child: child,
    );
  }

  var oneSecond = Duration(seconds: 0);
  @override
  Widget build(BuildContext context) {
    final dishId = ModalRoute.of(context).settings.arguments as String;
    if (dataloaded == 0) {
      Future.delayed(oneSecond, () => getData(database));
      dataloaded = 1;
    }
    print('this is ' + dishId);
    final selecteddish =
        avldishs.firstWhere((dish) => dish['id'].toString() == dishId);
    print(selecteddish);
    int ids = selecteddish['id'];
    isfav = selecteddish['fav'];
    return Scaffold(
      appBar: AppBar(
        actions: [
          FloatingActionButton(
              foregroundColor: Colors.amber,
              backgroundColor: Color.fromRGBO(255, 255, 255, 255),
              child: Icon(
                isfav == "true" ? Icons.star : Icons.star_border,
              ),
              onPressed: () async {
                if (selecteddish['fav'] == "true") {
                  await database.rawUpdate(
                      'UPDATE dishs SET  fav = ? WHERE id = ?',
                      ['false', ids]).then((value) {
                    print(selecteddish['fav']);
                    setState(() {
                      dataloaded = 0;
                      isfav = "false";
                    });
                  });
                }
                if (selecteddish['fav'] == "false") {
                  await database.rawUpdate(
                      'UPDATE dishs SET  fav = ? WHERE id = ?',
                      ['true', ids]).then((value) {
                    print(selecteddish['fav']);
                    setState(() {
                      dataloaded = 0;
                      isfav = "true";
                    });
                  });
                }
              })
        ],
        title: Text('${selecteddish['title']}'),
      ),
      body: avldishs.length == 0
          ? Center(child: Text(' '))
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: Image.file(
                      File(selecteddish['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  buildSectionTitle(context, 'Ingredients'),
                  buildContainer(SingleChildScrollView(
                      child: Text(selecteddish['ingredients']))),
                  buildSectionTitle(context, 'steps'),
                  buildContainer(
                    SingleChildScrollView(child: Text(selecteddish['steps'])),
                  ),
                ],
              ),
            ),
    );
  }
}
