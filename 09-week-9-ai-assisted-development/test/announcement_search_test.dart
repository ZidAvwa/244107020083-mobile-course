import 'package:campus_notify/features/announcements/presentation/pages/announcement_page.dart';
import 'package:campus_notify/features/announcements/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('search filters announcements and clearing restores navigation', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        GoRoute(
          path: '/announcement/:id',
          builder: (_, state) =>
              AnnouncementPage(id: state.pathParameters['id'] ?? ''),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    expect(find.text('Welcome to Campus Notify'), findsOneWidget);

    await tester.enterText(searchField, '  cAMPUS    NOTIFY ');
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Campus Notify'), findsOneWidget);

    await tester.enterText(searchField, 'no matching announcement');
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Campus Notify'), findsNothing);
    expect(
      find.text('No announcements found. Try a different search.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Campus Notify'), findsOneWidget);

    await tester.tap(find.text('Welcome to Campus Notify'));
    await tester.pumpAndSettle();
    expect(find.text('Details for announcement 1'), findsOneWidget);
  });
}
