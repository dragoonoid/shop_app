import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:http/http.dart' as http;

class CategoryProd with ChangeNotifier {
  List<String> maincateg = [
    'Men',
    'Women',
    'Electronics',
    'Accessories',
    'Shoes',
    'Home & garden',
    'Beauty',
    'Kids',
    'Bags'
  ];
  List<String> images = [
    'images/category/men.jpg',
    'images/category/women.jpg',
    'images/category/electronics.jpg',
    'images/category/accessories.jpeg',
    'images/category/shoes.jpg',
    'images/category/home_garden.jpg',
    'images/category/beauty.jpg',
    'images/category/kids.jpg',
    'images/category/bag.jpg',
  ];

  late String token;
  late String userId;
  List<Product> _list = [];
  Map<String, List<Product>> _allCategList = {};
  void updateToken(String tok, String x) {
    token = tok;
    userId = x;
    notifyListeners();
  }

  List<Product> get items {
    return [..._list];
  }
  Map<String, List<Product>> get allCategitems{
    return {..._allCategList};
  }
  void removeElement(String id) {
    _list.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future getCategoryItemsFromFirebase(String categ) async {
    final url = Uri.parse(
        'https://first-c92f8-default-rtdb.firebaseio.com/category/$categ.json?auth=$token');
    try {
      var resp = await http.get(url);
      final response = json.decode(resp.body);
      final favResponse = await http.get(
        Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$token'),
      );
      final favResData = json.decode(favResponse.body);
      List<Product> temp = [];
      if (response != null) {
        response.forEach((id, data) {
          temp.add(Product(
            id: id,
            title: data['title'] ?? 'temp',
            desc: data['desc'] ?? 'temp',
            price: (data['price'] ?? 1) * 1.00,
            imageUrl: data['imageUrl'] ??
                'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
            isFav: favResData == null ? false : favResData[id] ?? false,
            categ: categ,
          ));
        });
      }
      _list = temp;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  // Future returnCategoryItemsForHomeScreen() async {
  //   final url = Uri.parse(
  //       'https://first-c92f8-default-rtdb.firebaseio.com/category.json?auth=$token');
  //   try {
  //     var resp = await http.get(url);
  //     final response = json.decode(resp.body);
  //     final favResponse = await http.get(
  //       Uri.parse(
  //           'https://first-c92f8-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$token'),
  //     );
  //     final favResData = json.decode(favResponse.body);
  //     print(response);
  //     Map<String, List<Product>> temp2={};
  //     if (response != null) {
  //       for (int i = 0; i < maincateg.length; i++) {
  //         List<Product> temp = [];
  //         if(response[maincateg[i]]==null){
  //           continue;
  //         }
  //         response[maincateg[i]].forEach((id, data) {
  //           temp.add(Product(
  //             id: id,
  //             title: data['title'] ?? 'temp',
  //             desc: data['desc'] ?? 'temp',
  //             price: (data['price'] ?? 1) * 1.00,
  //             imageUrl: data['imageUrl'] ??
  //                 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
  //             isFav: favResData == null ? false : favResData[id] ?? false,
  //             categ: data['category'] ?? 'Men',
  //           ));
  //         });
  //         temp2[maincateg[i]]= temp;
  //       }
  //     }
  //     _allCategList=temp2;
  //     notifyListeners();
  //   } catch (error) {
  //     print(error);
  //   }
  // }
}
