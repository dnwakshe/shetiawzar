import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrotech/providers/catalog_provider.dart';
import 'package:agrotech/services/catalog_repository.dart';
import 'package:agrotech/services/enquiry_notification_service.dart';
import 'package:agrotech/services/launcher_helper.dart';
import 'package:agrotech/widgets/enquiry_dialog.dart';

void main() {
  group('Customer Enquiry Flow Tests', () {
    late InMemoryCatalogRepository repository;
    late CatalogProvider provider;

    setUp(() {
      LauncherHelper.enableLauncher = false;
      EnquiryNotificationService.enableHttp = false;
      repository = InMemoryCatalogRepository();
      provider = CatalogProvider(repository: repository);
    });

    tearDown(() {
      LauncherHelper.enableLauncher = true;
      EnquiryNotificationService.enableHttp = true;
    });

    testWidgets('Enquiry dialog validation and successful placement',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  // Add an item to cart first
                  provider.addToCart(provider.products.first);
                  EnquiryDialog.show(context, provider: provider);
                },
                child: const Text('Open Enquiry'),
              ),
            ),
          ),
        ),
      );

      // Tap open
      await tester.tap(find.text('Open Enquiry'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('चौकशी नोंदवा (Place Enquiry)'), findsOneWidget);
      expect(find.text('तुमचे पूर्ण नाव (Full Name) *'), findsOneWidget);
      expect(find.text('मोबाईल नंबर (Phone Number) *'), findsOneWidget);

      // Attempt to submit empty form -> should trigger validation
      await tester.tap(find.text('चौकशी पाठवा (Submit)'));
      await tester.pumpAndSettle();

      expect(find.text('कृपया तुमचे नाव लिहा (Please enter name)'), findsOneWidget);

      // Enter valid Name and Phone
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3));

      // Enter Name
      await tester.enterText(textFields.at(0), 'रमेश पाटील');
      // Enter Phone
      await tester.enterText(textFields.at(1), '9876543210');
      // Enter Village Note
      await tester.enterText(textFields.at(2), 'वाक्षेवाडी, सांगली');
      await tester.pumpAndSettle();

      // Submit Enquiry
      await tester.tap(find.text('चौकशी पाठवा (Submit)'));
      await tester.pumpAndSettle();

      // Verify enquiry was recorded in provider
      expect(provider.enquiries.length, 1);
      expect(provider.enquiries.first.customerName, 'रमेश पाटील');
      expect(provider.enquiries.first.customerPhone, '9876543210');

      // Verify success dialog is displayed
      expect(find.text('Your enquiry placed successfully!'), findsOneWidget);
      expect(find.text('चौकशी यशस्वीपणे नोंदवली गेली आहे.'), findsOneWidget);
      expect(find.textContaining('रमेश पाटील'), findsWidgets);
      expect(find.textContaining('9876543210'), findsWidgets);

      // Close success dialog
      await tester.tap(find.text('ठीक आहे (Done)'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Your enquiry placed successfully!'), findsNothing);
    });

    testWidgets('Single product enquiry placement from details flow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  final p = provider.products.first;
                  EnquiryDialog.show(
                    context,
                    provider: provider,
                    singleProduct: p,
                  );
                },
                child: const Text('Enquire Single'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Enquire Single'));
      await tester.pumpAndSettle();

      expect(find.text('चौकशी नोंदवा (Place Enquiry)'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'आनंद कदम');
      await tester.enterText(textFields.at(1), '8888777766');
      await tester.pumpAndSettle();

      await tester.tap(find.text('चौकशी पाठवा (Submit)'));
      await tester.pumpAndSettle();

      expect(find.text('Your enquiry placed successfully!'), findsOneWidget);
      expect(provider.enquiries.length, 1);
      expect(provider.enquiries.first.customerName, 'आनंद कदम');
      expect(provider.enquiries.first.customerPhone, '8888777766');
    });
  });
}
