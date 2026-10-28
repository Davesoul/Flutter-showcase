// MUSIC — now-playing card + playlist.
//
// TECHNIQUES ON DISPLAY
// ---------------------
// • Local StatefulWidget state (no provider needed — the player is
//   self-contained). Contrast with the cart (commerce), which *is*
//   shared state: the lesson is choosing the cheapest state that works.
// • A Timer-driven fake playback position wired to a Slider.
// • Gradient "album art" tiles — no image assets required, which keeps
//   the repo asset-free and GitHub Pages friendly.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/code_view.dart';
import '../core/data.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  int _track = 0;
  bool _playing = true;
  double _pos = 42; // seconds into the track
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Advance playback once per second while playing.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_playing) return;
      setState(() {
        final len = kTracks[_track].length.inSeconds.toDouble();
        _pos = _pos + 1 >= len ? 0 : _pos + 1;
      });
    });
  }

  @override
  void dispose() {
    _ticker
        ?.cancel(); // always cancel timers — leaked tickers rebuild dead widgets
    super.dispose();
  }

  void _select(int i) => setState(() {
    _track = i;
    _pos = 0;
    _playing = true;
  });

  @override
  Widget build(BuildContext context) {
    final track = kTracks[_track];

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                eyebrow: 'Media',
                title: 'Now playing',
                subtitle: 'Self-contained StatefulWidget + Timer. No packages.',
                action: const CodeAction(
                  assetPath: 'assets/code/src__modules__music_page.dart',
                ),
              ),
              const SizedBox(height: Tokens.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 860;
                  final art = _NowPlaying(
                    track: track,
                    position: _pos,
                    playing: _playing,
                    onSeek: (v) => setState(() => _pos = v),
                    onToggle: () => setState(() => _playing = !_playing),
                    onNext: () => _select((_track + 1) % kTracks.length),
                    onPrev: () =>
                        _select((_track - 1 + kTracks.length) % kTracks.length),
                  );
                  final list = _Playlist(current: _track, onSelect: _select);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: art),
                        const SizedBox(width: Tokens.s16),
                        Expanded(child: list),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      art,
                      const SizedBox(height: Tokens.s16),
                      list,
                    ],
                  );
                },
              ),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmt(double seconds) {
  final s = seconds.round();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({
    required this.track,
    required this.position,
    required this.playing,
    required this.onSeek,
    required this.onToggle,
    required this.onNext,
    required this.onPrev,
  });

  final Track track;
  final double position;
  final bool playing;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggle, onNext, onPrev;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final len = track.length.inSeconds.toDouble();
    return GlassCard(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: track.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Tokens.r16),
            ),
            child: Center(
              child:
                  Icon(
                        Icons.music_note,
                        size: 84,
                        color: Colors.white.withValues(alpha: 0.9),
                      )
                      .animate(target: playing ? 1 : 0)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                      ),
            ),
          ),
          const SizedBox(height: Tokens.s16),
          Text(
            track.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            track.artist,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Tokens.s8),
          Row(
            children: [
              Text(_fmt(position), style: theme.textTheme.labelSmall),
              Expanded(
                child: Slider(
                  // Slider asserts 0 <= value <= max — clamp the timer-driven
                  // position instead of trusting it.
                  value: position.clamp(0, len),
                  max: len,
                  onChanged: onSeek,
                ),
              ),
              Text(_fmt(len), style: theme.textTheme.labelSmall),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: onPrev,
                icon: const Icon(Icons.skip_previous),
              ),
              const SizedBox(width: Tokens.s12),
              IconButton.filled(
                onPressed: onToggle,
                iconSize: 32,
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: Tokens.s12),
              IconButton.filledTonal(
                onPressed: onNext,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Playlist extends StatelessWidget {
  const _Playlist({required this.current, required this.onSelect});
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.s16,
              Tokens.s16,
              Tokens.s16,
              Tokens.s8,
            ),
            child: Text(
              'Up next',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (var i = 0; i < kTracks.length; i++)
            ListTile(
              selected: i == current,
              selectedTileColor: theme.colorScheme.primaryContainer.withValues(
                alpha: 0.4,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: kTracks[i].colors),
                  borderRadius: BorderRadius.circular(Tokens.r12),
                ),
                child: Icon(
                  i == current ? Icons.equalizer : Icons.music_note_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                kTracks[i].title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(kTracks[i].artist),
              trailing: Text(_fmt(kTracks[i].length.inSeconds.toDouble())),
              onTap: () => onSelect(i),
            ),
          const SizedBox(height: Tokens.s8),
        ],
      ),
    );
  }
}
