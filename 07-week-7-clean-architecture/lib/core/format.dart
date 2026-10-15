// Pure functions: testable without widgets, Firebase, or Dio.

// RemoteMessage.data -> route to open (always starts with '/').
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] ?? '/').toString();
  return route.startsWith('/') ? route : '/$route';
}

/// First 12 characters + "..." so full tokens never appear in screenshots.
String truncateToken(String? token) {
  if (token == null) return '(no token)';
  return token.length <= 12 ? token : '${token.substring(0, 12)}...';
}

/// HH:mm:ss, used by the debug log.
String formatClock(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
}
