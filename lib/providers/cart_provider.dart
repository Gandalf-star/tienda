import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  void addToCart(Product product, {String? size, String? color}) {
    final existing = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size && item.selectedColor == color,
    );
    if (existing != -1) {
      _items[existing].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedSize: size, selectedColor: color));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.removeWhere(
      (i) => i.product.id == item.product.id && i.selectedSize == item.selectedSize && i.selectedColor == item.selectedColor,
    );
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    final index = _items.indexWhere(
      (i) => i.product.id == item.product.id && i.selectedSize == item.selectedSize && i.selectedColor == item.selectedColor,
    );
    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(CartItem item) {
    final index = _items.indexWhere(
      (i) => i.product.id == item.product.id && i.selectedSize == item.selectedSize && i.selectedColor == item.selectedColor,
    );
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
