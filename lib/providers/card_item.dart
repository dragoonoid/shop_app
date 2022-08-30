import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CardItem {
  final String id, title;
  int quantity;
  final String price;

  CardItem(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class Cart with ChangeNotifier {
  late String token;
  late String userId;
  void updateToken(String tok, String x) {
    token = tok;
    userId = x;
    notifyListeners();
  }

  Map<String, CardItem> mp = {};
  int _num = 0;
  Future addCartIemToFirebase(
      String id, String title, int quantity, String price) async {
    await http.put(
      Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/cart/$userId/$id.json?auth=$token'),
      body: jsonEncode(
        {
          'title': title,
          'quantity': quantity,
          'price': price,
        },
      ),
    );
  }

  Future getCartItemsFromFirebase() async {
    try {
      var uri = Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/cart/$userId.json?auth=$token');
      var resp = await http.get(uri);
      if (jsonDecode(resp.body) == null) {
        return;
      }
      var response = jsonDecode(resp.body) as Map<String, dynamic>;
      print('cart item');
      print(response);
      if (response.isEmpty) {
        return;
      }
      Map<String, CardItem> lst = {};
      response.forEach((key, value) {
        lst.putIfAbsent(key, () {
          return CardItem(
            id: key,
            title: value['title'],
            quantity: value['quantity'],
            price: value['price'],
          );
        });
      });
      mp = lst;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  deleteFromFirebaseCartElement(String id) async {
    await http.delete(
      Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/cart/$userId/$id.json?auth=$token'),
    );
  }

  updateCartItemFirebase(CardItem? x) async {
    var body = jsonEncode(
        {'title': x!.title, 'quantity': x.quantity, 'price': x.price});
    await http.put(
        Uri.parse(
            'https://first-c92f8-default-rtdb.firebaseio.com/cart/$userId/${x.id}.json?auth=$token'),
        body: body);
  }

  Map<String, CardItem> get item {
    return {...mp};
  }

  int get count {
    return mp.length;
  }

  int get mpLength {
    return mp.length;
  }

  Future deleteEle(String id) async {
    // reduce quantity
    if (mp[id]?.quantity == 1) {
      mp.remove(id);
      _num = _num - 1;
      notifyListeners();
      await deleteFromFirebaseCartElement(id);
    } else {
      mp.update(
          id,
          (value) => CardItem(
              id: value.id,
              title: value.title,
              quantity: value.quantity - 1,
              price: value.price));
      notifyListeners();
      await updateCartItemFirebase(mp[id]);
    }
  }

  Future removeEle(String id) async {
    mp.remove(id);
    await deleteFromFirebaseCartElement(id);
  }

  double get totalPrice {
    double ans = 0;
    mp.forEach((key, value) {
      ans += value.quantity * double.parse(value.price);
    });
    return ans;
  }

  Future<void> add(String id, String price, String title) async {
    _num = _num + 1;
    if (mp.containsKey(id)) {
      mp.update(
          id,
          (value) => CardItem(
                id: value.id,
                title: value.title,
                quantity: value.quantity + 1,
                price: value.price,
              ));
    } else {
      mp.putIfAbsent(
        id,
        () => CardItem(
          id: id,
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
    await addCartIemToFirebase(id, title, mp[id]!.quantity, price);
  }

  Future clear() async{
    mp = {};
    notifyListeners();
    var uri = Uri.parse(
        'https://first-c92f8-default-rtdb.firebaseio.com/cart/$userId.json?auth=$token');
    await http.delete(uri);
  }
  
}
