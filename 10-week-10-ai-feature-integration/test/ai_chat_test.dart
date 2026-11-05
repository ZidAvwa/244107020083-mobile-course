import 'dart:async';

import 'package:campus_notify/features/ai_chat/domain/ai_chat_service.dart';
import 'package:campus_notify/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:campus_notify/features/ai_chat/presentation/providers/ai_chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiChatService implements AiChatService {
  final controller = StreamController<String>();
  String? savedKey;
  String? askedQuestion;

  @override
  Stream<String> ask(String question) {
    askedQuestion = question;
    return controller.stream;
  }

  @override
  Future<void> clearApiKey() async {
    savedKey = null;
  }

  @override
  Future<String?> readApiKey() async => savedKey;

  @override
  Future<void> saveApiKey(String key) async {
    savedKey = key.trim();
  }
}

void main() {
  testWidgets('sends a question, shows loading, and renders the answer', (
    tester,
  ) async {
    final service = _FakeAiChatService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiChatServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: AiChatPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), '  How do I study?  ');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();

    expect(service.askedQuestion, 'How do I study?');
    expect(find.text('How do I study?'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    service.controller
      ..add('Make a study plan')
      ..add(' and take breaks.')
      ..close();
    await tester.pumpAndSettle();
    expect(find.text('Make a study plan and take breaks.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('saves an API key from AI settings', (tester) async {
    final service = _FakeAiChatService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiChatServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: AiChatPage()),
      ),
    );

    await tester.tap(find.byTooltip('AI settings'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '  test-api-key  ',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(service.savedKey, 'test-api-key');
    expect(find.text('API key saved.'), findsOneWidget);
  });
}
