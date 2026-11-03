# Flutter Week 9 - AI-Assisted Development

This project uses the existing Week 7 `campus_notify` app for the Week 9
AI-assisted development labs. The work adapts the lab's notes-search example to
the announcements feature already in this app; it does not start a new project
or add a notes feature.

## Lab 1 - Prompt and context engineering

The lab example describes notes search, but this project has an announcements
screen and no notes feature. The prompt was adapted to the app that actually
exists: search announcement titles, keep detail navigation working, and avoid
adding a database, dependencies, or unrelated architecture.

Save the exact prompt and AI response in `docs/ai-log.md`, as required by the
lab.

![Lab 1 Prompt](./screenshots/Lab1_Prompt.png)
![Lab 1 AI response](./screenshots/Lab1_Result.png)

## Lab 2 - Generate and verify search

Added title search to
`lib/features/announcements/presentation/pages/home_page.dart`.

- Search is case-insensitive and ignores leading, trailing, and repeated
  whitespace.
- A clear action restores the full list.
- A no-results message appears when nothing matches.
- Tapping a result still opens its announcement detail route.
- The list currently contains one hardcoded announcement, so search filters
  that existing entry; no repository or backend was added.

`test/announcement_search_test.dart` checks matching with mixed case and extra
spaces, the no-results state, clearing the query, and detail navigation.

Validation run from this project directory:

```powershell
flutter test test/announcement_search_test.dart
flutter analyze
```

![Lab 2 search with a matching announcement](./screenshots/Lab2_Search_Match.png)
![Lab 2 search with no matching announcements](./screenshots/Lab2_Search_NoResults.png)