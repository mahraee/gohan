import 'package:flutter/material.dart';
import '../widgets/dish_widget.dart';
import '../dish.dart';
import 'package:sqflite/sqflite.dart';

class DishesScreen extends StatefulWidget {
  static const routeName = '/dishs';

  @override
  _DishesScreenState createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {
  String categoryTitle;
  Database database;
  List<Dish> displayeddishs;
  List<Map> dishs = [];
  List<Map> avldishs = [];
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

    dataloaded = 0;
    creatDatabase();
    getData(database);
  }

  void getData(database) async {
    dishs = await database.rawQuery('SELECT * FROM dishs');
    setState(() {
      avldishs = dishs;
    });
  }

  var oneSecond = Duration(seconds: 0);
  @override
  Widget build(BuildContext context) {
    if (dataloaded == 0) {
      Future.delayed(oneSecond, () => getData(database));
      setState(() {
        avldishs = dishs;
      });
      dataloaded = 1;
    }

    return Scaffold(
        body: ListView(
      children: avldishs
          .map((xyz) => DishWidget(
                id: xyz['id'].toString(),
                title: xyz['title'],
                imageUrl: xyz['imageUrl'],
                cal: xyz['cal'],
              ))
          .toList(),
    ));
  }
}
