import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agrotech/main.dart';
import 'package:agrotech/models/product.dart';
import 'package:agrotech/providers/catalog_provider.dart';
import 'package:agrotech/services/catalog_repository.dart';

Widget _buildTestApp(CatalogRepository repository) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => CatalogProvider(repository: repository),
      ),
    ],
    child: const WaksheAgrotechApp(),
  );
}

void main() {
  group('Mobile Viewport Tests (360x800, 390x844, 430x932)', () {
    testWidgets('Mobile 360x800 header, drawer, bottom navigation, and no overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = InMemoryCatalogRepository();
      await tester.pumpWidget(_buildTestApp(repository));
      await tester.pumpAndSettle();

      // 1. Verify Compact Mobile Header
      expect(find.text('WAKSHE AGROTECH'), findsAtLeastNWidgets(1));
      expect(find.text('TOOLS FOR EVERY FIELD'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Verify desktop Shop and Admin buttons are NOT in the mobile header
      // (The only 'Shop' and 'Account' text on screen at this stage are in the bottom NavigationBar)
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Admin'), findsNothing);

      // 2. Verify Material 3 Bottom Navigation Bar
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      // 3. Verify Hero Banner & Agricultural Artwork (Image used instead of axe emoji placeholder)
      expect(find.text('BUILT FOR THE HANDS THAT GROW'), findsOneWidget);
      expect(find.text('Strong tools.\nStronger harvests.'), findsOneWidget);
      expect(find.text('Explore products →'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // 4. Verify Feature Highlights (vertical stack on mobile)
      expect(find.text('Hand-forged quality'), findsOneWidget);
      expect(find.text('Delivery across India'), findsOneWidget);
      expect(find.text('Farmer-first support'), findsOneWidget);

      // 5. Verify 2-Column Product Grid on Mobile
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);

      // 6. Test Product Details Sheet on Tap
      final firstProductCard = find.text('Hand-forged Koyta');
      expect(firstProductCard, findsOneWidget);
      await tester.ensureVisible(firstProductCard);
      await tester.tap(firstProductCard);
      await tester.pumpAndSettle();

      // Should show product details sheet
      expect(find.text('TOOL SPECIFICATIONS'), findsOneWidget);
      expect(find.text('Hand-forged high-carbon steel'), findsOneWidget);
      expect(find.text('Enquire'), findsOneWidget);

      // Close details sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 7. Test Add-to-cart on Mobile
      final addButtons = find.text('Add +');
      expect(addButtons, findsWidgets);
      await tester.ensureVisible(addButtons.first);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Cart count badge should display 1
      expect(find.text('1'), findsAtLeastNWidgets(1));

      // 8. Test Opening Mobile Drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Drawer items
      expect(find.text('Shop Catalogue'), findsOneWidget);
      expect(find.text('Shopping Cart'), findsOneWidget);
      expect(find.text('Account & Enquiries'), findsOneWidget);
      expect(find.text('ADMINISTRATION'), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('Restricted to administrators'), findsOneWidget);

      // 9. Test Admin Passcode Authentication Dialog
      await tester.tap(find.text('Admin Dashboard'));
      await tester.pumpAndSettle();

      expect(find.text('Administrator Access'), findsOneWidget);
      expect(find.text('Enter your administrator passcode to manage products, pricing, and stock inventory.'), findsOneWidget);

      // Enter wrong passcode
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.tap(find.text('Unlock Dashboard'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Invalid passcode'), findsOneWidget);

      // Enter correct passcode
      await tester.enterText(find.byType(TextField).last, 'admin123');
      await tester.tap(find.text('Unlock Dashboard'));
      await tester.pumpAndSettle();

      // Should now be on Admin Dashboard with responsive mobile cards!
      expect(find.text('Admin dashboard'), findsOneWidget);
      expect(find.text('Product catalogue'), findsOneWidget);
      expect(find.text('Add product'), findsOneWidget);

      // 10. Test Switching to Account Tab via Bottom Navigation Bar
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(find.text('User Profile & Account'), findsOneWidget);
      expect(find.text('Farmer Partner'), findsOneWidget);
      expect(find.text('Open Shopping Cart'), findsOneWidget);

      // 11. Switch back to Shop tab
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();
      expect(find.text('Explore our products'), findsOneWidget);
    });

    testWidgets('Mobile 390x844 layout verification without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = InMemoryCatalogRepository();
      await tester.pumpWidget(_buildTestApp(repository));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('WAKSHE AGROTECH'), findsAtLeastNWidgets(1));
      expect(find.text('Hand-forged Koyta'), findsOneWidget);
    });

    testWidgets('Mobile 430x932 layout verification without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = InMemoryCatalogRepository();
      await tester.pumpWidget(_buildTestApp(repository));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('WAKSHE AGROTECH'), findsAtLeastNWidgets(1));
      expect(find.text('Heavy-duty Axe'), findsOneWidget);
    });
  });

  group('Tablet Viewport Tests (768x1024)', () {
    testWidgets('Tablet 768x1024 maintains desktop navigation and 3 columns',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = InMemoryCatalogRepository();
      await tester.pumpWidget(_buildTestApp(repository));
      await tester.pumpAndSettle();

      // Tablet shows topbar Shop and Admin buttons
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.textContaining('Cart'), findsOneWidget);

      // Bottom navigation is NOT present on tablet
      expect(find.byType(NavigationBar), findsNothing);

      // 3-column product grid on tablet
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
    });
  });

  group('Desktop Viewport Tests (1024x768, 1366x768, 1440x900)', () {
    testWidgets('Desktop 1024x768 maintains desktop navigation and 4 columns',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = InMemoryCatalogRepository();
      await tester.pumpWidget(_buildTestApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // 4-column product grid on desktop
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);

      // Test switching to Admin View on desktop
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();

      expect(find.text('Admin dashboard'), findsOneWidget);
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('Desktop 1366x768 and 1440x900 layout verification',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = InMemoryCatalogRepository();
      await tester.pumpWidget(_buildTestApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('WAKSHE AGROTECH'), findsAtLeastNWidgets(1));
      expect(find.text('BUILT FOR THE HANDS THAT GROW'), findsOneWidget);
    });
  });
}
