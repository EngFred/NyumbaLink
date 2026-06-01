import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/services/video_player_manager.dart';
import '../../../../../core/theme/app_colors.dart';
import '../property-detail/video_utils.dart';

/// Pure-presentation in-feed video player for the browse-page property card.
///
/// Single responsibility: own a [VideoPlayerController] lifecycle and react
/// to [VideoPlayerManagerNotifier] state changes (active video + mute).
///
/// The widget plays when its [videoId] matches [VideoPlayerManagerState.activeVideoId]
/// and pauses otherwise — it is therefore safe to have many instances on screen
/// simultaneously; only the active one ever has its controller playing.
///
/// A static [_VideoThumbnail] is always rendered as the base layer so there
/// is no blank frame during controller initialisation.
class InlineVideoPlayer extends ConsumerStatefulWidget {
  const InlineVideoPlayer({
    super.key,
    required this.videoId,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  /// Unique identifier — must match the id used in
  /// [VideoPlayerManagerNotifier.setActive]. Typically the property's id.
  final String videoId;

  /// Direct video URL passed to [VideoPlayerController.networkUrl].
  final String videoUrl;

  /// Optional thumbnail shown as the static base layer before the video is
  /// ready. Falls back to a neutral placeholder when null.
  final String? thumbnailUrl;

  @override
  ConsumerState<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends ConsumerState<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  // ── Controller lifecycle ──────────────────────────────────────────────────
  Future<void> _initController() async {
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = ctrl;
    ctrl.addListener(_onTick);

    try {
      await ctrl.initialize();
      if (!mounted) return;
      await Future.wait([
        ctrl.setVolume(0), // always start silent — correct volume applied below
        ctrl.setLooping(true),
      ]);
      setState(() => _initialized = true);

      // Sync volume and auto-play against whatever the manager state is *now*,
      // since the initialisation is async and the state may have changed.
      final managerState = ref.read(videoPlayerManagerProvider);

      // Check if this specific video is unmuted
      final isMuted = !managerState.unmutedVideoIds.contains(widget.videoId);
      await ctrl.setVolume(isMuted ? 0.0 : 1.0);

      if (managerState.activeVideoId == widget.videoId) _play();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  /// Rebuild to push updated video frames through the widget tree.
  void _onTick() {
    if (mounted) setState(() {});
  }

  void _play() {
    if (_initialized && !_hasError) _controller?.play();
  }

  void _pause() => _controller?.pause();

  void _applyMute(bool muted) => _controller?.setVolume(muted ? 0.0 : 1.0);

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // React to active-video and mute changes without triggering a full rebuild —
    // ref.listen is a side-effect listener, not a watch.
    ref.listen<VideoPlayerManagerState>(videoPlayerManagerProvider, (
      prev,
      next,
    ) {
      if (!mounted || !_initialized) return;

      final wasActive = prev?.activeVideoId == widget.videoId;
      final isActive = next.activeVideoId == widget.videoId;

      if (isActive && !wasActive) {
        _play();
      } else if (!isActive && wasActive) {
        _pause();
      }

      // Sync volume whenever THIS video's mute state is toggled.
      final wasMuted =
          !(prev?.unmutedVideoIds.contains(widget.videoId) ?? false);
      final isCurrentlyMuted = !next.unmutedVideoIds.contains(widget.videoId);

      if (wasMuted != isCurrentlyMuted) {
        _applyMute(isCurrentlyMuted);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Static thumbnail — always rendered as base layer ──────────────
        _VideoThumbnail(url: widget.thumbnailUrl),
        // ── Video overlay — appears once controller is initialised ─────────
        if (_initialized && _controller != null)
          CoverVideo(controller: _controller!),
      ],
    );
  }
}

// ── _VideoThumbnail ───────────────────────────────────────────────────────────
/// Static image rendered before the video controller is ready.
///
/// Named [_VideoThumbnail] (not [_Thumbnail]) to be unambiguous alongside the
/// similarly named private class in [hero_video_hero.dart].
class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: AppColors.grey100),
        errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.grey100),
      );
    }
    return const ColoredBox(color: AppColors.grey100);
  }
}
