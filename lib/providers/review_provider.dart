import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewItem {
  final String id;
  final String desc;
  final int star;
  final DateTime date;
  final String userName;
  ReviewItem(
      {required this.id,
      required this.desc,
      required this.star,
      required this.date,
      required this.userName // DateFormat.yMEd().add_jms().format(widget.lst.date)
      });
}

class ReviewProvider with ChangeNotifier {
  late String token;
  late String userId;
  List<ReviewItem> lst = [];
  int initialList = 0; // 0 for newest, 1 for oldest, 2 for only stars
  void updateToken(String tok, String x) {
    token = tok;
    userId = x;
    notifyListeners();
  }

  void changeInitialList(int i) {
    if (i == initialList) {
      return;
    } else {
      initialList = i;
    }
    notifyListeners();
  }

  List<int> totalStars() {
    List<int> ans = [0, 0, 0, 0, 0];
    for (int i = 0; i < lst.length; i++) {
      ans[lst[i].star]++;
    }
    return ans;
  }

  Future getReviewsFromFirebase(String id) async {
    List<ReviewItem> temp = [];
    try {
      var url = Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/reviews/$id.json?auth=$token"');
      var resp = await http.get(url);
      final mp = json.decode(resp.body);
      if (mp == null || mp.isEmpty) {
        return;
      }
      mp.forEach((key, value) {
        temp.add(ReviewItem(
            id: value['id'],
            desc: value['description'],
            star: value['star'],
            userName: value['userName'],
            date: DateTime.parse(value['date'])));
      });
      lst = temp;
      sortReviews('0');
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future setReview(String id, String desc, int star, String name) async {
    try {
      var url = Uri.parse(
          'https://first-c92f8-default-rtdb.firebaseio.com/reviews/$id.json?auth=$token"');
      await http.post(url,
          body: jsonEncode({
            'id': id,
            'description': desc,
            'star': star,
            'date': DateTime.now().toIso8601String(),
            'userName': name
          }));
    } catch (e) {
      rethrow;
    }
  }

  sortReviews(String i) {
    if (i == '0') {
      // newest first
      lst.sort((a, b) {
        return a.date.isBefore(b.date) ? 1 : 0;
      });
    } else if (i == '1') {
      // oldest first
      lst.sort((a, b) {
        return a.date.isAfter(b.date) ? 1 : 0;
      });
    } else {
      return;
    }
  }
}
