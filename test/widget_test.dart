// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:telengana_attendance_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Mock camera list
    final List<CameraDescription> mockCameras = [];

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MyApp(cameras: mockCameras, isFirstLaunch: false, isSetupComplete: true),
    );

    // Verify that the title is displayed
    expect(find.text('TSWREIS'), findsOneWidget);

    // Verify that language toggle is present
    expect(find.byIcon(Icons.language), findsOneWidget);

    // Verify that main action buttons are present
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);
  });
}
