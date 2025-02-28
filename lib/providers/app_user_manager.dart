import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserManager extends ChangeNotifier {
  String _appUserId = '';
  String get appUserId => _appUserId;
  String _appUserToken = '';
  String get  appUserToken => _appUserToken;
  void setAppUserId(String userId) {
    _appUserId = userId;
    notifyListeners();
  }
  Future<void> setAppUserToken(String token) async {
    _appUserToken = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('appUserToken', token);
    notifyListeners();
  }
  Future<String> getAppUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('appUserToken') ?? '';
  }
}
