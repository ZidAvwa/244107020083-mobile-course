typedef AnnouncementSummary = ({String id, String title});

final _whitespacePattern = RegExp(r'\s+');

class SearchAnnouncements {
  const SearchAnnouncements();

  List<AnnouncementSummary> call({
    required List<AnnouncementSummary> announcements,
    required String query,
  }) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return announcements;

    return announcements
        .where(
          (announcement) =>
              _normalize(announcement.title).contains(normalizedQuery),
        )
        .toList(growable: false);
  }
}

String _normalize(String value) =>
    value.trim().replaceAll(_whitespacePattern, ' ').toLowerCase();
