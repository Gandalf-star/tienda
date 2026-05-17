import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  bool _showSearch = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>().products;
    final cartCount = context.watch<CartProvider>().itemCount;
    final available = products.where((p) => p.isAvailable).toList();
    final width = MediaQuery.of(context).size.width;

    // Get categories
    final categories = ['Todos', ...{...available.map((p) => p.category)}];

    // Filter
    var filtered = _selectedCategory == 'Todos'
        ? available
        : available.where((p) => p.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Responsive columns
    int crossAxisCount = 2;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 800) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: true,
            backgroundColor: AppTheme.bgPrimary,
            surfaceTintColor: Colors.transparent,
            expandedHeight: _showSearch ? 130 : 70,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgPrimary,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.surfaceBorder.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.diamond, color: AppTheme.bgPrimary, size: 18),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    auth.storeName.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              // Search toggle
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.search_off : Icons.search,
                  color: AppTheme.gold,
                ),
                onPressed: () => setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) _searchQuery = '';
                }),
              ),
              // Cart
              _buildCartButton(cartCount),
              // Admin
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppTheme.textMuted, size: 22),
                onPressed: () {
                  if (auth.isAdmin) {
                    Navigator.pushNamed(context, '/admin');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
            bottom: _showSearch
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        autofocus: true,
                        style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Buscar productos...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),

          // ─── Category filters ──────────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.gold : AppTheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.gold
                                : AppTheme.surfaceBorder.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppTheme.bgPrimary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ─── Results count ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'Todos' ? 'Colección' : _selectedCategory,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${filtered.length} artículos',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (auth.whatsappNumber.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone, color: AppTheme.whatsapp, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                auth.whatsappNumber,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Product Grid ──────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppTheme.gold.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay productos disponibles',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prueba con otra categoría o búsqueda',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filtered[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ProductCard(
                            product: product,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCartButton(int cartCount) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.gold, size: 24),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
        if (cartCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$cartCount',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bgPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
