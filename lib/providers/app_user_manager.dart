import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserManager extends ChangeNotifier {
  String _appUserId = '';
  String get appUserId => _appUserId;
  String _appUserToken = '';
  String _currentUserId = '';
  bool isFaceCapturedOfCurrentUser = false;
  bool isBatchRequired = false;
  bool isScanCompleted = false;
  bool isFoodEntryAlreadyExists = false;
  String get currentUserId => _currentUserId;
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
  void setIsFaceCapturedOfCurrentUser(bool isCaptured) {
    isFaceCapturedOfCurrentUser = isCaptured;
    notifyListeners();
  }
  void setIsBatchRequired(bool isRequired) {
    isBatchRequired = isRequired;
    notifyListeners();
  }
  void setIsScanCompleted(bool isCompleted) {
    isScanCompleted = isCompleted;
    notifyListeners();
  }
  void setIsFoodEntryAlreadyExists(bool isExists) {
    isFoodEntryAlreadyExists = isExists;
    notifyListeners();
  }
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
