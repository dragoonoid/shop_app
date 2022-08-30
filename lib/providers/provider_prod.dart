import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:http/http.dart' as http;

class ProviderProd with ChangeNotifier {
  List<Product> _list = [];
  late String token;
  late String userId;
  void updateToken(String tok, String x) {
    token = tok;
    userId = x;
    notifyListeners();
  }

  Future getItemsFirebase([bool filterByUser = false]) async {
    final url = filterByUser == true
        ? Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/product.json?auth=$token&orderBy="creatorId"&equalTo="$userId"')
        : Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/product.json?auth=$token');
    try {
      final response = await http.get(url);
      final favResponse = await http.get(
        Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$token'),
      );
      final mp = json.decode(response.body) as Map<String, dynamic>;
      final favResData = json.decode(favResponse.body);
      List<Product> temp = [];
      mp.forEach((id, data) {
        temp.add(Product(
          id: id.toString(),
          title: data['title'] ?? 'temp',
          desc: data['desc'] ?? 'temp',
          price: (data['price'] ?? 1) * 1.00,
          imageUrl: data['imageUrl'] ??
              'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
          isFav: favResData == null ? false : favResData[id] ?? false,
          categ: data['category'] ?? 'Random',
        ));
      });
      _list = temp;
      notifyListeners();
    } catch (error) {
      // ignore: avoid_print
      print(error);
    }
  }

  List<Product> get items {
    return [..._list];
  }

  List<Product> get favItem {
    return _list.where((element) => element.isFav).toList();
  }

  Product findId(String id) {
    return _list.firstWhere((x) => x.id == id);
  }

  Future addProd(Product p) async {
    try {
      var body = jsonEncode(
        {
          'title': p.title,
          'desc': p.desc,
          'price': p.price,
          'imageUrl': p.imageUrl,
          'creatorId': userId,
          'category': p.categ
        },
      );
      var resp = await http.post(
        Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/product.json?auth=$token'),
        body: body,
      );
      var response = json.decode(resp.body);
      var id = response['name'] ?? '123';
      //--------------------add item to its category----------------
      await http.put(
        Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/category/${p.categ}/$id.json?auth=$token'),
        body: jsonEncode(
          {
            'title': p.title,
            'desc': p.desc,
            'price': p.price,
            'imageUrl': p.imageUrl,
            'creatorId': userId,
            'category': p.categ,
            'product_id': id
          },
        ),
      );
      await getItemsFirebase();
      notifyListeners();
    } catch (error) {
      // ignore: avoid_print
      print(error);
      rethrow;
    }
  }

  Future deleteProd(String id) async {
    Product ele = _list.firstWhere((element) => element.id == id);
    final response = await http.delete(Uri.parse(
        'https://first-c92f8-default-rtdb.firebaseio.com/product/$id.json?auth=$token'));
    final deleteCateg = await http.delete(Uri.parse(
        'https://first-c92f8-default-rtdb.firebaseio.com/category/${ele.categ}/$id.json?auth=$token'));
    if (response.statusCode >= 400 || deleteCateg.statusCode >= 400) {
      throw HttpException('Failed to delete');
    }
    _list.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future update(Product x) async {
    String id = x.id;
    await http.patch(
      Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/product/$id.json?auth=$token'),
      body: jsonEncode({
        'desc': x.desc,
        'imageUrl': x.imageUrl,
        'price': x.price * 1.00,
        'title': x.title,
        'category': x.categ
      }),
    );
    await http.patch(
      Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/category/${x.categ}/$id.json?auth=$token'),
      body: jsonEncode({
        'desc': x.desc,
        'imageUrl': x.imageUrl,
        'price': x.price * 1.00,
        'title': x.title,
        'category': x.categ
      }),
    );
    final pos = _list.indexWhere((element) => element.id == id);
    _list[pos] = x;
    print(_list[pos].desc);
    print('now');
    await getItemsFirebase();
    notifyListeners();
  }

  List<Product> getSearchItems(String s) {
    return [..._list]
        .where((element) => element.title
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(s.toLowerCase().replaceAll(' ', '')))
        .toList();
  }
}
