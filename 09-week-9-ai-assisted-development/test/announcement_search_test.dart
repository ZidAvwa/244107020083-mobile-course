import 'package:campus_notify/features/announcements/presentation/pages/announcement_page.dart';
import 'package:campus_notify/features/announcements/presentation/pages/home_page.dart';
import 'package:campus_notify/features/announcements/domain/usecases/search_announcements.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcement_search_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _testAnnouncements = <AnnouncementSummary>[
  (id: '1', title: 'Welcome to Campus Notify'),
  (id: '2', title: 'Campus Events'),
  (id: '3', title: 'Library Hours'),
];

GoRouter _createRouter() => GoRouter(
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

Widget _appWithAnnouncements(GoRouter router) => ProviderScope(
  overrides: [
    announcementSummariesProvider.overrideWithValue(_testAnnouncements),
  ],
  child: MaterialApp.router(routerConfig: router),
);

void main() {
  test('search matches case and whitespace normalized titles', () {
    const announcements = <AnnouncementSummary>[
      (id: '1', title: 'Welcome to Campus Notify'),
      (id: '2', title: 'Campus Events'),
    ];

    final results = const SearchAnnouncements()(
      announcements: announcements,
      query: '  cAMPUS    NOTIFY ',
    );

    expect(results.map((announcement) => announcement.id), ['1']);
    expect(
      const SearchAnnouncements()(
        announcements: announcements,
        query: 'no matching announcement',
      ),
      isEmpty,
    );
    expect(
      const SearchAnnouncements()(announcements: announcements, query: '   '),
      announcements,
    );
  });

  testWidgets(
    'search filters multiple announcements and clearing restores list',
    (tester) async {
      final router = _createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(_appWithAnnouncements(router));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(find.text('Welcome to Campus Notify'), findsOneWidget);
      expect(find.text('Campus Events'), findsOneWidget);
      expect(find.text('Library Hours'), findsOneWidget);

      await tester.enterText(searchField, '  cAMPUS ');
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Campus Notify'), findsOneWidget);
      expect(find.text('Campus Events'), findsOneWidget);
      expect(find.text('Library Hours'), findsNothing);

      await tester.enterText(searchField, '  cAMPUS    NOTIFY ');
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Campus Notify'), findsOneWidget);
      expect(find.text('Campus Events'), findsNothing);

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
      expect(find.text('Campus Events'), findsOneWidget);
      expect(find.text('Library Hours'), findsOneWidget);

      await tester.tap(find.text('Welcome to Campus Notify'));
      await tester.pumpAndSettle();
      expect(find.text('Details for announcement 1'), findsOneWidget);
    },
  );

  testWidgets('reopening announcements clears a stale search query', (
    tester,
  ) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_appWithAnnouncements(router));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Campus');
    await tester.pumpAndSettle();
    expect(find.text('Library Hours'), findsNothing);

    router.go('/announcement/1');
    await tester.pumpAndSettle();
    expect(find.text('Details for announcement 1'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(find.text('Welcome to Campus Notify'), findsOneWidget);
    expect(find.text('Campus Events'), findsOneWidget);
    expect(find.text('Library Hours'), findsOneWidget);
  });
}
