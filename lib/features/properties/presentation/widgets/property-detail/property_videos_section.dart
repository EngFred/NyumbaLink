import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

/// Horizontally scrollable video cards — one per PropertyVideoType.
/// Tapping any card opens a full-screen player with custom controls.
class PropertyVideosSection extends StatelessWidget {
  const PropertyVideosSection({super.key, required this.videos});
  final List<PropertyVideo> videos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text('Property Videos', style: AppTextStyles.h4),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${videos.length} ${videos.length == 1 ? 'clip' : 'clips'}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.grey500,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Video cards ───────────────────────────────────────────────────────
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) => _VideoCard(video: videos[index]),
          ),
        ),
      ],
    );
  }
}

// ── Video type config ─────────────────────────────────────────────────────────

class _VideoConfig {
  const _VideoConfig({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
}

const _kVideoConfigs = {
  'INTERIOR': _VideoConfig(
    label: 'Interior Tour',
    icon: Icons.living_outlined,
    gradientColors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    accentColor: Color(0xFF64B5F6),
  ),
  'EXTERIOR': _VideoConfig(
    label: 'Exterior Tour',
    icon: Icons.villa_outlined,
    gradientColors: [Color(0xFF134E5E), Color(0xFF1A5C3A), Color(0xFF2D8653)],
    accentColor: Color(0xFF81C784),
  ),
  'NEIGHBORHOOD': _VideoConfig(
    label: 'Neighbourhood',
    icon: Icons.location_city_outlined,
    gradientColors: [Color(0xFF1A0533), Color(0xFF2D1B69), Color(0xFF3B2A8A)],
    accentColor: Color(0xFFCE93D8),
  ),
};

const _kDefaultVideoConfig = _VideoConfig(
  label: 'Video Tour',
  icon: Icons.videocam_outlined,
  gradientColors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
  accentColor: Color(0xFF90CAF9),
);

// ── Video Card ────────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});
  final PropertyVideo video;

  @override
  Widget build(BuildContext context) {
    final config = _kVideoConfigs[video.videoType] ?? _kDefaultVideoConfig;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black,
          transitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, __, ___) => _VideoPlayerPage(
            url: video.url,
            title: config.label,
            accentColor: config.accentColor,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      child: Container(
        width: 186,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: config.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: config.gradientColors.first.withOpacity(0.55),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Decorative background orbs ──────────────────────────────────
            Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: config.accentColor.withOpacity(0.09),
                ),
              ),
            ),
            Positioned(
              bottom: -28,
              left: -28,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: config.accentColor.withOpacity(0.07),
                ),
              ),
            ),

            // ── Main content ────────────────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Type icon
                Center(
                  child: Icon(
                    config.icon,
                    size: 20,
                    color: config.accentColor.withOpacity(0.85),
                  ),
                ),
                const Gap(10),

                // Play button
                Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const Gap(12),

                // Label
                Center(
                  child: Text(
                    config.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Gap(3),
                Center(
                  child: Text(
                    'Tap to watch',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full-Screen Video Player Page ─────────────────────────────────────────────

class _VideoPlayerPage extends StatefulWidget {
  const _VideoPlayerPage({
    required this.url,
    required this.title,
    required this.accentColor,
  });
  final String url;
  final String title;
  final Color accentColor;

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _controller;
  late final AnimationController _controlsFade;

  bool _initialized = false;
  bool _showControls = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Allow landscape while player is open
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controlsFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1,
    );

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _initialized = true);
            _controller.play();
            _scheduleControlsHide();
          })
          .catchError((_) {
            if (mounted) setState(() => _hasError = true);
          });

    _controller.addListener(_onVideoTick);
  }

  void _onVideoTick() {
    if (mounted) setState(() {});
  }

  void _scheduleControlsHide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls && _controller.value.isPlaying) {
        _hideControls();
      }
    });
  }

  void _hideControls() {
    setState(() => _showControls = false);
    _controlsFade.reverse();
  }

  void _showControlsNow() {
    setState(() => _showControls = true);
    _controlsFade.forward();
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsNow();
      _scheduleControlsHide();
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _showControlsNow(); // Always show controls when paused
    } else {
      _controller.play();
      _scheduleControlsHide();
    }
  }

  @override
  void dispose() {
    // Restore portrait-only and system UI on close
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller
      ..removeListener(_onVideoTick)
      ..dispose();
    _controlsFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            // ── Video ──────────────────────────────────────────────────────
            if (_initialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else if (_hasError)
              _ErrorView(onClose: () => Navigator.of(context).pop())
            else
              _LoadingView(accentColor: widget.accentColor),

            // ── Controls overlay ───────────────────────────────────────────
            if (_initialized)
              FadeTransition(
                opacity: _controlsFade,
                child: _ControlsOverlay(
                  controller: _controller,
                  title: widget.title,
                  accentColor: widget.accentColor,
                  onClose: () => Navigator.of(context).pop(),
                  onPlayPause: _togglePlayPause,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Controls Overlay ──────────────────────────────────────────────────────────

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({
    required this.controller,
    required this.title,
    required this.accentColor,
    required this.onClose,
    required this.onPlayPause,
  });

  final VideoPlayerController controller;
  final String title;
  final Color accentColor;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pos = controller.value.position;
    final dur = controller.value.duration;
    final progress = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      children: [
        // Top fade gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // Bottom fade gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // ── Top bar: close button + title ───────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: onClose,
                  ),
                  const Gap(4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Center play/pause ───────────────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: onPlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.48),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),

        // ── Bottom controls: seek bar + time ────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: accentColor,
                      inactiveTrackColor: Colors.white.withOpacity(0.28),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (v) => controller.seekTo(
                        Duration(
                          milliseconds: (v * dur.inMilliseconds).round(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(pos),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _fmt(dur),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Loading View ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.accentColor});
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: accentColor, strokeWidth: 2.5),
        const Gap(20),
        Text(
          'Loading video…',
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
        ),
      ],
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.broken_image_outlined,
          color: Colors.white38,
          size: 56,
        ),
        const Gap(16),
        const Text(
          'Could not load video',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(8),
        const Text(
          'Check your connection and try again.',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const Gap(28),
        TextButton(
          onPressed: onClose,
          child: const Text('Go back', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
