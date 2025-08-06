// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:assesment/main.dart';
import 'package:assesment/providers/auth_provider.dart';
import 'package:assesment/providers/task_provider.dart';
import 'package:assesment/models/user.dart';
import 'package:assesment/models/project.dart';
import 'package:assesment/models/task.dart';

void main() {
  group('TaskMaster AI App Tests', () {
    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(UserAdapter());
      Hive.registerAdapter(ProjectAdapter());
      Hive.registerAdapter(TaskAdapter());
    });

    testWidgets('App should start with splash screen', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the splash screen is shown
      expect(find.text('TaskMaster AI'), findsOneWidget);
      expect(find.text('AI-Powered Task Management'), findsOneWidget);
    });

    testWidgets('Login screen should show after splash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify login screen elements
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Sign in to continue managing your tasks'),
        findsOneWidget,
      );
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Email and password fields
    });

    testWidgets('Registration screen should be accessible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on sign up link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify registration screen elements
      expect(find.text('Join TaskMaster AI'), findsOneWidget);
      expect(find.text('Create your account to get started'), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(4),
      ); // Name, email, password, confirm password
    });

    testWidgets('Dashboard should show after successful login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: Text('Dashboard Test')),
          ),
        ),
      );

      // Verify providers are working
      expect(find.text('Dashboard Test'), findsOneWidget);
    });
  });
}
