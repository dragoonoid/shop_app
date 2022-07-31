import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'card_item.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CardItem> product;
  final DateTime date;
  OrderItem(
      {required this.id,
      required this.amount,
      required this.product,
      required this.date});
}

class Order with ChangeNotifier {
  List<OrderItem> _list = [];
  List<OrderItem> get orderList {
    return [..._list];
  }
  String token='';
  String userId='';
  void updateToken(String tok, String x){
    token=tok;
    userId=x;
    notifyListeners();
  }
  Future getOrderFirebase() async {
    final response = await http.get(
        Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/order/$userId.json?auth=$token'));
    if(response==null){
        return;
    }
    final x = jsonDecode(response.body) as Map<String, dynamic>;
    List<OrderItem> newList = [];
    x.forEach((id, data) {
      newList.add(OrderItem(
          id: id,
          amount: data['amount']*1.0,
          product: (data['products'] as List<dynamic>)
              .map((e) => CardItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price']))
              .toList(),
          date: DateTime.parse(data['date'])));
    });
    _list = newList.reversed.toList();
    notifyListeners();
  }
  Future addOrder(List<CardItem> l, double amt) async {
    final date = DateTime.now();
    final response = await http
        .post(
      Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/order/$userId.json?auth=$token'),
      body: jsonEncode({
        'amount': amt*1.0,
        'date': date.toIso8601String(),
        'products': l
            .map((e) => {
                  'id': e.id,
                  'price': e.price,
                  'quantity': e.quantity,
                  'title': e.title
                })
            .toList()
      }),
    )
        .catchError((onError) {
      print(onError);
      throw onError;
    });
    // _list.insert(
    //   0,
    //   OrderItem(
    //     id: jsonDecode(response.body)['name'],
    //     amount: amt,
    //     product: l,
    //     date: date,
    //   ),
    // );
    //await getOrderFirebase();
    notifyListeners();
  }

}
