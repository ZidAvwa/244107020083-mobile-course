import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/search_announcements.dart';

final searchAnnouncementsProvider = Provider<SearchAnnouncements>(
  (ref) => const SearchAnnouncements(),
);

final announcementSearchQueryProvider =
    NotifierProvider<AnnouncementSearchQueryNotifier, String>(
      AnnouncementSearchQueryNotifier.new,
    );

class AnnouncementSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}
