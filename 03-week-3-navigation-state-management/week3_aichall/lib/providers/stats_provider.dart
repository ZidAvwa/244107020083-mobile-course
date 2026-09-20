import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier manages the state transitions (loading, data, error) for async data
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // Simulate a 2-second network latency
    await Future.delayed(const Duration(seconds: 2));

    // Simulate ~30% chance of network or server failure
    if (Random().nextDouble() < 0.3) {
      throw Exception('Failed to fetch statistics from server.');
    }

    // Return 3 statistics items upon success
    return [
      'Total Users: 1,250',
      'Active Sessions: 84',
      'System Uptime: 99.9%',
    ];
  }
}

// Global provider declaration to be consumed by widgets or tests
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);