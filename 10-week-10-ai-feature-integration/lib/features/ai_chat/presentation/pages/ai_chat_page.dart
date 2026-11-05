import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ai_chat_service.dart';
import '../providers/ai_chat_providers.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final question = _messageController.text.trim();
    if (question.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isSending = true;
      _errorMessage = null;
    });
    _scrollToBottom();

    try {
      await for (final chunk in ref.read(aiChatServiceProvider).ask(question)) {
        if (!mounted) return;
        setState(() {
          if (_messages.last.isUser) {
            _messages.add(_ChatMessage(text: chunk, isUser: false));
          } else {
            final previous = _messages.last;
            _messages[_messages.length - 1] = _ChatMessage(
              text: '${previous.text}$chunk',
              isUser: false,
            );
          }
        });
        _scrollToBottom();
      }
    } on AiChatException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showSettings() async {
    final service = ref.read(aiChatServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (_) => _AiChatSettingsDialog(
        service: service,
        onSaved: () {
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('API key saved.')),
            );
          }
        },
        onRemoved: () {
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('API key removed.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            tooltip: 'AI settings',
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colors.tertiaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Questions are sent to Google Gemini. Don’t include passwords, '
              'personal information, or other sensitive data.',
              style: TextStyle(color: colors.onTertiaryContainer),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Ask a question to get started.\n'
                        'Add your Gemini API key in AI settings first.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? colors.primaryContainer
                                : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SelectableText(message.text),
                        ),
                      );
                    },
                  ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dismiss error',
                    onPressed: () => setState(() => _errorMessage = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Ask Gemini',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _isSending ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _AiChatSettingsDialog extends StatefulWidget {
  const _AiChatSettingsDialog({
    required this.service,
    required this.onSaved,
    required this.onRemoved,
  });

  final AiChatService service;
  final VoidCallback onSaved;
  final VoidCallback onRemoved;

  @override
  State<_AiChatSettingsDialog> createState() => _AiChatSettingsDialogState();
}

class _AiChatSettingsDialogState extends State<_AiChatSettingsDialog> {
  final _keyController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.service.saveApiKey(_keyController.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved();
    } on AiChatException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = 'Could not save the API key.';
      });
    }
  }

  Future<void> _removeKey() async {
    setState(() => _saving = true);
    try {
      await widget.service.clearApiKey();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onRemoved();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = 'Could not remove the API key.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('AI settings'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your Gemini API key. It is stored securely on this device.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _keyController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'Gemini API key',
            border: OutlineInputBorder(),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _saving ? null : _removeKey,
        child: const Text('Remove key'),
      ),
      FilledButton(
        onPressed: _saving ? null : _saveKey,
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ],
  );
}
