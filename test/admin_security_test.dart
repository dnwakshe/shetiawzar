import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agrotech/main.dart';
import 'package:agrotech/providers/catalog_provider.dart';
import 'package:agrotech/services/catalog_repository.dart';
import 'package:agrotech/services/enquiry_notification_service.dart';
import 'package:agrotech/services/launcher_helper.dart';

void main() {
  group('Admin Web Security Unit Tests', () {
    late InMemoryCatalogRepository repository;
    late CatalogProvider provider;

    setUp(() {
      LauncherHelper.enableLauncher = false;
      EnquiryNotificationService.enableHttp = false;
      repository = InMemoryCatalogRepository();
      provider = CatalogProvider(repository: repository);
    });

    test('Admin is locked by default and showAdminView does not auto-authenticate', () {
      expect(provider.isAdminAuthenticated, isFalse);
      provider.showAdminView();
      // Crucial security check: showAdminView must NOT automatically grant authentication!
      expect(provider.isAdminAuthenticated, isFalse);
      expect(provider.isAdminView, isTrue);
    });

    test('Incorrect passcode increments failed attempts and triggers lockout', () {
      expect(provider.failedAdminAttempts, 0);

      // 4 wrong attempts
      for (int i = 1; i <= 4; i++) {
        final result = provider.authenticateAdmin('wrong_pass');
        expect(result, isFalse);
        expect(provider.failedAdminAttempts, i);
        expect(provider.isLockedOut, isFalse);
      }

      // 5th wrong attempt triggers 30s lockout
      final fifthResult = provider.authenticateAdmin('wrong_pass');
      expect(fifthResult, isFalse);
      expect(provider.failedAdminAttempts, 5);
      expect(provider.isLockedOut, isTrue);
      expect(provider.lockoutSecondsRemaining, greaterThan(0));

      // During lockout, even correct password is blocked
      expect(provider.authenticateAdmin('wakshe@123'), isFalse);
    });

    test('Valid passcodes grant authentication and reset attempt counters', () {
      expect(provider.authenticateAdmin('wakshe@123'), isTrue);
      expect(provider.isAdminAuthenticated, isTrue);
      expect(provider.failedAdminAttempts, 0);
      expect(provider.isLockedOut, isFalse);

      // Lockout / Logout
      provider.logoutAdmin();
      expect(provider.isAdminAuthenticated, isFalse);

      // Backward compatible admin123
      expect(provider.authenticateAdmin('admin123'), isTrue);
      expect(provider.isAdminAuthenticated, isTrue);
    });

    test('Update admin passcode enforces verification and minimum length', () {
      // Wrong current passcode fails
      expect(
        provider.updateAdminPasscode(
          currentPasscode: 'wrong_old',
          newPasscode: 'newsecret123',
        ),
        isFalse,
      );

      // Too short new passcode fails
      expect(
        provider.updateAdminPasscode(
          currentPasscode: 'wakshe@123',
          newPasscode: '123',
        ),
        isFalse,
      );

      // Valid update
      expect(
        provider.updateAdminPasscode(
          currentPasscode: 'wakshe@123',
          newPasscode: 'newsecret123',
        ),
        isTrue,
      );

      // Authenticate with new passcode
      expect(provider.authenticateAdmin('newsecret123'), isTrue);
    });
  });

  group('Web Admin UI Security Tests', () {
    setUp(() {
      LauncherHelper.enableLauncher = false;
      EnquiryNotificationService.enableHttp = false;
    });

    testWidgets('Desktop Admin button requires authentication challenge',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
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

      // Click Admin on Desktop Topbar
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();

      // Verify Administrator Access modal is displayed
      expect(find.text('Administrator Access'), findsOneWidget);
      expect(find.text('Enter your administrator passcode to manage products, pricing, and stock inventory.'), findsOneWidget);

      // Enter invalid password
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.tap(find.text('Unlock Dashboard'));
      await tester.pumpAndSettle();

      // Verify error message is shown and dashboard is NOT unlocked
      expect(find.textContaining('Invalid passcode'), findsOneWidget);
      expect(find.text('Admin dashboard'), findsNothing);

      // Enter valid password
      await tester.enterText(find.byType(TextField).last, 'wakshe@123');
      await tester.tap(find.text('Unlock Dashboard'));
      await tester.pumpAndSettle();

      // Now dashboard is unlocked
      expect(find.text('Admin dashboard'), findsOneWidget);
      expect(find.text('Product catalogue'), findsOneWidget);
      expect(find.text('Change Passcode'), findsOneWidget);
      expect(find.text('Lock Session'), findsOneWidget);

      // Test Lock Session
      await tester.tap(find.text('Lock Session'));
      await tester.pumpAndSettle();

      // Session is locked and returns to Shop view
      expect(find.text('Admin dashboard'), findsNothing);
      expect(find.text('Explore our products'), findsOneWidget);
    });
  });
}
