import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

/// A premium, production-ready horizontally scrollable video card section.
class PropertyVideosSection extends StatelessWidget {
  const PropertyVideosSection({super.key, required this.videos});
  final List<PropertyVideo> videos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const Gap(12),
              Text('Property Videos', style: AppTextStyles.h4),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${videos.length} ${videos.length == 1 ? 'clip' : 'clips'}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.grey600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Cinematic Video Cards ────────────────────────────────────────────
        SizedBox(
          height: 135, // Optimized height for clean 16:9-proportioned items
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const Gap(14),
            itemBuilder: (context, index) => _VideoCard(video: videos[index]),
          ),
        ),
      ],
    );
  }
}

// ── Minimalist Content Configuration ──────────────────────────────────────────
class _VideoConfig {
  const _VideoConfig({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

const _kVideoConfigs = {
  'INTERIOR': _VideoConfig(
    label: 'Interior Tour',
    icon: Icons.chair_alt_rounded,
  ),
  'EXTERIOR': _VideoConfig(
    label: 'Exterior View',
    icon: Icons.home_work_rounded,
  ),
  'NEIGHBORHOOD': _VideoConfig(
    label: 'Neighborhood',
    icon: Icons.explore_rounded,
  ),
};

const _kDefaultVideoConfig = _VideoConfig(
  label: 'Video Tour',
  icon: Icons.videocam_rounded,
);

// ── Premium Video Card ────────────────────────────────────────────────────────
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
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) =>
              _VideoPlayerPage(url: video.url, title: config.label),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      child: Container(
        width: 215, // Widescreen ratio silhouette
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Deep obsidian studio surface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            // Subtly muted cinematic radial backing to replace raw flat orbs
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      const Color(0xFF1E293B).withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Layout Structure
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper Row: Clean Context Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(config.icon, size: 12, color: Colors.white70),
                            const Gap(5),
                            Text(
                              config.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Lower Layout: Clean Text details & Absolute Inline Action
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Refined High-End Glassmorphic Play Trigger
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Watch Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(1),
                            Text(
                              'Tap to preview',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full-Screen Video Player Page ─────────────────────────────────────────────
class _VideoPlayerPage extends StatefulWidget {
  const _VideoPlayerPage({required this.url, required this.title});
  final String url;
  final String title;

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controlsFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
      _showControlsNow();
    } else {
      _controller.play();
      _scheduleControlsHide();
    }
  }

  @override
  void dispose() {
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
              const _LoadingView(),

            if (_initialized)
              FadeTransition(
                opacity: _controlsFade,
                child: _ControlsOverlay(
                  controller: _controller,
                  title: widget.title,
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
    required this.onClose,
    required this.onPlayPause,
  });
  final VideoPlayerController controller;
  final String title;
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x99000000), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.24),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.12),
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
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _fmt(dur),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
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
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
        const Gap(16),
        Text(
          'Loading video…',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
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
          Icons.error_outline_rounded,
          color: Colors.white30,
          size: 44,
        ),
        const Gap(14),
        const Text(
          'Could not load video',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(24),
        TextButton(
          onPressed: onClose,
          child: const Text(
            'Go back',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
