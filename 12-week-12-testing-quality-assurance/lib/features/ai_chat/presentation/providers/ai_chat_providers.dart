import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_api_key_store.dart';
import '../../data/gemini_ai_chat_service.dart';
import '../../domain/ai_chat_service.dart';

final aiApiKeyStoreProvider = Provider<AiApiKeyStore>((ref) => AiApiKeyStore());

final aiChatServiceProvider = Provider<AiChatService>(
  (ref) => GeminiAiChatService(keyStore: ref.watch(aiApiKeyStoreProvider)),
);
