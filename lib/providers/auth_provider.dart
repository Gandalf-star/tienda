import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  String _whatsappNumber = '';
  String get whatsappNumber => _whatsappNumber;

  String _storeName = 'Mi Boutique';
  String get storeName => _storeName;

  AuthProvider() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await StorageService.loadAdminConfig();
    _whatsappNumber = config['whatsappNumber']!;
    _storeName = config['storeName']!;
    notifyListeners();
  }

  bool login(String password) {
    if (password == 'admin123') {
      _isAdmin = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAdmin = false;
    notifyListeners();
  }

  Future<void> updateConfig(String number, String name) async {
    _whatsappNumber = number;
    _storeName = name;
    await StorageService.saveAdminConfig(number, name);
    notifyListeners();
  }
}
