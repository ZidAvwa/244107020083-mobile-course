abstract interface class AiChatService {
  Future<String?> readApiKey();

  Future<void> saveApiKey(String key);

  Future<void> clearApiKey();

  Stream<String> ask(String question);
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}
