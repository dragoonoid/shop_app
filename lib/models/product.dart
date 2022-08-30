import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String desc;
  final String imageUrl;
  final double price;
  final String categ;
  bool isFav;

  Product({
    required this.id,
    required this.title,
    required this.desc,
    required this.price,
    required this.imageUrl,
    this.isFav = false,
    required this.categ,
  });

  Future<void> changeFav(String token, String userId) async {
    var fav = !isFav;
    await http
        .put(
      Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/userFav/$userId/$id.json?auth=$token'),
      body: jsonEncode(fav),
    )
        .then((value) {
      if (value.statusCode >= 400) {
        throw HttpException('Failed to change fav');
      }
      isFav = !isFav;
      notifyListeners();
    }).catchError((onError) {
      throw onError;
    });
  }
}
