import 'package:flutter/material.dart';

import '../providers/catalog_provider.dart';
import '../services/launcher_helper.dart';
import '../theme/app_theme.dart';
import 'admin_login_dialog.dart';
import 'enquiry_dialog.dart';

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
            const Expanded(
              child: Text(
                'वाक्षे ॲग्रोटेक',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'प्रो. प्रा. सौ. माया मोहन वाक्षे',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.green,
                ),
              ),
              const Text(
                'शेती अवजार व्यापारी',
                style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.featureBg,
                  borderRadius: BorderRadius.circular(8),
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
                        fontWeight: FontWeight.w600,
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
              const SizedBox(height: 12),
              const Text(
                'वाक्षे ॲग्रोटेक — शिवकालीन परंपरेतील राजस्थानी लोहारांनी घडवलेली पारंपरिक व टिकाऊ शेती अवजारे. प्रत्येक अवजार उच्च दर्जाच्या लोखंड/स्टीलपासून बनवलेले असून दीर्घकाळ धार टिकवून ठेवते.',
                style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text(
                '📍 संपर्क व कारखाना पत्ता:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.green),
              ),
              const SizedBox(height: 4),
              const Text(
                LauncherHelper.fullAddress,
                style: TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.3),
              ),
              const SizedBox(height: 8),
              const Text(
                '📞 मोबाईल: ${LauncherHelper.phoneDisplay}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              const Text(
                '📧 ईमेल: ${LauncherHelper.email}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call'),
            onPressed: () {
              Navigator.of(ctx).pop();
              LauncherHelper.callSupport();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.map, size: 16),
            label: const Text('Map'),
            onPressed: () {
              Navigator.of(ctx).pop();
              LauncherHelper.openMap();
            },
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  const SizedBox(height: 10),
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
                    'वाक्षे ॲग्रोटेक · शेती अवजारे',
                    style: TextStyle(
                      color: Color(0xFFC7D8C9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Proprietor Credit Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: const Text(
                      'प्रो. प्रा. सौ. माया मोहन वाक्षे',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
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

                  // Direct Calling Support (Owner / Support)
                  ListTile(
                    leading: const Icon(
                      Icons.phone_in_talk,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'Call Support (थेट संपर्क)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      '${LauncherHelper.phoneDisplay} · प्रो. माया वाक्षे',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
                    onTap: () {
                      Navigator.of(context).pop();
                      LauncherHelper.callSupport();
                    },
                  ),

                  // WhatsApp Support
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
                      'Chat with tool specialists (1-click)',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
                    onTap: () {
                      Navigator.of(context).pop();
                      EnquiryDialog.show(context, provider: provider);
                    },
                  ),

                  // Email Support
                  ListTile(
                    leading: const Icon(
                      Icons.email_outlined,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'Email Support (ईमेल संपर्क)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      LauncherHelper.email,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 14, color: AppColors.muted),
                    onTap: () {
                      Navigator.of(context).pop();
                      LauncherHelper.openEmail();
                    },
                  ),

                  // Google Maps Location
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.green,
                    ),
                    title: const Text(
                      'Store & Factory Location',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'वाक्षेवाडी, आटपाडी, सांगली (Google Maps)',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 14, color: AppColors.muted),
                    onTap: () {
                      Navigator.of(context).pop();
                      LauncherHelper.openMap();
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
                      'शिवकालीन परंपरा व लोहारांची कारागिरी',
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
