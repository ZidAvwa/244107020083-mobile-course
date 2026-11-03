import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory log shown on the Debug page (token events, backend calls).
final debugLogProvider =
    NotifierProvider<DebugLogNotifier, List<String>>(DebugLogNotifier.new);

class DebugLogNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void add(String line) {
    final t = DateTime.now().toIso8601String().substring(11, 19);
    state = [...state, '[$t] $line'];
  }
}
