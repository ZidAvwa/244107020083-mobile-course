import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (total, completed, remaining) = ref.watch(todoStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total tasks: $total', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Completed tasks: $completed', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Remaining tasks: $remaining', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}