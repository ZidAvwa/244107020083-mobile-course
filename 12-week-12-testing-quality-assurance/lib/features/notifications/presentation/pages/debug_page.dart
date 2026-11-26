import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../providers/debug_log_provider.dart';
import '../providers/push_providers.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(fcmTokenProvider);
    final log = ref.watch(debugLogProvider);
    final token = tokenAsync.when(
      data: (t) => t,
      loading: () => null,
      error: (_, _) => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FCM token (truncated)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(truncateToken(token),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 18)),
            if (tokenAsync.hasError)
              Text('Token error: ${tokenAsync.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => ref.invalidate(fcmTokenProvider),
                  child: const Text('Reload token'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy full token'),
                  onPressed: token == null
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: token));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Token copied to clipboard')),
                          );
                        },
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Events', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [for (final l in log) Text(l)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
