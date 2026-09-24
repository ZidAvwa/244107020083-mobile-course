# Flutter Week 4 - Networking and REST API

idk

## AI Verification Checklist

* **Does the UI call Dio directly (forbidden) or go through the repository?**
Yes. The UI reads Riverpod providers. The providers create repositories, and
the repositories are the only classes that call Dio.

* **Is `fromJson` null-safe, or does it still use direct casts that can crash?**
Partly. `Post.fromJson` uses nullable numeric conversion and `toString()` for
missing or non-string title/body values. However, `Comment.fromJson` still uses
direct `as String?` casts, so malformed non-string values can still throw. This
should be changed to the same defensive conversion before accepting the code.

* **Are all `DioExceptionType` values (timeout, connectionError, badResponse)
mapped to user messages?**
Yes. Timeout types, `connectionError`, `badResponse` status codes, and the
remaining Dio cases are mapped in `friendlyErrorMessage` and
`commentErrorMessage`. The UI displays these messages with retry actions.

* **Are `baseUrl` / timeouts centralized in one client instead of scattered
across methods?**
Partly. `baseUrl`, connection timeout, and receive timeout are centralized in
`createDio()` and shared through Riverpod. `CommentRepository.fetchComments`
also repeats all three timeout values in request options, so timeout
configuration is not completely centralized.

* **Does the AI test cover the missing-field case, or only the happy path? Add
at least 1 edge case of your own.**
No. The existing test is still the generated counter smoke test and does not
test JSON parsing or missing fields. An edge case to add is parsing a post with
missing `title` and `body`, which should produce empty strings instead of
throwing. A second useful case is a non-string title/body value, which the
current `Post.fromJson` handles through `toString()`.


## Reflection

idk
