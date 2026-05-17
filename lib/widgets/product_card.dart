import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onEdit,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        transformAlignment: Alignment.center,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.gold.withValues(alpha: 0.4)
                    : AppTheme.surfaceBorder.withValues(alpha: 0.4),
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.bgPrimary.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            widget.product.category,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.goldLight,
                            ),
                          ),
                        ),
                      ),
                      // Availability badge
                      if (!widget.product.isAvailable)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Agotado',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      // Edit button (admin)
                      if (widget.onEdit != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: widget.onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.bgPrimary.withValues(alpha: 0.75),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: AppTheme.gold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Product info
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (widget.product.isAvailable)
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stock: ${widget.product.quantity}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.product.images.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(widget.product.images.first),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_outlined, size: 36, color: AppTheme.gold.withValues(alpha: 0.3)),
            const SizedBox(height: 6),
            Text(
              'Sin imagen',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
