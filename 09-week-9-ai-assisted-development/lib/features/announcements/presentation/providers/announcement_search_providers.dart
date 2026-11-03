import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/search_announcements.dart';

final announcementSummariesProvider = Provider<List<AnnouncementSummary>>(
  (ref) => const [
    (id: '1', title: 'Welcome to Campus Notify'),
    (id: '2', title: 'Campus Events This Week'),
    (id: '3', title: 'Library Hours and Study Spaces'),
    (id: '4', title: 'Registration Deadline Reminder'),
    (id: '5', title: 'Scholarship Applications Open'),
    (id: '6', title: 'Campus Wi-Fi Maintenance Notice'),
    (id: '7', title: 'Student Organization Fair'),
    (id: '8', title: 'Exam Schedule Published'),
    (id: '9', title: 'New Cafeteria Menu'),
    (id: '10', title: 'Guest Lecture on Artificial Intelligence'),
  ],
);

final searchAnnouncementsProvider = Provider<SearchAnnouncements>(
  (ref) => const SearchAnnouncements(),
);

final announcementSearchQueryProvider =
    NotifierProvider.autoDispose<AnnouncementSearchQueryNotifier, String>(
      AnnouncementSearchQueryNotifier.new,
    );

class AnnouncementSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}
