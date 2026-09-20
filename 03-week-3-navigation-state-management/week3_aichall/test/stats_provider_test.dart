import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_aichall/providers/stats_provider.dart';

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
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(TestStatsNotifierSuccess.new),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(statsProvider),
      const AsyncLoading<List<String>>(),
    );

    final result = await container.read(statsProvider.future);

    expect(result.length, 3);
    expect(result.first, 'Total Users: 1,250');
  });
}