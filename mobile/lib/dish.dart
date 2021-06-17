import 'package:flutter/foundation.dart';

class Dish {
  final String id;
  final String title;
  final String ingredients;
  final String steps;
  final String cal;

  const Dish({
    @required this.id,
    @required this.title,
    @required this.ingredients,
    @required this.steps,
    @required this.cal,
  });
}
