import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';

/// In-memory log shown on the Debug page (token events, backend calls).
final debugLogProvider =
    NotifierProvider<DebugLogNotifier, List<String>>(DebugLogNotifier.new);

class DebugLogNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void add(String line) {
    state = [...state, '[${formatClock(DateTime.now())}] $line'];
  }
}
