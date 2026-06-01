import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Derives a Cloudinary thumbnail URL from a video URL.
/// Returns null when the URL is not a Cloudinary video URL.
String? cloudinaryThumbnail(String videoUrl) {
  try {
    if (!videoUrl.contains('cloudinary.com')) return null;
    return videoUrl
        .replaceFirst(
          '/video/upload/',
          '/video/upload/so_auto,w_600,q_auto,f_jpg/',
        )
        .replaceFirst(RegExp(r'\.(mp4|mov|webm)(\?.*)?$'), '.jpg');
  } catch (_) {
    return null;
  }
}

/// Display metadata for a video-type badge.
class VideoTypeConfig {
  const VideoTypeConfig({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

const Map<String, VideoTypeConfig> kVideoTypeConfigs = {
  'INTERIOR': VideoTypeConfig(
    label: 'Interior Tour',
    icon: Icons.chair_alt_rounded,
  ),
  'EXTERIOR': VideoTypeConfig(
    label: 'Exterior View',
    icon: Icons.home_work_rounded,
  ),
  'NEIGHBORHOOD': VideoTypeConfig(
    label: 'Neighborhood',
    icon: Icons.explore_rounded,
  ),
};

const VideoTypeConfig kDefaultVideoTypeConfig = VideoTypeConfig(
  label: 'Video Tour',
  icon: Icons.videocam_rounded,
);

// ── CoverVideo ─────────────────────────────────────────────────────────────────

/// Renders a [VideoPlayerController] with [BoxFit.cover] semantics so that the
/// video fills its parent container identically to [CachedNetworkImage] with
/// [fit: BoxFit.cover].
///
/// Shared by [HeroVideoHero] (property-detail page hero) and [InlineVideoPlayer]
/// (browse-feed cards) to prevent duplicating the FittedBox/SizedBox cover-video
/// pattern across the codebase.
class CoverVideo extends StatelessWidget {
  const CoverVideo({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;

    // Guard: size is zero until the controller finishes initialising.
    if (size.isEmpty) return const SizedBox.shrink();

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
