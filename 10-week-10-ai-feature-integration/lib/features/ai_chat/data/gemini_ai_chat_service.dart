import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/ai_chat_service.dart';
import 'ai_api_key_store.dart';

class GeminiAiChatService implements AiChatService {
  GeminiAiChatService({required this.keyStore, Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 45),
            ),
          );

  static final _endpoint = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/'
    'models/gemini-3.6-flash:streamGenerateContent',
  );

  final AiApiKeyStore keyStore;
  final Dio _client;

  @override
  Future<String?> readApiKey() => keyStore.read();

  @override
  Future<void> saveApiKey(String key) async {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      throw const AiChatException('Enter a Gemini API key to save it.');
    }
    await keyStore.save(trimmedKey);
  }

  @override
  Future<void> clearApiKey() => keyStore.clear();

  @override
  Stream<String> ask(String question) async* {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      throw const AiChatException('Enter a question first.');
    }

    final apiKey = await keyStore.read();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiChatException(
        'Add your Gemini API key in AI settings to start chatting.',
      );
    }

    try {
      final response = await _client.post<ResponseBody>(
        _endpoint.toString(),
        queryParameters: {'alt': 'sse'},
        data: {
          'contents': [
            {
              'parts': [
                {'text': trimmedQuestion},
              ],
            },
          ],
        },
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'x-goog-api-key': apiKey},
          responseType: ResponseType.stream,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final statusCode = response.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw const AiChatException(
          'Gemini rejected the API key. Check it in AI settings.',
        );
      }
      if (statusCode == 429) {
        throw const AiChatException(
          'The Gemini API quota was reached. Try again later.',
        );
      }
      if (statusCode == null || statusCode < 200 || statusCode >= 300) {
        throw AiChatException(
          'The Gemini request failed (${statusCode ?? 'unknown status'}).',
        );
      }

      final body = response.data;
      if (body == null) {
        throw const AiChatException('Gemini returned an empty response.');
      }

      var receivedText = false;
      await for (final line
          in body.stream
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final eventData = line.substring(5).trim();
        if (eventData.isEmpty || eventData == '[DONE]') continue;
        final text = _responseText(eventData);
        if (text == null || text.isEmpty) continue;
        receivedText = true;
        yield text;
      }
      if (!receivedText) {
        throw const AiChatException(
          'Gemini returned an empty response. Try a different question.',
        );
      }
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const AiChatException(
          'Could not reach Gemini. Check your internet connection and try again.',
        );
      }
      throw const AiChatException(
        'The Gemini request could not be completed. Please try again.',
      );
    }
  }

  String? _responseText(String json) {
    dynamic data;
    try {
      data = jsonDecode(json);
    } on FormatException {
      throw const AiChatException('Gemini returned an unreadable response.');
    }
    if (data is! Map<String, dynamic>) return null;
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final candidate = candidates.first;
    if (candidate is! Map<String, dynamic>) return null;
    final content = candidate['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List) return null;

    final textParts = <String>[];
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        textParts.add(part['text'] as String);
      }
    }
    return textParts.isEmpty ? null : textParts.join();
  }
}
