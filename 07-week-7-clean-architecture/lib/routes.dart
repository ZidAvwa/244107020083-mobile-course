/// Single source of truth for route strings, shared by GoRouter and FCM deep links.
class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const debug = '/debug';
  static const announcementPattern = '/announcement/:id';
  static String announcement(String id) => '/announcement/$id';
}

/// Pure function (no Firebase): RemoteMessage.data -> route to open.
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] ?? '/').toString();
  return route.startsWith('/') ? route : '/$route';
}
