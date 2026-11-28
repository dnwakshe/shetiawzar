import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agrotech/main.dart';
import 'package:agrotech/providers/catalog_provider.dart';
import 'package:agrotech/services/catalog_repository.dart';

void main() {
  testWidgets('Wakshe Agrotech store smoke test matching HTML design',
      (WidgetTester tester) async {
    // Provide an adequately large surface size for responsive testing
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repository = InMemoryCatalogRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CatalogProvider(repository: repository),
          ),
        ],
        child: const WaksheAgrotechApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Topbar and footer brand
    expect(find.text('WAKSHE AGROTECH'), findsAtLeastNWidgets(1));
    expect(find.text('TOOLS FOR EVERY FIELD'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.textContaining('Cart'), findsOneWidget);

    // 2. Verify Hero section
    expect(find.text('BUILT FOR THE HANDS THAT GROW'), findsOneWidget);
    expect(find.text('Strong tools.\nStronger harvests.'), findsOneWidget);
    expect(find.text('Explore products →'), findsOneWidget);

    // 3. Verify feature highlights
    expect(find.text('Hand-forged quality'), findsOneWidget);
    expect(find.text('Delivery across India'), findsOneWidget);
    expect(find.text('Farmer-first support'), findsOneWidget);

    // 4. Verify catalog section & category filter pills
    expect(find.text('Explore our products'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Cutting'), findsOneWidget);
    expect(find.text('Digging'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // 5. Verify starter products are rendered
    expect(find.text('Hand-forged Koyta'), findsOneWidget);
    expect(find.text('Heavy-duty Axe'), findsOneWidget);
    expect(find.text('Agricultural Spade'), findsOneWidget);
    expect(find.text('Garden Khurpi'), findsOneWidget);

    // 6. Test adding a product to cart
    final addToCartButtons = find.text('Add to cart +');
    expect(addToCartButtons, findsWidgets);
    await tester.ensureVisible(addToCartButtons.first);
    await tester.tap(addToCartButtons.first);
    await tester.pumpAndSettle();

    // Cart counter in topbar should now show '1'
    expect(find.text('1'), findsOneWidget);

    // 7. Test switching to Admin View with security verification
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Web admin access is secured; authenticate with valid passcode
    if (find.text('Administrator Access').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).last, 'wakshe@123');
      await tester.tap(find.text('Unlock Dashboard'));
      await tester.pumpAndSettle();
    } else if (find.text('प्रशासक सुरक्षित प्रवेश').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).last, 'wakshe@123');
      await tester.tap(find.text('Unlock Dashboard'));
      await tester.pumpAndSettle();
    }

    // Should display Admin dashboard
    expect(find.text('Admin dashboard'), findsOneWidget);
    expect(find.text('Product catalogue'), findsOneWidget);
    expect(find.text('＋ Add product'), findsOneWidget);
  });

  testWidgets('Hero backdrop switcher cycles background images cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) =>
                CatalogProvider(repository: InMemoryCatalogRepository()),
          ),
        ],
        child: const WaksheAgrotechApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('🌾 Fields'), findsOneWidget);
    expect(find.text('⚒️ Forge'), findsOneWidget);
    expect(find.text('🌿 Brand'), findsOneWidget);

    bool hasHeroAsset(String path) => tester
        .widgetList<Image>(find.byType(Image))
        .any((img) => img.image is AssetImage && (img.image as AssetImage).assetName == path);

    expect(hasHeroAsset('assets/backgrounds/hero_golden_fields.jpg'), isTrue);

    await tester.tap(find.text('⚒️ Forge'));
    await tester.pumpAndSettle();
    expect(hasHeroAsset('assets/backgrounds/hero_heritage_forge.jpg'), isTrue);

    await tester.tap(find.text('🌿 Brand'));
    await tester.pumpAndSettle();
    expect(hasHeroAsset('assets/backgrounds/hero_modern_agri.jpg'), isTrue);
  });
}
