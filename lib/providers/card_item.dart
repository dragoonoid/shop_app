

import 'package:flutter/material.dart';

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
  Map<String, CardItem> mp = {};
  int _num = 0;
  Map<String, CardItem> get item {
    return {...mp};
  }

  int get count {
    return mp.length;
  }

  int get mpLength {
    return mp.length;
  }

  void deleteEle(String id) {
    if (mp[id]?.quantity == 1) {
      mp.remove(id);
      _num = _num - 1;
    } else {
      mp.update(
          id,
          (value) => CardItem(
              id: value.id,
              title: value.title,
              quantity: value.quantity - 1,
              price: value.price));
    }
    notifyListeners();
  }

  void removeEle(String id) {
    mp.remove(id);
    notifyListeners();
  }

  double get totalPrice {
    double ans = 0;
    mp.forEach((key, value) {
      ans += value.quantity * double.parse(value.price);
    });
    return ans;
  }

  void add(String id, String price, String title) {
    _num = _num + 1;
    if (mp.containsKey(id)) {
      mp.update(id, (value) =>CardItem(
          id: value.id,
          title: value.title,
          quantity: value.quantity + 1,
          price: value.price,
        )
      );
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
  }

  void clear() {
    mp = {};
    notifyListeners();
  }
}
