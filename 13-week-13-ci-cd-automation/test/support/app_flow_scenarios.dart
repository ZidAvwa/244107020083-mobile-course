import 'package:campus_notify/app/providers.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/presentation/pages/announcement_page.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/main.dart' show CampusNotifyApp;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  bool _loggedIn = false;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@') || password.isEmpty) {
      return (
        session: null,
        failure: const AuthFailure('Invalid email or password'),
      );
    }

    _loggedIn = true;
    return (
      session: const AuthSession(
        access: 'test-access',
        refresh: 'test-refresh',
      ),
      failure: null,
    );
  }

  @override
  Future<({String? access, Failure? failure})> refreshAccessToken() async =>
      (access: 'test-access', failure: null);

  @override
  Future<String?> readAccessToken() async => _loggedIn ? 'test-access' : null;

  @override
  Future<bool> hasSession() async => _loggedIn;

  @override
  Future<Failure?> logout() async {
    _loggedIn = false;
    return null;
  }
}

void defineAppFlowTests() {
  testWidgets('login, search announcements, and open details', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: CampusNotifyApp(container: container, firebaseReady: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'student@example.edu');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Announcements'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'scholarship');
    await tester.pumpAndSettle();
    expect(find.text('Scholarship Applications Open'), findsOneWidget);
    expect(find.text('Welcome to Campus Notify'), findsNothing);

    await tester.tap(find.text('Scholarship Applications Open'));
    await tester.pumpAndSettle();
    expect(find.text('Details for announcement 5'), findsOneWidget);
    expect(find.byType(AnnouncementPage), findsOneWidget);
  });
}
