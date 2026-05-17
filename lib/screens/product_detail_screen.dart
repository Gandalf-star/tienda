import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/image_zoom_viewer.dart';
import '../widgets/inquiry_bottom_sheet.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late PageController _productPageController;
  late List<Product> _categoryProducts;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    // Get all available products in the same category
    _categoryProducts = provider.products
        .where((p) => p.isAvailable && p.category == widget.product.category)
        .toList();
    
    // If for some reason the current product is not in the list (e.g. not available), add it
    if (!_categoryProducts.any((p) => p.id == widget.product.id)) {
      _categoryProducts.insert(0, widget.product);
    }
    
    final initialIndex = _categoryProducts.indexWhere((p) => p.id == widget.product.id);
    _productPageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
  }

  @override
  void dispose() {
    _productPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: PageView.builder(
        controller: _productPageController,
        itemCount: _categoryProducts.length,
        itemBuilder: (context, index) {
          return _ProductDetailView(product: _categoryProducts[index]);
        },
      ),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  String? selectedSize;
  String? selectedColor;
  final TextEditingController _customSizeCtrl = TextEditingController();
  final TextEditingController _customColorCtrl = TextEditingController();

  int currentImage = 0;
  late final PageController _imagePageController;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _customSizeCtrl.dispose();
    _customColorCtrl.dispose();
    super.dispose();
  }

  List<String> _parseOptions(String? optionsStr) {
    if (optionsStr == null || optionsStr.trim().isEmpty) return [];
    return optionsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final sizes = _parseOptions(widget.product.size);
    final colors = _parseOptions(widget.product.color);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          backgroundColor: AppTheme.bgPrimary,
          leading: _backBtn(),
          flexibleSpace: FlexibleSpaceBar(background: _imageCarousel()),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _productInfo(cart, sizes, colors),
            ),
          ),
        ),
      ],
    );
  }

  Widget _backBtn() => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
      ),
      child: const Icon(Icons.arrow_back, color: AppTheme.gold, size: 22),
    ),
  );

  Widget _imageCarousel() {
    if (widget.product.images.isEmpty) {
      return Container(
        color: AppTheme.surfaceLight,
        child: Center(
          child: Icon(Icons.diamond_outlined, size: 72, color: AppTheme.gold.withValues(alpha: 0.2)),
        ),
      );
    }
    return Stack(
      children: [
        GestureDetector(
          onTap: () => ImageZoomViewer.show(context, widget.product.images, initialIndex: currentImage),
          child: PageView.builder(
            controller: _imagePageController,
            itemCount: widget.product.images.length,
            onPageChanged: (i) => setState(() => currentImage = i),
            itemBuilder: (_, index) {
              try {
                return Image.memory(base64Decode(widget.product.images[index]), fit: BoxFit.cover);
              } catch (_) {
                return Container(color: AppTheme.surfaceLight, child: const Center(child: Icon(Icons.broken_image)));
              }
            },
          ),
        ),
        Positioned(
          bottom: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.zoom_in, color: AppTheme.gold, size: 16),
              const SizedBox(width: 4),
              Text('Ampliar', style: GoogleFonts.poppins(color: AppTheme.goldLight, fontSize: 11)),
            ]),
          ),
        ),
        if (widget.product.images.length > 1)
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.product.images.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == currentImage ? 24 : 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: i == currentImage ? AppTheme.gold : Colors.white.withValues(alpha: 0.4),
                ),
              )),
            ),
          ),
      ],
    );
  }

  Widget _productInfo(CartProvider cart, List<String> sizes, List<String> colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Category chip + swipe indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Text(widget.product.category, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.gold)),
            ),
            Row(
              children: [
                Icon(Icons.swipe_left, color: AppTheme.textMuted.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 6),
                Text('Desliza para ver más', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted.withValues(alpha: 0.8))),
                const SizedBox(width: 6),
                Icon(Icons.swipe_right, color: AppTheme.textMuted.withValues(alpha: 0.5), size: 16),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(widget.product.name, style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        // Price
        Row(children: [
          Text('\$${widget.product.price.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.gold)),
          const SizedBox(width: 8),
          Text('USD', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (widget.product.isAvailable ? AppTheme.success : AppTheme.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.product.isAvailable ? AppTheme.success : AppTheme.error, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(widget.product.isAvailable ? '${widget.product.quantity} disponibles' : 'Agotado',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: widget.product.isAvailable ? AppTheme.success : AppTheme.error)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        Divider(color: AppTheme.surfaceBorder.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        // Description
        Text('Descripción', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text(widget.product.description, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
        
        // Sizes
        const SizedBox(height: 20),
        Text('Talla', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        if (sizes.isNotEmpty)
          Wrap(spacing: 10, runSpacing: 10, children: sizes.map((s) {
            final sel = selectedSize == s;
            return GestureDetector(
              onTap: () => setState(() => selectedSize = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.gold : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppTheme.gold : AppTheme.surfaceBorder),
                ),
                child: Text(s, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? AppTheme.bgPrimary : AppTheme.textSecondary)),
              ),
            );
          }).toList())
        else
          TextField(
            controller: _customSizeCtrl,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ej. M, L, 38, 40 (Opcional)',
              hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted),
              filled: true, fillColor: AppTheme.surfaceLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => selectedSize = v,
          ),
          
        // Colors
        const SizedBox(height: 20),
        Text('Color', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        if (colors.isNotEmpty)
          Wrap(spacing: 10, runSpacing: 10, children: colors.map((c) {
            final sel = selectedColor == c;
            return GestureDetector(
              onTap: () => setState(() => selectedColor = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.gold : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppTheme.gold : AppTheme.surfaceBorder),
                ),
                child: Text(c, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? AppTheme.bgPrimary : AppTheme.textSecondary)),
              ),
            );
          }).toList())
        else
          TextField(
            controller: _customColorCtrl,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ej. Rojo, Azul, Negro (Opcional)',
              hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted),
              filled: true, fillColor: AppTheme.surfaceLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => selectedColor = v,
          ),

        const SizedBox(height: 28),
        // Add to cart
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.product.isAvailable ? () {
              // Get custom values if any
              final finalSize = sizes.isNotEmpty ? selectedSize : _customSizeCtrl.text.trim();
              final finalColor = colors.isNotEmpty ? selectedColor : _customColorCtrl.text.trim();
              
              cart.addToCart(
                widget.product, 
                size: finalSize?.isEmpty == true ? null : finalSize, 
                color: finalColor?.isEmpty == true ? null : finalColor,
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(children: [
                  const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const SizedBox(width: 10),
                  Text('Agregado al carrito', style: GoogleFonts.poppins()),
                ]),
                backgroundColor: AppTheme.surfaceLight,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold, foregroundColor: AppTheme.bgPrimary,
              disabledBackgroundColor: AppTheme.surfaceLight, disabledForegroundColor: AppTheme.textMuted,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.shopping_bag_outlined, size: 20),
              const SizedBox(width: 10),
              Text('Agregar al carrito', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        // Inquiry
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => InquiryBottomSheet.show(context, widget.product),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gold,
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.chat_bubble_outline, size: 18),
              const SizedBox(width: 10),
              Text('¿Tienes preguntas? Consúltanos', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}
