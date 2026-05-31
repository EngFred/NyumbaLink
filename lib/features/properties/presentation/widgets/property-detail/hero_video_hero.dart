import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_price_overlay.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_scrims.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/video_player_page.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/video_utils.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

/// Hero widget used when a property has **videos but no images**.
///
/// Replaces [HeroImageCarousel] in the [SliverAppBar] flexible space,
/// showing pageable video-thumbnail slides. Tapping a slide (or the
/// action button) opens [VideoPlayerPage] in full-screen.
class HeroVideoHero extends StatefulWidget {
  const HeroVideoHero({super.key, required this.property});

  final Property property;

  @override
  State<HeroVideoHero> createState() => _HeroVideoHeroState();
}

class _HeroVideoHeroState extends State<HeroVideoHero> {
  int _currentIndex = 0;
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openVideo(PropertyVideo video) {
    final config =
        kVideoTypeConfigs[video.videoType] ?? kDefaultVideoTypeConfig;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) =>
            VideoPlayerPage(url: video.url, title: config.label),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = widget.property.videos;
    final hasMultiple = videos.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Pageable video-thumbnail slides ──────────────────────────────
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemCount: videos.length,
          itemBuilder: (_, i) => _VideoThumbnailSlide(
            video: videos[i],
            onTap: () => _openVideo(videos[i]),
          ),
        ),

        // ── Gradient scrims ──────────────────────────────────────────────
        const HeroScrims(),

        // ── "Watch video(s)" action button ───────────────────────────────
        Positioned(
          bottom: 22,
          right: 18,
          child: GestureDetector(
            onTap: () => _openVideo(videos[_currentIndex]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const Gap(5),
                  Text(
                    hasMultiple
                        ? 'Watch all ${videos.length} videos'
                        : 'Watch video',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Price / badges / dots ────────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: HeroPriceOverlay(
            property: widget.property,
            dotCount: videos.length,
            currentDot: _currentIndex,
            reserveRightSpace: true,
          ),
        ),
      ],
    );
  }
}

// ── Single video-thumbnail slide ──────────────────────────────────────────────

class _VideoThumbnailSlide extends StatelessWidget {
  const _VideoThumbnailSlide({required this.video, required this.onTap});

  final PropertyVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = cloudinaryThumbnail(video.url);
    final config =
        kVideoTypeConfigs[video.videoType] ?? kDefaultVideoTypeConfig;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background thumbnail or dark gradient fallback ─────────────
          if (thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ColoredBox(color: Color(0xFF0F172A)),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF0F172A)),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
            ),

          // ── Centred play button + video-type label ─────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
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
                    size: 40,
                  ),
                ),
                const Gap(14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(config.icon, size: 13, color: Colors.white70),
                      const Gap(7),
                      Text(
                        config.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
