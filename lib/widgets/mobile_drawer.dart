import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';
import 'admin_login_dialog.dart';

/// Responsive side drawer for mobile application navigation,
/// providing customer browsing tabs, cart access, and secure
/// administrator portal authentication.
class MobileDrawer extends StatelessWidget {
  final CatalogProvider provider;
  final VoidCallback onOpenCart;

  const MobileDrawer({
    super.key,
    required this.provider,
    required this.onOpenCart,
  });

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/app_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'About Wakshe Agrotech',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'वाक्षे ॲग्रोटेक (Wakshe Agrotech)',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.green),
            ),
            SizedBox(height: 8),
            Text(
              'Crafting heavy-duty, hand-forged agricultural tools with high-carbon steel for farmers across India.\n\nEvery tool is shaped, tempered and sharpened by seasoned artisans in Maharashtra for maximum durability in field conditions.',
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
            ),
            SizedBox(height: 14),
            Text(
              '📍 Maharashtra, India · All-India Delivery',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Official Logo & Branding
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: const BoxDecoration(
                color: AppColors.green,
                gradient: LinearGradient(
                  colors: [AppColors.green, AppColors.green2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🌾', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'WAKSHE AGROTECH',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'TOOLS FOR EVERY FIELD · वाक्षे ॲग्रोटेक',
                    style: TextStyle(
                      color: Color(0xFFC7D8C9),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Shop Catalogue
                  ListTile(
                    leading: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'Shop Catalogue',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Browse handcrafted farm tools',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    selected: provider.isShopView,
                    selectedTileColor: AppColors.lime.withValues(alpha: 0.35),
                    onTap: () {
                      Navigator.of(context).pop();
                      provider.showShopView();
                    },
                  ),

                  // Shopping Cart
                  ListTile(
                    leading: Badge.count(
                      count: provider.cartCount,
                      isLabelVisible: provider.cartCount > 0,
                      backgroundColor: AppColors.green,
                      textColor: Colors.white,
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.green,
                      ),
                    ),
                    title: const Text(
                      'Shopping Cart',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      provider.formattedCartTotal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenCart();
                    },
                  ),

                  // Account & Enquiries
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'Account & Enquiries',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Orders & customer profile',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    selected: provider.isAccountView,
                    selectedTileColor: AppColors.lime.withValues(alpha: 0.35),
                    onTap: () {
                      Navigator.of(context).pop();
                      provider.showAccountView();
                    },
                  ),

                  const Divider(height: 24),

                  // Administration Section Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'ADMINISTRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Admin Dashboard (Protected by authentication)
                  ListTile(
                    leading: Icon(
                      provider.isAdminAuthenticated
                          ? Icons.admin_panel_settings
                          : Icons.lock_outline,
                      color: provider.isAdminAuthenticated
                          ? AppColors.green
                          : AppColors.muted,
                    ),
                    title: const Text(
                      'Admin Dashboard',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      provider.isAdminAuthenticated
                          ? 'Manage catalog & stock'
                          : 'Restricted to administrators',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    trailing: provider.isAdminAuthenticated
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inStockBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Unlocked',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.inStockText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const Icon(Icons.lock, size: 16, color: AppColors.muted),
                    selected: provider.isAdminView,
                    selectedTileColor: AppColors.lime.withValues(alpha: 0.35),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (provider.isAdminAuthenticated) {
                        provider.showAdminView();
                      } else {
                        AdminLoginDialog.show(context, provider);
                      }
                    },
                  ),

                  // If authorized, offer Lock Admin session
                  if (provider.isAdminAuthenticated)
                    ListTile(
                      leading: const Icon(
                        Icons.lock,
                        color: AppColors.outOfStockText,
                        size: 20,
                      ),
                      title: const Text(
                        'Lock Admin Session',
                        style: TextStyle(
                          color: AppColors.outOfStockText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        provider.logoutAdmin();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Administrator session locked.'),
                          ),
                        );
                      },
                    ),

                  const Divider(height: 24),

                  // Help & Support Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'HELP & SUPPORT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.chat_outlined,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'WhatsApp Assistance',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Chat with tool specialists',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      final msg = provider.cart.isNotEmpty
                          ? provider.generateEnquiryMessage()
                          : 'Hello Wakshe Agrotech, I have an enquiry about agricultural tools.';
                      Clipboard.setData(ClipboardData(text: msg));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.green,
                          content: Text(
                            'WhatsApp enquiry message copied to clipboard!',
                          ),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'About Wakshe Agrotech',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Handcrafted tool legacy since 2020',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Footer at bottom of drawer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Wakshe Agrotech v1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '🌾 Handcrafted',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
