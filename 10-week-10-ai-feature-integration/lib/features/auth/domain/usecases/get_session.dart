import '../repositories/auth_repository.dart';

/// True when a stored session exists (used by the route guard).
class GetSession {
  const GetSession(this._repository);
  final AuthRepository _repository;

  Future<bool> call() => _repository.hasSession();
}
