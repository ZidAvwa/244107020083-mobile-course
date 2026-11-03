# AI-assisted development log

## Prompts

### Lab 1-2: Generate and verify title search

```text
Act as a senior Flutter developer. Work only in
09-week-9-ai-assisted-development/, which contains my existing Week 7
campus_notify app.

Add title search to the announcements screen. Users should be able to filter
announcements as they type; matching should ignore capitalization and extra
whitespace. Show a helpful empty state when there are no matches, and restore
all announcements when the search is cleared. Keep announcement taps and
existing navigation working.

First inspect the project’s current architecture and follow its patterns. Keep
the change focused: don’t create a notes feature, add dependencies, or refactor
unrelated code. Don’t introduce a new data layer just for this feature if the
existing app doesn’t need one.

Add a focused test for searching, no results, and clearing the search. Run the
test and flutter analyze from the Week 9 folder. Summarize your approach,
changed files, and test results; mention any assumptions or checks you couldn’t
complete.
```

### Lab 3: Debug and refactor search

```text
In 09-week-9-ai-assisted-development/, debug and refactor the announcement
title search.

Inspect the existing app patterns first. Reproduce a genuine bug with a focused
test, fix its root cause, and record it in docs/ai-log.md. If you can’t
reproduce a real bug, report what you checked instead of inventing one.

Keep the refactor focused: follow existing state-management patterns, preserve
case/whitespace-insensitive search, no-results and clear behavior, and
announcement navigation. Don’t add dependencies or create a data layer the app
doesn’t need.

From the Week 9 folder, run the focused test, flutter analyze, dart format
--set-exit-if-changed ., and flutter test. Summarize the bug, changes, and
results.
```

### AI Challenge review

```text
Review this Flutter search code as a senior dev.
Context: feature-first (presentation->domain<-data),
Riverpod, SQLite + Dio.
Focus: correctness, architecture, tests. Ignore style.
Give 3 findings + blocker/suggestion level + reasons.
```

## Work and results

### Announcement title search

- Reviewed the announcements route, widget, existing tests, and Riverpod
  notifier/use-case patterns.
- The initial search test passed for mixed-case input with repeated and
  surrounding whitespace, no results, clearing, and detail navigation. No
  reproducible search bug was found at that stage.
- Moved title matching into the pure `SearchAnnouncements` use case and search
  query state into a Riverpod notifier.
- Kept announcements in memory; the app has no announcement repository or
  persistence layer.

### AI Challenge findings and decisions

1. **Search state can outlive its text field. Accepted and fixed.** Changed the
   query provider to auto-dispose. A route-away-and-reopen widget test confirms
   the field clears and the full list returns.
2. **Search should use SQLite/Dio. Rejected as a defect.** This app has no
   announcement API or repository; adding a backend or persistence layer would
   expand the scope unnecessarily.
3. **Widget coverage should include multiple announcements. Accepted and
   tested.** The widget test overrides an in-memory provider with three
   announcements and verifies filtering.

### Verification

- Focused announcement search tests: 3 passed.
- Full test suite: 10 passed.
- `flutter analyze`: no issues.
- Formatting check: 3 files checked, 0 changed.
