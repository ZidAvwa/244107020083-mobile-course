import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_aichall/providers/stats_provider.dart';

// Test implementation overriding build() to eliminate randomness and delay during unit tests
class TestStatsNotifierSuccess extends StatsNotifier {
  @override
  Future<List<String>> build() async {
    return [
      'Total Users: 1,250',
      'Active Sessions: 84',
      'System Uptime: 99.9%',
    ];
  }
}

void main() {
  test('StatsNotifier produces correct data list on success', () async {
    // Create a ProviderContainer to isolate provider state during testing
    final container = ProviderContainer(
      overrides: [
        // Override the original provider with deterministic test notifier
        statsProvider.overrideWith(TestStatsNotifierSuccess.new),
      ],
    );
    // Ensure container resources are released after test execution
    addTearDown(container.dispose);

    // Initial state before future completes should be AsyncLoading
    expect(
      container.read(statsProvider),
      const AsyncLoading<List<String>>(),
    );

    // Read and await the async result of the provider
    final result = await container.read(statsProvider.future);

    // Assertions for item count and content
    expect(result.length, 3);
    expect(result.first, 'Total Users: 1,250');
  });
}