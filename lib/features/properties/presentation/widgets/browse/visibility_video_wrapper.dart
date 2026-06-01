import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../core/services/video_player_manager.dart';
import 'inline_video_player.dart';

/// Wraps [InlineVideoPlayer] with scroll-visibility detection.
///
/// Single responsibility: decide **when** to call
/// [VideoPlayerManagerNotifier.updateVisibility] based on how much of the
/// card frame is currently on screen. This widget knows nothing about video
/// rendering or controller management — that is [InlineVideoPlayer]'s concern.
///
/// On every scroll tick the raw visible fraction is forwarded to the manager,
/// which picks the **most visible** card above the 50 % threshold as the
/// active video. This prevents the race condition that arose when two cards
/// were simultaneously above the threshold and whichever called [setActive]
/// last (typically the lower card) incorrectly won.
class VisibilityVideoWrapper extends ConsumerWidget {
  const VisibilityVideoWrapper({
    super.key,
    required this.videoId,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  /// Must match the property id passed to [InlineVideoPlayer.videoId].
  final String videoId;
  final String videoUrl;

  /// Optional Cloudinary thumbnail URL forwarded to [InlineVideoPlayer].
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VisibilityDetector(
      // Key must be globally unique — property id satisfies this requirement.
      key: Key('video_vis_$videoId'),
      onVisibilityChanged: (info) {
        // Forward the raw fraction to the manager so it can always activate
        // the most visible video, rather than the last one to cross a binary
        // threshold (which caused incorrect playback when scrolling back up).
        ref
            .read(videoPlayerManagerProvider.notifier)
            .updateVisibility(videoId, info.visibleFraction);
      },
      child: InlineVideoPlayer(
        videoId: videoId,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      ),
    );
  }
}
