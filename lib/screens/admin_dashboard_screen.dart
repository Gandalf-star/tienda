import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'admin_product_form_screen.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>().products;

    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.gold)));
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        title: Text('Panel Admin', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: AppTheme.gold), onPressed: () => _showConfigDialog(context)),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textMuted),
            onPressed: () { auth.logout(); Navigator.pushReplacementNamed(context, '/'); },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: products.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inventory_2_outlined, size: 56, color: AppTheme.gold.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('No hay productos', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Agrega tu primer producto', style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 13)),
            ]))
          : Column(children: [
              // Stats bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _stat('Total', '${products.length}', Icons.inventory_2_outlined),
                  Container(width: 1, height: 36, color: AppTheme.surfaceBorder),
                  _stat('Activos', '${products.where((p) => p.isAvailable).length}', Icons.check_circle_outline),
                  Container(width: 1, height: 36, color: AppTheme.surfaceBorder),
                  _stat('Agotados', '${products.where((p) => !p.isAvailable).length}', Icons.cancel_outlined),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (_, index) => _ProductListItem(product: products[index]),
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductFormScreen())),
        backgroundColor: AppTheme.gold, foregroundColor: AppTheme.bgPrimary,
        icon: const Icon(Icons.add), label: Text('Nuevo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(children: [
      Icon(icon, color: AppTheme.gold, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted)),
    ]);
  }

  void _showConfigDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final numberCtrl = TextEditingController(text: auth.whatsappNumber);
    final nameCtrl = TextEditingController(text: auth.storeName);

    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Configuración', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, style: GoogleFonts.poppins(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Nombre de la tienda', prefixIcon: Icon(Icons.store, color: AppTheme.gold))),
        const SizedBox(height: 14),
        TextField(controller: numberCtrl, style: GoogleFonts.poppins(color: AppTheme.textPrimary), keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Número WhatsApp', hintText: 'Ej: 584123456789', prefixIcon: Icon(Icons.phone, color: AppTheme.gold))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
        ElevatedButton(
          onPressed: () { auth.updateConfig(numberCtrl.text.trim(), nameCtrl.text.trim()); Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Configuración guardada', style: GoogleFonts.poppins()), backgroundColor: AppTheme.surfaceLight)); },
          child: Text('Guardar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }
}

class _ProductListItem extends StatelessWidget {
  final Product product;
  const _ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Row(children: [
        // Availability indicator
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: product.isAvailable ? AppTheme.success.withValues(alpha: 0.12) : AppTheme.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text('${product.quantity}', style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, fontSize: 16,
            color: product.isAvailable ? AppTheme.success : AppTheme.error))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text('\$${product.price.toStringAsFixed(2)} USD · ${product.category}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
        ])),
        IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.gold), onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProductFormScreen(product: product)))),
        IconButton(
          icon: Icon(product.isAvailable ? Icons.visibility : Icons.visibility_off, size: 20, color: AppTheme.textMuted),
          onPressed: () => provider.toggleAvailability(product.id)),
        IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error), onPressed: () => _confirmDelete(context, provider)),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text('Eliminar producto', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary)),
      content: Text('¿Eliminar "${product.name}"?', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textMuted))),
        ElevatedButton(
          onPressed: () { provider.deleteProduct(product.id); Navigator.pop(context); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
          child: Text('Eliminar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }
}
