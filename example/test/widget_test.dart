// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dart_service_provider/dart_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_service_provider/flutter_service_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_service_provider_example/main.dart';

void main() {
  testWidgets('Flutter service test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      Services(
        serviceConfig: (services) => services.addApplicationServices(),
        builder: (context, _) => const MyApp(),
      ),
    );

    expect(find.textContaining('Greetings, Singleton'), findsOneWidget);
    expect(find.textContaining('Greetings, Transient'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Greetings, Scope'), findsOneWidget);
    expect(find.textContaining('Greetings, Transient'), findsOneWidget);
    expect(find.textContaining('Greetings, Consumer'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Greetings, New Route'), findsOneWidget);
  });
  testWidgets('Custom service provider test', (WidgetTester tester) async {
    final services = ServiceCollection();
    services.addApplicationServices();
    final ServiceProvider rootProvider = services.buildServiceProvider();
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      Services.fromServiceProvider(
        provider: rootProvider,
        builder: (context, _) => const MyApp(),
      ),
    );

    expect(find.textContaining('Greetings, Singleton'), findsOneWidget);
    expect(find.textContaining('Greetings, Transient'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Greetings, Scope'), findsOneWidget);
    expect(find.textContaining('Greetings, Transient'), findsOneWidget);
    expect(find.textContaining('Greetings, Consumer'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Greetings, New Route'), findsOneWidget);
  });
}
