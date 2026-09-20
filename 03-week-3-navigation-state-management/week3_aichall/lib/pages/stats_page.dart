import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

// ConsumerWidget provides access to WidgetRef to listen to providers
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the AsyncValue state of the statistics provider
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      // Match the AsyncValue state to render the appropriate UI
      body: statsAsync.when(
        // Loading state: display a centered progress indicator
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // Error state: show error message and a retry button
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error: $err',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                // Invalidate the provider to force its build() method to run again
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        // Success state: display a ListView containing the 3 items
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}