import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../core/utils/format_utils.dart';
import '../core/widgets/product_image.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  String _search = '';
  String? _selectedCategory;
  final _searchController = TextEditingController();

  // Carousel
  final _pageController = PageController();
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  List<String> _buildCategories(List<ProductModel> products) {
    final cats = products.map((p) => p.category).toSet().toList()..sort();
    return ['Todos', ...cats];
  }

  static const List<Map<String, String>> _banners = [
    {
      'image': 'assets/images/banners/banner1.png',
      'title': 'Smartphones de última generación',
      'subtitle': 'Descubre los mejores modelos',
    },
    {
      'image': 'assets/images/banners/banner2.png',
      'title': 'Audio Premium',
      'subtitle': 'Sonido que te transporta',
    },
    {
      'image': 'assets/images/banners/banner3.png',
      'title': 'Accesorios Tech',
      'subtitle': 'Todo para tu día a día digital',
    },
    {
      'image': 'assets/images/banners/banner4.png',
      'title': 'Ofertas Especiales',
      'subtitle': 'Hasta 30% de descuento',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_carouselIndex + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  List<ProductModel> _filtered(List<ProductModel> products) {
    return products.where((p) {
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase());
      final matchCategory = _selectedCategory == null ||
          _selectedCategory == 'Todos' ||
          p.category.toLowerCase().contains(_selectedCategory!.toLowerCase());
      return matchSearch && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FluxShop', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(user, cartProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).pushNamed(AppRoutes.cart);
          } else if (i == 2) {
            Navigator.of(context).pushNamed(AppRoutes.profile);
          } else {
            setState(() => _currentTab = 0);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle),
                      child: Text('${cartProvider.itemCount}',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Perfil'),
        ],
      ),
      body: Column(
        children: [
          _buildCarousel(user?.name.isNotEmpty == true ? user!.name.split(' ').first : (user?.username ?? 'usuario')),
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildDrawer(dynamic user, CartProvider cartProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A3D62), Color(0xFF1565C0)],
              ),
            ),
            accountName: Text('${user?.name ?? ''} ${user?.apellidos ?? ''}'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white24,
              backgroundImage: user?.photo != null
                  ? MemoryImage(base64Decode(user!.photo!))
                  : null,
              child: user?.photo == null
                  ? Text(
                      (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Mis Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.orders);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(String firstName) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemBuilder: (context, i) {
              final banner = _banners[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    banner['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: const Color(0xFF161B22)),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Colors.transparent, Color(0xCC0D1117)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¡Hola, $firstName!',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          banner['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner['subtitle']!,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Dots indicadores
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _carouselIndex == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _carouselIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFF21262D),
        ),
        onChanged: (v) => setState(() => _search = v),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final products = context.read<ProductProvider>().products;
    final categories = _buildCategories(products);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final selected = (_selectedCategory == null && cat == 'Todos') ||
              _selectedCategory == cat;
          return FilterChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => setState(() {
              _selectedCategory = cat == 'Todos' ? null : cat;
            }),
            selectedColor: const Color(0xFF00E5FF),
            labelStyle: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final productProvider = context.watch<ProductProvider>();

    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = _filtered(productProvider.products);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _search.isNotEmpty ? 'Sin resultados para "$_search"' : 'No hay productos',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProductProvider>().refresh(),
      color: const Color(0xFF00E5FF),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _AnimatedProductCard(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: product),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImage(imageUrl: product.imageUrl, productName: product.name, height: 130),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCOP(product.price),
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedProductCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedProductCard({required this.child, required this.onTap});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: AnimatedSlide(
          offset: _pressed ? const Offset(0, 0.02) : Offset.zero,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
