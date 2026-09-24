// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/widgets/post_tile.dart';

void main() {
  testWidgets('PostTile renders post summary', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostTile(
            post: const Post(
              userId: 1,
              id: 7,
              title: 'A post title',
              body: 'A post body',
            ),
          ),
        ),
      ),
    );

    expect(find.text('A post title'), findsOneWidget);
    expect(find.text('A post body'), findsOneWidget);
  });
}
