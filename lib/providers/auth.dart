import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String token = '';
  String userId = '';
  Timer? expiryTimer;
  DateTime expiryDate = DateTime.now();
  bool get isAuth{
    if(getToken()!='null'){
      return true;
    }
    return false;
  }
  
  String getToken(){
    if(token!='' && expiryDate.isAfter(DateTime.now())){
      return token;
    }
    return 'null';
  }
  
  Future <bool> tryAutoLogIn() async{
    final prefs=await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final internal=prefs.getString('userData') ?? "ghj";
    final userData=jsonDecode(internal) as Map<String,dynamic>;
    if(DateTime.parse(userData['expiryDate']).isBefore(DateTime.now())){
      return false;
    }
    token=userData['token'];
    userId=userData['userId'];
    expiryDate=DateTime.parse(userData['expiryDate']);
    notifyListeners();
    autoLogout(); 
    return true;
  }
  
  Future signInOrsignUp(String email, String password, String mode) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$mode?key=AIzaSyB6u049MEKPNhLhCG3ZrGeuOjt3mqhcXhU');
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      token = responseData['idToken'];
      userId = responseData['localId'];
      print(userId);
      expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      autoLogout();
      notifyListeners();
      final pref=await SharedPreferences.getInstance();
      final userValue=jsonEncode({
        'token':token,
        'userId': userId,
        'expiryDate': expiryDate.toIso8601String()
      });
      pref.setString('userData', userValue);
    } catch (error) {
      rethrow;
    }
  }

  Future signup(String email, String password) async {
    const mode = 'signUp';
    return signInOrsignUp(email, password, mode);
  }

  Future signin(String email, String password) async {
    const mode = 'signInWithPassword';
    return signInOrsignUp(email, password, mode);
  }
  
  Future logout()async{
    token='';
    userId='';
    expiryDate=DateTime.now();
    if(expiryTimer!=null){
      expiryTimer!.cancel();
      expiryTimer=null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    prefs.clear();
  }
 
  void autoLogout(){
    if(expiryTimer!=null){
      expiryTimer!.cancel();
    }
    final duration=expiryDate.difference(DateTime.now()).inSeconds;
    expiryTimer=Timer(Duration(seconds: duration), logout);
  }
}
