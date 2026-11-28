import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agrotech/main.dart';
import 'package:agrotech/providers/catalog_provider.dart';
import 'package:agrotech/services/catalog_repository.dart';
import 'package:agrotech/services/launcher_helper.dart';

Widget _buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => CatalogProvider(repository: InMemoryCatalogRepository()),
      ),
    ],
    child: const WaksheAgrotechApp(),
  );
}

void main() {
  group('Hero Contact Row & Mobile Number Formatting Tests', () {
    final launchedUris = <Uri>[];

    setUp(() {
      launchedUris.clear();
      LauncherHelper.enableLauncher = false;
      LauncherHelper.onLaunchAttempt = launchedUris.add;
    });

    tearDown(() {
      LauncherHelper.enableLauncher = true;
      LauncherHelper.onLaunchAttempt = null;
    });

    test('Phone display has +91 prefix and no spaces', () {
      expect(LauncherHelper.phoneDisplay, '+918788341895');
      expect(LauncherHelper.phoneDisplay.contains(' '), isFalse);
      expect(LauncherHelper.phone, '+918788341895');
    });

    testWidgets(
      'Desktop displays address, map & location, email and +91 call in hero row with click actions',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        final callFinder = find.text('Call: +918788341895');
        final emailFinder = find.text(LauncherHelper.email);
        final mapFinder = find.text('Map & Location ↗');
        final addressFinder = find.text(LauncherHelper.fullAddress);

        expect(callFinder, findsOneWidget);
        expect(emailFinder, findsAtLeastNWidgets(1));
        expect(mapFinder, findsOneWidget);
        expect(addressFinder, findsAtLeastNWidgets(1));

        // Verify the header starts cleanly at y=0 (no extra bar above TopBar)
        expect(tester.getTopLeft(find.text('WAKSHE AGROTECH')).dy, lessThan(40));

        // Click-to-call in hero row
        await tester.tap(callFinder);
        await tester.pumpAndSettle();
        expect(launchedUris.last.toString(), 'tel:+918788341895');

        // Click-to-mail in hero row
        await tester.tap(emailFinder.first);
        await tester.pumpAndSettle();
        expect(launchedUris.last.scheme, 'mailto');
        expect(launchedUris.last.path, LauncherHelper.email);

        // Click Map & Location in hero row
        await tester.tap(mapFinder);
        await tester.pumpAndSettle();
        expect(launchedUris.last.toString(), LauncherHelper.mapsUrl);

        // Click Address in hero row
        await tester.tap(addressFinder.first);
        await tester.pumpAndSettle();
        expect(launchedUris.last.toString(), LauncherHelper.mapsUrl);
      },
    );

    testWidgets(
      'Mobile 360x800 displays hero contact row items without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        final callFinder = find.text('Call: +918788341895');
        final emailFinder = find.text(LauncherHelper.email);
        final mapFinder = find.text('Map & Location ↗');
        final addressFinder = find.text(LauncherHelper.fullAddress);

        expect(callFinder, findsOneWidget);
        expect(emailFinder, findsAtLeastNWidgets(1));
        expect(mapFinder, findsOneWidget);
        expect(addressFinder, findsAtLeastNWidgets(1));

        await tester.ensureVisible(callFinder);
        await tester.tap(callFinder);
        await tester.pumpAndSettle();
        expect(launchedUris.last.toString(), 'tel:+918788341895');

        await tester.ensureVisible(emailFinder.first);
        await tester.tap(emailFinder.first);
        await tester.pumpAndSettle();
        expect(launchedUris.last.scheme, 'mailto');

        await tester.ensureVisible(mapFinder);
        await tester.tap(mapFinder);
        await tester.pumpAndSettle();
        expect(launchedUris.last.toString(), LauncherHelper.mapsUrl);
      },
    );
  });
}
