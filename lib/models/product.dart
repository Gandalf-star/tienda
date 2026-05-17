class Product {
  final String id;
  String name;
  String description;
  double price;
  int quantity;
  bool isAvailable;
  List<String> images;
  String category;
  String? size;
  String? color;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.isAvailable = true,
    this.images = const [],
    this.category = 'General',
    this.size,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'images': images,
      'category': category,
      'size': size,
      'color': color,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      isAvailable: json['isAvailable'],
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? 'General',
      size: json['size'],
      color: json['color'],
    );
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    int? quantity,
    bool? isAvailable,
    List<String>? images,
    String? category,
    String? size,
    String? color,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      images: images ?? this.images,
      category: category ?? this.category,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}
