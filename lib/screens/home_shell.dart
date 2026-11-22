import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/catalog_provider.dart';
import '../services/launcher_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_login_dialog.dart';
import '../widgets/mobile_drawer.dart';
import '../widgets/product_details_sheet.dart';
import '../widgets/responsive_breakpoints.dart';

/// The primary application shell faithfully implementing the Wakshe Agrotech
/// store design specification with responsive layouts for Mobile, Tablet, and Desktop Web.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _productsKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToProducts() {
    final ctx = _productsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _showCartSheet(BuildContext context, CatalogProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CartBottomSheet(provider: provider),
    );
  }

  void _showProductDialog(
    BuildContext context,
    CatalogProvider provider, {
    Product? productToEdit,
  }) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _ProductEditDialog(provider: provider, product: productToEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final isShop = provider.isShopView;
    final isAdmin = provider.isAdminView;
    final isAccount = provider.isAccountView;
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.cream,
      // Mobile Drawer (navigation hidden in topbar on mobile is placed here)
      drawer: isMobile
          ? MobileDrawer(
              provider: provider,
              onOpenCart: () => _showCartSheet(context, provider),
            )
          : null,
      // Fixed Material 3 Bottom Navigation Bar for Mobile (< 600px)
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: isShop ? 0 : (isAccount ? 2 : 0),
              onDestinationSelected: (index) {
                if (index == 0) {
                  provider.showShopView();
                } else if (index == 1) {
                  _showCartSheet(context, provider);
                } else if (index == 2) {
                  provider.showAccountView();
                }
              },
              backgroundColor: Colors.white,
              indicatorColor: AppColors.lime,
              elevation: 4,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Shop',
                ),
                NavigationDestination(
                  icon: Badge.count(
                    count: provider.cartCount,
                    isLabelVisible: provider.cartCount > 0,
                    backgroundColor: AppColors.green,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge.count(
                    count: provider.cartCount,
                    isLabelVisible: provider.cartCount > 0,
                    backgroundColor: AppColors.green,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Topbar
            _buildTopBar(context, provider, isMobile),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isShop) ...[
                          _buildHeroSection(context, isMobile),
                          _buildFeatureHighlights(isMobile),
                          _buildProductsSection(context, provider, isMobile),
                        ] else if (isAdmin) ...[
                          _buildAdminView(context, provider, isMobile),
                        ] else if (isAccount) ...[
                          _buildAccountView(context, provider, isMobile),
                        ],
                        _buildFooter(isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOPBAR (Responsive Mobile vs Desktop)
  // ==========================================
  Widget _buildTopBar(
    BuildContext context,
    CatalogProvider provider,
    bool isMobile,
  ) {
    final isShop = provider.isShopView;
    final isAdmin = provider.isAdminView;

    // Mobile Header (< 600px): Compact header with logo, cart badge, and hamburger menu.
    // Desktop Shop & Admin buttons are removed from top bar and placed in drawer / bottom nav.
    if (isMobile) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.green,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10291B).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brand Logo & Title on Mobile (Flexibly sized)
            Expanded(
              child: InkWell(
                onTap: provider.showShopView,
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 34,
                        height: 34,
                        color: Colors.white,
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          'assets/app_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: AppColors.lime,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text('🌾', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WAKSHE AGROTECH',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'TOOLS FOR EVERY FIELD',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFC7D8C9),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Mobile Right Actions: Cart Icon with Live Count & Hamburger Menu Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shopping Cart Button with Live Count Badge
                InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => _showCartSheet(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lime,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${provider.cartCount}',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 2),

                // Hamburger Menu Button (opens drawer)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 22),
                  tooltip: 'Open navigation menu',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Tablet & Desktop TopBar (Existing preserved design)
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.green,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10291B).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo & Title
          InkWell(
            onTap: provider.showShopView,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.white,
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(
                      'assets/app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🌾', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAKSHE AGROTECH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'TOOLS FOR EVERY FIELD',
                      style: TextStyle(
                        color: Color(0xFFC7D8C9),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top Action Buttons (Shop, Admin, Cart)
          Row(
            children: [
              // Shop Tab Button
              _TopNavButton(
                title: 'Shop',
                isActive: isShop,
                onPressed: provider.showShopView,
              ),
              const SizedBox(width: 8),

              // Admin Tab Button
              _TopNavButton(
                title: 'Admin',
                isActive: isAdmin,
                onPressed: provider.showAdminView,
              ),
              const SizedBox(width: 10),

              // Cart Button
              InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => _showCartSheet(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.26),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '🛒 Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${provider.cartCount}',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HERO SECTION (Responsive with real agricultural artwork)
  // ==========================================
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 14 : 20,
        isMobile ? 16 : 24,
        isMobile ? 14 : 20,
        isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        gradient: const LinearGradient(
          colors: [AppColors.green, AppColors.green2, AppColors.greenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680 || isMobile;

          if (isNarrow) {
            return Padding(
              padding: EdgeInsets.all(isMobile ? 18 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCopy(context, isMobile: true),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Image.asset(
                        'assets/1000562171.png',
                        height: isMobile ? 140 : 180,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 130,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.agriculture_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(42),
                  child: _buildHeroCopy(context, isMobile: false),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Image.asset(
                      'assets/1000562171.png',
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.agriculture_rounded,
                        size: 130,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCopy(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Proprietor Brand Tag
        Container(
          margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✦ ', style: TextStyle(color: AppColors.gold, fontSize: 10)),
              Flexible(
                child: Text(
                  '${LauncherHelper.proprietor} — ${LauncherHelper.businessRole}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 10.5 : 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'BUILT FOR THE HANDS THAT GROW',
          style: TextStyle(
            color: const Color(0xFFD9E8BD),
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 10 : 11,
            letterSpacing: isMobile ? 1.5 : 2,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Text(
          LauncherHelper.mainSlogan,
          style: TextStyle(
            color: const Color(0xFFE2ECDF),
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 10.5 : 12,
            letterSpacing: isMobile ? 0.6 : 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          'Strong tools.\nStronger harvests.',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 25 : 34,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        // Authentic Marathi Quality Quote & Trust Tagline
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Text(
            '${LauncherHelper.qualityQuote}\n${LauncherHelper.trustTagline}',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: const Color(0xFFF2E6CE),
              fontSize: isMobile ? 11 : 12.5,
              height: 1.35,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 14 : 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.green,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 12 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                elevation: 0,
              ),
              onPressed: _scrollToProducts,
              child: const Text(
                'Explore products →',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 18,
                  vertical: isMobile ? 12 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(Icons.phone_in_talk, size: 16, color: AppColors.gold),
              label: Text(
                'Call: ${LauncherHelper.phoneDisplay}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
              onPressed: () => LauncherHelper.callSupport(),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // FEATURE HIGHLIGHT TILES
  // ==========================================
  Widget _buildFeatureHighlights(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 740 || isMobile;

          final items = [
            const _FeatureCard(
              emoji: '⚒️',
              title: 'Hand-forged quality',
              subtitle: 'Made for demanding farm work',
            ),
            const _FeatureCard(
              emoji: '🚚',
              title: 'Delivery across India',
              subtitle: 'Reach from village to city',
            ),
            const _FeatureCard(
              emoji: '🤝',
              title: 'Farmer-first support',
              subtitle: 'Help choosing the right tool',
            ),
          ];

          if (isNarrow) {
            return Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: item,
                    ),
                  )
                  .toList(),
            );
          }

          return Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: item,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  // ==========================================
  // PRODUCTS SECTION & TOOLBAR
  // ==========================================
  Widget _buildProductsSection(
    BuildContext context,
    CatalogProvider provider,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: 16,
      ),
      child: Column(
        key: _productsKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Filters Toolbar
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 780 || isMobile;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore our products',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Practical tools for your farm, garden and workshop.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),

                  // Search + Category Filters Row
                  if (isNarrow) ...[
                    _buildSearchBar(provider),
                    const SizedBox(height: 12),
                    _buildCategoryPills(provider),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 290, child: _buildSearchBar(provider)),
                        _buildCategoryPills(provider),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Product Grid
          _buildProductGrid(context, provider, isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CatalogProvider provider) {
    return TextField(
      controller: _searchController,
      onChanged: provider.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search tools...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.muted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
              )
            : null,
      ),
    );
  }

  /// Horizontal scrolling category filters
  Widget _buildCategoryPills(CatalogProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: provider.categories.map((category) {
          final isSelected = provider.activeCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => provider.setCategory(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.green : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.green : AppColors.line,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4E5A50),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    CatalogProvider provider,
    bool isMobile,
  ) {
    final products = provider.filteredProducts;

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'No products found. Try another search or category.',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
              },
              child: const Text('Reset filters'),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 4;
    double childAspectRatio = 0.68;
    double spacing = 16;

    if (isMobile || screenWidth < 600) {
      // Exactly 2 columns on mobile screens!
      crossAxisCount = 2;
      childAspectRatio = 0.58;
      spacing = 12;
    } else if (screenWidth < 1024) {
      // Tablet: 600px - 1023px
      crossAxisCount = 3;
      childAspectRatio = 0.68;
      spacing = 16;
    } else {
      // Desktop: 1024px and above
      crossAxisCount = 4;
      childAspectRatio = 0.68;
      spacing = 16;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          isMobile: crossAxisCount == 2,
          onTap: () {
            ProductDetailsSheet.show(
              context,
              product: product,
              provider: provider,
            );
          },
          onAddToCart: () {
            final success = provider.addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1800),
                backgroundColor: success
                    ? AppColors.green
                    : AppColors.outOfStockText,
                content: Text(
                  success
                      ? 'Added "${product.name}" to cart 🛒'
                      : 'This product is currently out of stock.',
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ADMIN DASHBOARD VIEW (Responsive Table vs Mobile Cards)
  // ==========================================
  Widget _buildAdminView(
    BuildContext context,
    CatalogProvider provider,
    bool isMobile,
  ) {
    final products = provider.allProducts;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin dashboard',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Manage your catalogue and keep product information up to date.',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (provider.isAdminAuthenticated)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppColors.muted,
                  ),
                  label: const Text(
                    'Lock',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  onPressed: () {
                    provider.logoutAdmin();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Admin session locked.')),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Card
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A3820).withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header row of the card with Add button
                if (isMobile) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Product catalogue',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${products.length} products total',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        onPressed: () => _showProductDialog(context, provider),
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text('Add product', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product catalogue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${products.length} products · Edit details, stock and pricing',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _showProductDialog(context, provider),
                        child: const Text('＋ Add product'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // If Mobile: Render Responsive Product Cards!
                // If Desktop/Tablet: Render existing DataTable!
                if (isMobile) ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColors.line, height: 20),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return _buildMobileAdminProductCard(context, provider, p);
                    },
                  ),
                ] else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('PRODUCT')),
                        DataColumn(label: Text('CATEGORY')),
                        DataColumn(label: Text('PRICE')),
                        DataColumn(label: Text('STOCK')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: products.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        p.description.length > 40
                                            ? '${p.description.substring(0, 40)}…'
                                            : p.description,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(p.category)),
                            DataCell(
                              Text(
                                p.formattedPrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text('${p.stock}')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: p.isAvailable
                                      ? AppColors.inStockBg
                                      : AppColors.outOfStockBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.isAvailable ? 'In stock' : 'Out of stock',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: p.isAvailable
                                        ? AppColors.inStockText
                                        : AppColors.outOfStockText,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.line,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _showProductDialog(
                                      context,
                                      provider,
                                      productToEdit: p,
                                    ),
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.line,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _confirmDelete(
                                      context,
                                      provider,
                                      p.id,
                                      p.name,
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: AppColors.outOfStockText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Demo note: changes are saved in this session. A real multi-user app needs an authenticated admin backend and database.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAdminProductCard(
    BuildContext context,
    CatalogProvider provider,
    Product p,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.featureBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                alignment: Alignment.center,
                child: Text(p.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.category} · ${p.formattedPrice}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.isAvailable
                      ? AppColors.inStockBg
                      : AppColors.outOfStockBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.isAvailable ? '${p.stock} in stock' : 'Out of stock',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: p.isAvailable
                        ? AppColors.inStockText
                        : AppColors.outOfStockText,
                  ),
                ),
              ),
            ],
          ),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              p.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showProductDialog(
                  context,
                  provider,
                  productToEdit: p,
                ),
                icon: const Icon(Icons.edit, size: 14, color: AppColors.green),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _confirmDelete(
                  context,
                  provider,
                  p.id,
                  p.name,
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: AppColors.outOfStockText,
                ),
                label: const Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.outOfStockText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACCOUNT & PROFILE VIEW (Customer & Admin access)
  // ==========================================
  Widget _buildAccountView(
    BuildContext context,
    CatalogProvider provider,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Profile & Account',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Manage your orders, farm equipment enquiries and account settings.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 20),

          // Customer Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.lime,
                  child: const Text('👨‍🌾', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmer Partner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Wakshe Agrotech Field Member · Maharashtra',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cart Quick Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: AppColors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Shopping Cart Status',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${provider.cartCount} item(s) in cart',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.formattedCartTotal,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showCartSheet(context, provider),
                    child: const Text(
                      'Open Shopping Cart',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Administrator Section Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      provider.isAdminAuthenticated
                          ? Icons.admin_panel_settings
                          : Icons.lock_outline,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Administrator Portal',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: provider.isAdminAuthenticated
                            ? AppColors.inStockBg
                            : AppColors.featureBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        provider.isAdminAuthenticated ? 'Unlocked' : 'Protected',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: provider.isAdminAuthenticated
                              ? AppColors.inStockText
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access product catalogue management, stock modifications, and price adjustments.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (provider.isAdminAuthenticated) {
                            provider.showAdminView();
                          } else {
                            AdminLoginDialog.show(context, provider);
                          }
                        },
                        child: Text(
                          provider.isAdminAuthenticated
                              ? 'Go to Admin Dashboard'
                              : 'Admin Passcode Login',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (provider.isAdminAuthenticated) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          provider.logoutAdmin();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin session locked.'),
                            ),
                          );
                        },
                        child: const Text('Lock'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Direct WhatsApp & Field Support Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.featureBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.chat_outlined, color: AppColors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Farmer Field Support',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Have questions about tool sizes, bulk village orders, or custom blades? Contact Wakshe Agrotech on WhatsApp.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Enquire via WhatsApp'),
                  onPressed: () {
                    final msg = provider.cart.isNotEmpty
                        ? provider.generateEnquiryMessage()
                        : 'नमस्कार, मला वाक्षे ॲग्रोटेक (प्रो. माया वाक्षे) शेती अवजारांबद्दल माहिती हवी आहे.';
                    LauncherHelper.openWhatsApp(msg);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Official Proprietor & Factory Support Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.gold, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        LauncherHelper.proprietor,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  '${LauncherHelper.businessRole} · शिवकालीन परंपरा व राजस्थानी लोहार कारागिरी',
                  style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.featureBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LauncherHelper.qualityQuote,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        LauncherHelper.trustTagline,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone_in_talk, size: 18, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'मोबाईल / फोन: ${LauncherHelper.phoneDisplay}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Full Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 18, color: AppColors.green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        LauncherHelper.fullAddress,
                        style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons: Call, WhatsApp, Google Maps
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Support'),
                      onPressed: () => LauncherHelper.callSupport(),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('WhatsApp'),
                      onPressed: () => LauncherHelper.openWhatsApp(),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.line),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 16, color: AppColors.gold),
                      label: const Text('Google Maps'),
                      onPressed: () => LauncherHelper.openMap(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CatalogProvider provider,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to remove "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.outOfStockText,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.deleteProduct(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Product deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FOOTER (Responsive Mobile vs Desktop with Proprietor & Contact details)
  // ==========================================
  Widget _buildFooter(bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 36),
      color: AppColors.footerBg,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 24,
        vertical: isMobile ? 22 : 28,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'वाक्षे ॲग्रोटेक · WAKSHE AGROTECH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '${LauncherHelper.proprietor} — ${LauncherHelper.businessRole}',
                  style: TextStyle(color: AppColors.gold, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  LauncherHelper.fullAddress,
                  style: TextStyle(color: Color(0xFFD8E4D8), fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    InkWell(
                      onTap: () => LauncherHelper.callSupport(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, size: 14, color: AppColors.gold),
                          SizedBox(width: 4),
                          Text(
                            LauncherHelper.phoneDisplay,
                            style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => LauncherHelper.openMap(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, size: 14, color: AppColors.lime),
                          SizedBox(width: 4),
                          Text(
                            'Google Maps ↗',
                            style: TextStyle(color: AppColors.lime, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '✦ विश्वासाचं नाव, शेतकऱ्यांचं काम ✦ • शिवकालीन परंपरेतील कारागिरी',
                  style: TextStyle(color: Color(0xFF9FB2A2), fontSize: 10.5),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'वाक्षे ॲग्रोटेक · WAKSHE AGROTECH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '${LauncherHelper.proprietor} — ${LauncherHelper.businessRole}',
                        style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        LauncherHelper.fullAddress,
                        style: TextStyle(color: Color(0xFFD8E4D8), fontSize: 11.5),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '${LauncherHelper.qualityQuote} • ${LauncherHelper.trustTagline}',
                        style: TextStyle(color: Color(0xFF9FB2A2), fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => LauncherHelper.callSupport(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_in_talk, size: 16, color: AppColors.gold),
                          SizedBox(width: 6),
                          Text(
                            LauncherHelper.phoneDisplay,
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => LauncherHelper.openMap(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 15, color: AppColors.lime),
                          SizedBox(width: 4),
                          Text(
                            'Open Factory in Google Maps ↗',
                            style: TextStyle(color: AppColors.lime, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ==========================================
// SUB-WIDGETS & MODALS
// ==========================================

class _TopNavButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onPressed;

  const _TopNavButton({
    required this.title,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive
                ? AppColors.lime
                : Colors.white.withValues(alpha: 0.26),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.green : Colors.white,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.featureBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isMobile;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    this.isMobile = false,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF183B1A).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Art & Tag
            Container(
              height: isMobile ? 100 : 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [AppColors.artGradientStart, AppColors.artGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      product.icon,
                      style: TextStyle(fontSize: isMobile ? 42 : 64),
                    ),
                  ),
                  Positioned(
                    top: isMobile ? 6 : 10,
                    left: isMobile ? 6 : 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 2.5 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.tag,
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF78906E),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: isMobile ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 10.5 : 11.5,
                        color: AppColors.muted,
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.formattedPrice,
                            style: TextStyle(
                              fontSize: isMobile ? 14.5 : 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 11,
                              vertical: isMobile ? 5 : 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            minimumSize: isMobile ? const Size(32, 28) : null,
                          ),
                          onPressed: onAddToCart,
                          child: Text(
                            isMobile ? 'Add +' : 'Add to cart +',
                            style: TextStyle(
                              fontSize: isMobile ? 10.5 : 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cart Bottom Sheet with full item list, stepper, and WhatsApp enquiry checkout
class _CartBottomSheet extends StatelessWidget {
  final CatalogProvider provider;

  const _CartBottomSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cart = provider.cart;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(22),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'Your cart is empty. Add a product to get started.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cart.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.line),
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          item.product.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${item.quantity} × ${item.product.formattedPrice}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Qty Stepper
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                              onPressed: () => provider.updateCartQuantity(
                                item.product.id,
                                item.quantity - 1,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              onPressed: () => provider.updateCartQuantity(
                                item.product.id,
                                item.quantity + 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.formattedTotalPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    provider.formattedCartTotal,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Continue shopping',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final enquiry = provider.generateEnquiryMessage();
                      Clipboard.setData(ClipboardData(text: enquiry));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.green,
                          content: Text(
                            'Enquiry message copied to clipboard! Ready to share via WhatsApp.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Place enquiry',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog for Adding or Editing a Product in Admin Mode
class _ProductEditDialog extends StatefulWidget {
  final CatalogProvider provider;
  final Product? product;

  const _ProductEditDialog({required this.provider, this.product});

  @override
  State<_ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<_ProductEditDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _descCtrl;
  String _selectedCategory = 'Cutting';

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? '${p.price.round()}' : '',
    );
    _stockCtrl = TextEditingController(text: p != null ? '${p.stock}' : '10');
    _iconCtrl = TextEditingController(text: p?.icon ?? '🌾');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    if (p != null && ['Cutting', 'Digging', 'Other'].contains(p.category)) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _iconCtrl.dispose();
    _imageUrlCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit product' : 'Add product',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  hintText: 'e.g. Hand-forged Koyta',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Cutting', 'Digging', 'Other']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        hintText: '499',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock quantity',
                        hintText: '20',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _iconCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Icon / emoji',
                        hintText: '🌾',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Image URL / Asset (optional)',
                  hintText: 'https://example.com/tool.jpg or assets/tool.png',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Product description',
                  hintText: 'Describe material, size, use and key benefits...',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final name = _nameCtrl.text.trim();
                      final price = double.tryParse(_priceCtrl.text) ?? 0.0;
                      final stock = int.tryParse(_stockCtrl.text) ?? 0;

                      if (name.isEmpty || price < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enter a product name and valid price.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (isEditing) {
                        widget.provider.editProduct(
                          widget.product!.copyWith(
                            name: name,
                            category: _selectedCategory,
                            price: price,
                            stock: stock,
                            icon: _iconCtrl.text.trim().isNotEmpty
                                ? _iconCtrl.text.trim()
                                : '🌱',
                            imageUrl: _imageUrlCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                      } else {
                        widget.provider.addProduct(
                          Product(
                            id: '${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            category: _selectedCategory,
                            price: price,
                            stock: stock,
                            icon: _iconCtrl.text.trim().isNotEmpty
                                ? _iconCtrl.text.trim()
                                : '🌱',
                            imageUrl: _imageUrlCtrl.text.trim(),
                            tag: 'Farm essential',
                            description: _descCtrl.text.trim(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.green,
                          content: Text(
                            isEditing ? 'Product updated' : 'Product added',
                          ),
                        ),
                      );
                    },
                    child: const Text('Save product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
