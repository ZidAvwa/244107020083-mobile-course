import 'package:dio/dio.dart';

/// Maps raw exceptions to user-friendly messages, so the UI never
/// sees DioException or stack traces.
String friendlyError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Check your network and retry.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Your session expired. Please log in again.';
        if (code == 403) return 'You do not have access to this content.';
        if (code == 404) return 'The requested content was not found.';
        if (code != null && code >= 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed (${code ?? 'unknown'}).';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}
