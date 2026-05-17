import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class StorageService {
  static const String _productsKey = 'products';
  static const String _adminKey = 'admin_config';

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_productsKey, jsonEncode(jsonList));
  }

  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_productsKey);
    if (data == null) return [];
    final jsonList = jsonDecode(data) as List;
    return jsonList.map((e) => Product.fromJson(e)).toList();
  }

  static Future<void> saveAdminConfig(String whatsappNumber, String storeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminKey, jsonEncode({
      'whatsappNumber': whatsappNumber,
      'storeName': storeName,
    }));
  }

  static Future<Map<String, String>> loadAdminConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_adminKey);
    if (data == null) return {'whatsappNumber': '', 'storeName': 'Mi Boutique'};
    final config = jsonDecode(data) as Map<String, dynamic>;
    return {
      'whatsappNumber': config['whatsappNumber'] ?? '',
      'storeName': config['storeName'] ?? 'Mi Boutique',
    };
  }

  static Future<String> getWhatsAppNumber() async {
    final config = await loadAdminConfig();
    return config['whatsappNumber'] ?? '';
  }
}
