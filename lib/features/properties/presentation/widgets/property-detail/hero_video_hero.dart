import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:video_player/video_player.dart';

import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_price_overlay.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_scrims.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/video_player_page.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/video_utils.dart';
import '../../../domain/entities/property_entities.dart';

/// Hero widget used when a property has **videos but no images**.
///
/// Behaviour:
///   - First video auto-plays muted as soon as it is initialised.
///   - Tapping the slide toggles play / pause inline.
///   - Mute / unmute and full-screen buttons are accessible directly in the
///     carousel — no navigation required.
///   - The inline video renders with BoxFit.cover semantics, matching the
///     thumbnail frame exactly.
///   - Thumbnail is always rendered as a base layer; the video overlays it
///     once initialised, ensuring a seamless transition.
class HeroVideoHero extends StatefulWidget {
  const HeroVideoHero({super.key, required this.property});

  final Property property;

  @override
  State<HeroVideoHero> createState() => _HeroVideoHeroState();
}

class _HeroVideoHeroState extends State<HeroVideoHero> {
  int _currentIndex = 0;
  bool _isMuted = true;
  late final PageController _pageCtrl;

  // Per-slide state
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initializing = {};
  final Set<int> _initialized = {};
  final Set<int> _errors = {};

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _initAndPlay(0);
    // Pre-load second slide while user reads the page
    if (widget.property.videos.length > 1) _initController(1);
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.removeListener(_onControllerTick);
      ctrl.dispose();
    }
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Controller management ────────────────────────────────────────────────

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  Future<void> _initController(int index) async {
    if (_controllers.containsKey(index) || _initializing.contains(index)) {
      return;
    }
    final videos = widget.property.videos;
    if (index >= videos.length) return;

    _initializing.add(index);
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(videos[index].url));
    _controllers[index] = ctrl;
    ctrl.addListener(_onControllerTick);

    try {
      await ctrl.initialize();
      if (!mounted) return;
      await Future.wait([
        ctrl.setVolume(0), // always start silent until user unmutes
        ctrl.setLooping(true),
      ]);
      if (mounted) setState(() => _initialized.add(index));
    } catch (_) {
      if (mounted) setState(() => _errors.add(index));
    } finally {
      _initializing.remove(index);
    }
  }

  Future<void> _initAndPlay(int index) async {
    await _initController(index);
    if (!mounted || _currentIndex != index) return;
    final ctrl = _controllers[index];
    if (ctrl != null && _initialized.contains(index)) {
      await ctrl.setVolume(_isMuted ? 0.0 : 1.0);
      await ctrl.play();
    }
  }

  // ── User actions ─────────────────────────────────────────────────────────

  void _onPageChanged(int i) {
    _controllers[_currentIndex]?.pause();
    setState(() => _currentIndex = i);
    _initAndPlay(i);
    // Pre-fetch the next slide
    if (i + 1 < widget.property.videos.length) _initController(i + 1);
  }

  void _togglePlayPause() {
    final ctrl = _controllers[_currentIndex];
    if (ctrl == null || !_initialized.contains(_currentIndex)) return;
    ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _controllers[_currentIndex]?.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _openFullScreen() {
    final video = widget.property.videos[_currentIndex];
    _controllers[_currentIndex]?.pause();
    final config =
        kVideoTypeConfigs[video.videoType] ?? kDefaultVideoTypeConfig;
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black,
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                VideoPlayerPage(url: video.url, title: config.label),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        )
        .then((_) {
          // Resume playback when returning from full-screen
          if (mounted) _controllers[_currentIndex]?.play();
        });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final videos = widget.property.videos;
    final ctrl = _controllers[_currentIndex];
    final isReady = _initialized.contains(_currentIndex);
    final isPlaying = ctrl?.value.isPlaying ?? false;
    final isLoading = !isReady && !_errors.contains(_currentIndex);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Pageable video slides ────────────────────────────────────────
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: _onPageChanged,
          physics: const ClampingScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (_, i) {
            final c = _controllers[i];
            final ready = _initialized.contains(i);
            return GestureDetector(
              onTap: i == _currentIndex ? _togglePlayPause : null,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail — base layer, always visible until video is up
                  _Thumbnail(video: videos[i]),
                  // Inline video — overlays thumbnail once initialised,
                  // rendered with BoxFit.cover to match thumbnail frame.
                  // Uses the shared CoverVideo widget from video_utils.dart.
                  if (ready && c != null) CoverVideo(controller: c),
                ],
              ),
            );
          },
        ),

        // ── Gradient scrims ──────────────────────────────────────────────
        const HeroScrims(),

        // ── Buffering spinner ────────────────────────────────────────────
        if (isLoading)
          const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white38,
              ),
            ),
          ),

        // ── Centre play icon (fades out while playing) ───────────────────
        if (!isLoading && isReady)
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 220),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.45),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.55),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

        // ── Price / badges / dots overlay ────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: HeroPriceOverlay(
            property: widget.property,
            dotCount: videos.length,
            currentDot: _currentIndex,
            // Reserves 140 px on the right of the dots row for our controls
            reserveRightSpace: true,
          ),
        ),

        // ── Inline controls: mute + full-screen ──────────────────────────
        // Listed after HeroPriceOverlay so they sit above it in z-order
        // and receive tap events correctly.
        Positioned(
          bottom: 22,
          right: 18,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlCircle(
                icon: _isMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                tooltip: _isMuted ? 'Unmute' : 'Mute',
                onTap: _toggleMute,
              ),
              const Gap(10),
              _ControlCircle(
                icon: Icons.fullscreen_rounded,
                tooltip: 'Full screen',
                onTap: _openFullScreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── _Thumbnail ────────────────────────────────────────────────────────────────

/// Static thumbnail shown immediately, before the video is ready.
/// Uses [BoxFit.cover] — the exact same visual footprint as [CoverVideo].
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video});
  final PropertyVideo video;

  @override
  Widget build(BuildContext context) {
    final url = cloudinaryThumbnail(video.url);
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: Color(0xFF0F172A)),
        errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFF0F172A)),
      );
    }
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
    );
  }
}

// ── _ControlCircle ────────────────────────────────────────────────────────────

class _ControlCircle extends StatelessWidget {
  const _ControlCircle({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.55),
          border: Border.all(color: Colors.white.withOpacity(0.30)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
