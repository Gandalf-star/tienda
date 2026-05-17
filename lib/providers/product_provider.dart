import 'dart:math';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  ProductProvider() {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _products = await StorageService.loadProducts();
    if (_products.isEmpty) {
      _products = _demoProducts();
      await StorageService.saveProducts(_products);
    }
    notifyListeners();
  }

  List<Product> _demoProducts() {
    return [
      Product(
        id: '1',
        name: 'Camisa Casual',
        description: 'Camisa casual de algodon, perfecta para el dia a dia.',
        price: 25.00,
        quantity: 10,
        isAvailable: true,
        images: [],
        category: 'Camisas',
        size: 'M',
      ),
      Product(
        id: '2',
        name: 'Pantalon Jeans',
        description: 'Jeans clásico de mezclilla, corte recto.',
        price: 35.00,
        quantity: 8,
        isAvailable: true,
        images: [],
        category: 'Pantalones',
        size: '32',
      ),
      Product(
        id: '3',
        name: 'Vestido Elegante',
        description: 'Vestido para ocasiones especiales.',
        price: 45.00,
        quantity: 5,
        isAvailable: true,
        images: [],
        category: 'Vestidos',
        size: 'S',
      ),
    ];
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await StorageService.saveProducts(_products);
    notifyListeners();
  }

  Future<void> toggleAvailability(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].isAvailable = !_products[index].isAvailable;
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> addImage(String productId, String base64Image) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].images.add(base64Image);
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> removeImage(String productId, String base64Image) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].images.remove(base64Image);
      await StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
