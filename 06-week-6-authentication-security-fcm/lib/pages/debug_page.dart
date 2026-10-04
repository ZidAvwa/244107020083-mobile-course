import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../messaging/push_service.dart';
import '../providers/debug_log_provider.dart';

class DebugPage extends ConsumerStatefulWidget {
  const DebugPage({super.key});

  @override
  ConsumerState<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
    // Keep the displayed token in sync when it rotates.
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      if (mounted) setState(() => _token = t);
    });
  }

  Future<void> _load() async {
    try {
      final t = await FirebaseMessaging.instance.getToken();
      if (mounted) setState(() => _token = t);
    } catch (e) {
      ref.read(debugLogProvider.notifier).add('getToken failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(debugLogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM token (truncated)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              truncateToken(_token),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _load,
                  child: const Text('Reload token'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy full token'),
                  onPressed: _token == null
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: _token!));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Token copied to clipboard'),
                            ),
                          );
                        },
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Events', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: ListView(children: [for (final l in log) Text(l)])),
          ],
        ),
      ),
    );
  }
}
