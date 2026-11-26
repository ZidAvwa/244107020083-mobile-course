import 'dart:async';
import 'dart:typed_data';

import 'package:campus_notify/features/ai_chat/domain/ai_chat_service.dart';
import 'package:campus_notify/features/ai_chat/data/ai_api_key_store.dart';
import 'package:campus_notify/features/ai_chat/data/gemini_ai_chat_service.dart';
import 'package:campus_notify/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:campus_notify/features/ai_chat/presentation/providers/ai_chat_providers.dart';
import 'package:dio/dio.dart';
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

class _FakeKeyStore extends AiApiKeyStore {
  @override
  Future<String?> read() async => 'test-key';
}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      'data: {"candidates":[{"content":{"parts":[{"text":"Try spaced practice '
      'sessions."}]}}]}\n\n',
      200,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('sends the system prompt and current user question to Gemini', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    addTearDown(dio.close);
    final service = GeminiAiChatService(keyStore: _FakeKeyStore(), client: dio);

    final output = await service.ask('How should I study?').join();

    expect(output, 'Try spaced practice sessions.');
    expect(adapter.request?.headers['x-goog-api-key'], 'test-key');
    final data = adapter.request?.data as Map<String, dynamic>;
    final instruction = data['systemInstruction'] as Map<String, dynamic>;
    final instructionParts = instruction['parts'] as List<dynamic>;
    expect(
      (instructionParts.single as Map<String, dynamic>)['text'],
      GeminiAiChatService.systemPrompt,
    );
    final contents = data['contents'] as List<dynamic>;
    final message = contents.single as Map<String, dynamic>;
    final parts = message['parts'] as List<dynamic>;
    expect(
      (parts.single as Map<String, dynamic>)['text'],
      'How should I study?',
    );
  });

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
