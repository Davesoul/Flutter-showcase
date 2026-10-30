// CHAT — conversation UI with simulated replies.
//
// TECHNIQUES ON DISPLAY
// ---------------------
// • Bubble alignment via Row + MainAxisAlignment (me → end, them → start)
// • A typing indicator (three bouncing dots with flutter_animate)
// • Optimistic send: the message appears instantly, then a Future.delayed
//   appends a canned reply. This is the same UX pattern real chat apps
//   use while waiting on a network round-trip — here the "network" is
//   just a timer, so no backend is needed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/code_view.dart';
import '../core/data.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMsg> _messages = [...kInitialMessages];
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;

  static const _replies = [
    'Got it — this reply was generated locally with a timer.',
    'Try the Motion lab next — the staggered lists are fun.',
    'Everything on this page is a plain ListView + setState.',
    'No backend, no sockets, no API keys. Just Flutter.',
  ];
  int _replyIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMsg(text, _now(), true));
      _typing = true;
    });
    _controller.clear();
    _scrollToEnd();
    // Simulated network round-trip.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMsg(
            _replies[_replyIndex++ % _replies.length], _now(), false));
        _typing = false;
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    // Wait a frame so the new item is laid out before scrolling.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _now() =>
      '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaxWidth(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              eyebrow: 'Messaging',
              title: 'Studio chat',
              subtitle: 'Send a message — replies are simulated locally.',
              action: CodeAction(
                  assetPath:
                      'assets/code/src__modules__chat_page.dart'),
            ),
            const SizedBox(height: Tokens.s16),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    // Fake conversation header.
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          child: Icon(Icons.smart_toy_outlined,
                              color: theme
                                  .colorScheme.onPrimaryContainer),
                        ),
                        const SizedBox(width: Tokens.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Prism Assistant',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(
                                          fontWeight:
                                              FontWeight.w800)),
                              Text(
                                _typing ? 'typing…' : 'online · local mock',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: _typing
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme
                                            .onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.videocam_outlined,
                            color:
                                theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: Tokens.s8),
                        Icon(Icons.call_outlined,
                            color:
                                theme.colorScheme.onSurfaceVariant),
                      ],
                    ),
                    const Divider(height: Tokens.s32),
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        itemCount:
                            _messages.length + (_typing ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _messages.length) {
                            return const _TypingBubble();
                          }
                          // Key by content+index so an inserted message gets
                          // its own entrance animation instead of reusing
                          // the previous bubble's element.
                          return _Bubble(
                            key: ValueKey(
                                '${_messages[i].text}$i'),
                            msg: _messages[i],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: Tokens.s8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Type a message…',
                              prefixIcon:
                                  Icon(Icons.emoji_emotions_outlined),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: Tokens.s8),
                        IconButton.filled(
                          onPressed: _send,
                          icon: const Icon(Icons.send_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Tokens.s16),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.msg});
  final ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final me = msg.me;
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Tokens.s4),
        padding: const EdgeInsets.symmetric(
            horizontal: Tokens.s16, vertical: Tokens.s12),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: me
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(Tokens.r16),
            topRight: const Radius.circular(Tokens.r16),
            bottomLeft: Radius.circular(me ? Tokens.r16 : Tokens.s4),
            bottomRight: Radius.circular(me ? Tokens.s4 : Tokens.r16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: me
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface),
            ),
            Text(msg.time,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: (me
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant)
                        .withValues(alpha: 0.7))),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.2, end: 0);
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Tokens.s4),
        padding: const EdgeInsets.symmetric(
            horizontal: Tokens.s16, vertical: Tokens.s12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Tokens.r16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: CircleAvatar(radius: 4, backgroundColor: scheme.primary)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                        begin: 0,
                        end: -5,
                        delay: (i * 150).ms,
                        duration: 300.ms),
              ),
          ],
        ),
      ),
    );
  }
}
