# AI PR Review: Proposal vs. Decision

## Prompt

```text
Review this Flutter PR as a senior Flutter dev.
Context: feature-first Clean Architecture
(presentation → domain ← data), Riverpod, GoRouter, SQLite + Dio.
Focus: correctness, architecture, tests. Ignore style.
Give the top 5 findings with severity (blocker/suggestion), rationale, and proposed code fix.
```

## Raw AI output

The unedited response is preserved in
[`../screenshots/Lab4_AI_Review.png`](../screenshots/Lab4_AI_Review.png).
The review was run against PR #1, which changes the Week 5 Offline Notes
project. The prompt's Clean Architecture context describes the Week 7 project,
so architecture proposals were checked against the actual PR scope.

## Proposal vs. final decision

| # | AI finding | AI severity | Decision | Evidence and rationale |
|---|---|---|---|---|
| 1 | Title validation should live in the domain layer rather than only in the widget. | Blocker | Reject as a blocker | PR #1 targets the Week 5 project, which has no domain/use-case layer. Adding that architecture is outside this focused UI validation change. The form rejects blank titles and trims accepted input. |
| 2 | The PR needs a CI workflow and the workflow must use the correct weekly project directory. | Blocker | Reject as a PR finding | CI configuration is not among PR #1's changed files. The workflow is a separate Lab 3 deliverable, not a defect in this PR. |
| 3 | The test misses cancellation and persistence-error cases. | Suggestion | Accept | `validate_note_test.dart` verifies blank-title rejection and trimmed-title saving, but does not exercise cancel or repository failure. These are useful follow-up cases, not blockers for the behavior under test. |
| 4 | The fake repository in the test depends on a concrete data-layer repository. | Suggestion | Accept as a future design improvement | The fake extends `NoteRepository`, a concrete class in `data/repositories` that uses SQLite. This coupling is real, though introducing a separate abstraction is beyond the Week 5 lab's current architecture. |
| 5 | Saving after the dialog lacks a mounted check and explicit error handling. | Suggestion | Accept as a follow-up hardening item | After the dialog returns a draft, `_addNote` calls the notifier without a mounted check or error handling. The focused test does not cover route disposal or repository failure. |

## Verification evidence

- Focused test: `flutter test test/validate_note_test.dart` — passed.
- Targeted analysis: `flutter analyze lib/pages/notes_page.dart test/validate_note_test.dart` — no issues.
- Terminal evidence: [`../screenshots/Lab4_AI_Verification.png`](../screenshots/Lab4_AI_Verification.png).
- PR change evidence: the commit adds the dialog validation and a focused
  widget test; it does not add a CI workflow.

No AI-proposed code changes were applied as part of this review.
