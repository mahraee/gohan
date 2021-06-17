import 'package:flutter/material.dart';
import './screens/tabs_screen.dart';
import 'screens/add_dish.dart';
import 'screens/dish_detailScreen.dart';
import 'screens/dish_screen.dart';
import './screens/favorites_screen.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
  }

  void getData(database) async {
    dishs = await database.rawQuery('SELECT * FROM dishs');
    setState(() {
      avldishs = dishs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gohan',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.amber,
        canvasColor: Color.fromRGBO(255, 254, 229, 1),
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
                // ignore: deprecated_member_use
                title: TextStyle(
              fontSize: 20,
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
            )),
      ),
      // home: CategoriesScreen(),
      initialRoute: '/', // default is '/'
      routes: {
        '/': (ctx) => TabsScreen(),
        DishesScreen.routeName: (ctx) => DishesScreen(),
        FavoritesScreen.routeName: (ctx) => FavoritesScreen(),
        Adddish.routeName: (ctx) => Adddish(),
        dishDetailScreen.routeName: (ctx) => dishDetailScreen(),
      },
    );
  }
}
