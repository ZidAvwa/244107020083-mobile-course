import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiApiKeyStore {
  AiApiKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'gemini_api_key';
  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _key);

  Future<void> save(String key) => _storage.write(key: _key, value: key);

  Future<void> clear() => _storage.delete(key: _key);
}
