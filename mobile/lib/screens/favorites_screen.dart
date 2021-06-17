import 'package:flutter/material.dart';
import '../dish.dart';
import '../widgets/dish_widget.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesScreen extends StatefulWidget {
  static const routeName = '/fav';
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map> favoritedishs;
  Database database;
  List<Map> dishs;
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
    //WHERE fav= ?', ['true']
  }

  void getData(database) async {
    dishs =
        await database.rawQuery('SELECT * FROM dishs WHERE fav= ?', ['true']);
    setState(() {
      avldishs = dishs;
    });
  }

  var oneSecond = Duration(seconds: 0);
  @override
  Widget build(BuildContext context) {
    if (dataloaded == 0) {
      Future.delayed(oneSecond, () => getData(database));
      dataloaded = 1;
    }

    return Scaffold(
        body: avldishs.length == 0
            ? Center(child: Text('No dish selected as Favorite'))
            : ListView(
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
