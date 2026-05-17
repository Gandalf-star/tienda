import 'package:url_launcher/url_launcher.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class WhatsAppService {
  static Future<void> sendOrder(String phoneNumber, List<CartItem> items, double total) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final message = _buildMessage(items, total);
    final url = 'https://wa.me/$cleaned?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> sendInquiry(String phoneNumber, Product product, String question) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final message = _buildInquiryMessage(product, question);
    final url = 'https://wa.me/$cleaned?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _buildMessage(List<CartItem> items, double total) {
    final buffer = StringBuffer();
    buffer.writeln('✨ *Nuevo Pedido* ✨');
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━');
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('*${i + 1}. ${item.product.name}*');
      buffer.writeln('   💰 Precio: \$${item.product.price.toStringAsFixed(2)} USD');
      buffer.writeln('   📦 Cantidad: ${item.quantity}');
      if (item.selectedSize != null && item.selectedSize!.isNotEmpty) {
        buffer.writeln('   📏 Talla: ${item.selectedSize}');
      }
      if (item.selectedColor != null && item.selectedColor!.isNotEmpty) {
        buffer.writeln('   🎨 Color: ${item.selectedColor}');
      }
      buffer.writeln('   💵 Subtotal: \$${item.total.toStringAsFixed(2)} USD');
      buffer.writeln();
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━');
    buffer.writeln('*Total: \$${total.toStringAsFixed(2)} USD*');
    buffer.writeln();
    buffer.writeln('¡Gracias! 🛍️');
    return buffer.toString();
  }

  static String _buildInquiryMessage(Product product, String question) {
    final buffer = StringBuffer();
    buffer.writeln('💎 *Consulta sobre producto*');
    buffer.writeln();
    buffer.writeln('*Producto:* ${product.name}');
    buffer.writeln('*Precio:* \$${product.price.toStringAsFixed(2)} USD');
    buffer.writeln('*Categoría:* ${product.category}');
    buffer.writeln();
    buffer.writeln('*Pregunta:*');
    buffer.writeln(question);
    buffer.writeln();
    buffer.writeln('¡Gracias por su atención! 🙏');
    return buffer.toString();
  }
}
