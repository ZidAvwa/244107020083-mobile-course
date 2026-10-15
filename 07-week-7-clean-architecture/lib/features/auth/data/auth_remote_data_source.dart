/// Mock remote source, ready to swap for Firebase Auth
/// (FirebaseAuth.instance.signInWithEmailAndPassword / GoogleSignIn).
/// Returns raw maps like a real API would; parsing happens in the model.
class AuthRemoteDataSource {
  Future<Map<String, Object?>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    return {
      'access': 'mock-access-for-$email',
      'refresh': 'mock-refresh-for-$email',
    };
  }

  Future<Map<String, Object?>> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token missing');
    return {
      'access': 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}
