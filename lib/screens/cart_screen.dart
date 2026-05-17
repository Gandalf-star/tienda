import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/whatsapp_service.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        title: Text('Mi Carrito', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: 1)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.gold), onPressed: () => Navigator.pop(context)),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: Text('Vaciar', style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13)),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: items.isEmpty ? _emptyState() : _cartContent(context, cart, items),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Icon(Icons.shopping_bag_outlined, size: 56, color: AppTheme.gold.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 24),
        Text('Tu carrito está vacío', style: GoogleFonts.playfairDisplay(fontSize: 22, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Explora nuestra colección y encuentra algo especial', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _cartContent(BuildContext context, CartProvider cart, List items) {
    return Column(children: [
      // Items count
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${cart.itemCount} artículos', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted)),
          Text('Desliza para eliminar →', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
        ]),
      ),
      // Cart items
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];
            return Dismissible(
              key: Key('${item.product.id}_${item.selectedSize}_${item.selectedColor}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => cart.removeFromCart(item),
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.delete_outline, color: AppTheme.error, size: 28),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.cardDecoration,
                child: Row(children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 70, height: 70,
                      child: item.product.images.isNotEmpty
                          ? Image.memory(base64Decode(item.product.images.first), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _thumbPlaceholder())
                          : _thumbPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      if (item.selectedSize != null && item.selectedSize!.isNotEmpty)
                        Text('Talla: ${item.selectedSize}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
                      if (item.selectedColor != null && item.selectedColor!.isNotEmpty)
                        Text('Color: ${item.selectedColor}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
                      Text('\$${item.product.price.toStringAsFixed(2)} USD', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                  // Quantity controls
                  Container(
                    decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.surfaceBorder)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _qtyBtn(Icons.remove, () => cart.decreaseQuantity(item)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.quantity}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14)),
                      ),
                      _qtyBtn(Icons.add, () => cart.increaseQuantity(item)),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      // Bottom summary
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.surfaceBorder.withValues(alpha: 0.5))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, -8))],
        ),
        child: SafeArea(
          child: Column(children: [
            // Subtotal
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Subtotal', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
              Text('\$${cart.total.toStringAsFixed(2)} USD', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('\$${cart.total.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.gold)),
            ]),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _sendOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.whatsapp, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text('Enviar pedido por WhatsApp', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _thumbPlaceholder() => Container(
    color: AppTheme.surfaceLight,
    child: Icon(Icons.diamond_outlined, color: AppTheme.gold.withValues(alpha: 0.3), size: 28),
  );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 16, color: AppTheme.gold)),
  );

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text('Vaciar carrito', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary)),
      content: Text('¿Deseas eliminar todos los artículos?', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
        ElevatedButton(
          onPressed: () { cart.clear(); Navigator.pop(context); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          child: Text('Vaciar', style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    ));
  }

  Future<void> _sendOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final number = auth.whatsappNumber;
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay número de WhatsApp configurado')));
      return;
    }
    await WhatsAppService.sendOrder(number, cart.items, cart.total);
  }
}
