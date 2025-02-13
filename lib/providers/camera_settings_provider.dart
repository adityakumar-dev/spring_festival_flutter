import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraSettingsProvider extends ChangeNotifier {
  static const String _frontCameraRotationKey = 'front_camera_rotation_angle';
  static const String _backCameraRotationKey = 'back_camera_rotation_angle';
  final SharedPreferences _prefs;
  
  double _frontCameraRotation;
  double _backCameraRotation;

  CameraSettingsProvider(this._prefs) : 
    _frontCameraRotation = _prefs.getDouble(_frontCameraRotationKey) ?? 0.0,
    _backCameraRotation = _prefs.getDouble(_backCameraRotationKey) ?? 0.0;

  double getRotationAngle(bool isFrontCamera) {
    return isFrontCamera ? _frontCameraRotation : _backCameraRotation;
  }

  Future<void> setRotationAngle(double? angle, bool isFrontCamera) async {
    if (isFrontCamera) {
      _frontCameraRotation = angle ?? 0.0;
      await _prefs.setDouble(_frontCameraRotationKey, angle ?? 0.0);
    } else {
      _backCameraRotation = angle ?? 0.0;
      await _prefs.setDouble(_backCameraRotationKey, angle ?? 0.0);
    }
    notifyListeners();
  }
} 