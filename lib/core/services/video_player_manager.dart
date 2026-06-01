import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ──────────────────────────────────────────────────────────────────────
/// Immutable state for the global in-feed video playback coordinator.
class VideoPlayerManagerState {
  const VideoPlayerManagerState({
    this.activeVideoId,
    this.isMuted = true,
    Map<String, double>? visibilityFractions,
  }) : visibilityFractions = visibilityFractions ?? const {};

  /// The property ID of the currently playing in-feed video.
  /// Null when no video is playing.
  final String? activeVideoId;

  /// Global mute flag — starts muted (Instagram-style).
  /// Once the user unmutes one video, all subsequent auto-playing
  /// in-feed videos in the session also play with audio.
  final bool isMuted;

  /// Tracks the current visible fraction (0.0–1.0) of every in-feed video
  /// that has reported a non-zero visibility. Used by the notifier to always
  /// activate the *most visible* video rather than the last one to cross the
  /// threshold — prevents race conditions when multiple cards are
  /// simultaneously ≥ 50 % visible during a scroll.
  final Map<String, double> visibilityFractions;

  bool get hasActiveVideo => activeVideoId != null;

  VideoPlayerManagerState copyWith({
    String? activeVideoId,
    bool clearActive = false,
    bool? isMuted,
    Map<String, double>? visibilityFractions,
  }) {
    return VideoPlayerManagerState(
      activeVideoId: clearActive ? null : (activeVideoId ?? this.activeVideoId),
      isMuted: isMuted ?? this.isMuted,
      visibilityFractions: visibilityFractions ?? this.visibilityFractions,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────
/// Global in-feed video playback coordinator.
///
/// Guarantees only one in-feed video plays at a time across the entire app —
/// including across the browse feed and the property-detail page — by
/// broadcasting a single [activeVideoId] that all [InlineVideoPlayer]
/// instances react to.
///
/// Interaction contracts:
///   • [VisibilityVideoWrapper] calls [updateVisibility] on every scroll tick
///     so the manager can always activate the most visible video.
///   • Navigation tap-handlers call [pauseAll] before pushing a new route.
///   • [InlineVideoPlayer] watches this provider and plays / pauses its
///     controller when [activeVideoId] changes.
final videoPlayerManagerProvider =
    StateNotifierProvider<VideoPlayerManagerNotifier, VideoPlayerManagerState>(
      (_) => VideoPlayerManagerNotifier(),
    );

// ── Notifier ───────────────────────────────────────────────────────────────────
class VideoPlayerManagerNotifier
    extends StateNotifier<VideoPlayerManagerState> {
  VideoPlayerManagerNotifier() : super(const VideoPlayerManagerState());

  /// Minimum visible fraction a card must reach before it can become active.
  static const _kPlayThreshold = 0.5;

  /// Updates the visible fraction for [id] and re-evaluates which video
  /// should be active.
  ///
  /// Called by [VisibilityVideoWrapper] on every visibility change.
  /// The manager always activates the video with the **highest** fraction
  /// above [_kPlayThreshold], so when multiple cards are simultaneously
  /// above the threshold (common during a fast upward scroll), the most
  /// visible one wins instead of whichever happened to call [setActive] last.
  void updateVisibility(String id, double fraction) {
    final updated = Map<String, double>.from(state.visibilityFractions);
    if (fraction < 0.01) {
      // Card is effectively off-screen — remove it from the tracking map.
      updated.remove(id);
    } else {
      updated[id] = fraction;
    }

    // Pick the most visible candidate above the play threshold.
    String? newActive;
    var best = _kPlayThreshold; // candidate must beat this to qualify
    for (final entry in updated.entries) {
      if (entry.value >= best) {
        best = entry.value;
        newActive = entry.key;
      }
    }

    // Nothing changed — just persist the updated fractions map.
    if (state.activeVideoId == newActive) {
      state = state.copyWith(visibilityFractions: updated);
      return;
    }

    state = VideoPlayerManagerState(
      activeVideoId: newActive,
      isMuted: state.isMuted,
      visibilityFractions: updated,
    );
  }

  /// Pauses all in-feed videos immediately.
  ///
  /// Call before navigating away from the browse feed (e.g. to a property-
  /// detail page) to prevent a browse-page video and a detail-page video
  /// playing simultaneously. Visibility fractions are intentionally retained
  /// so playback can resume correctly if the user navigates back.
  void pauseAll() {
    if (!state.hasActiveVideo) return;
    state = VideoPlayerManagerState(
      isMuted: state.isMuted,
      visibilityFractions: state.visibilityFractions,
    );
  }

  /// Wakes up the most visible video based on the last known visibility fractions.
  /// Call this after returning from a screen where [pauseAll] was used (like transparent routes).
  void resumeActive() {
    String? bestId;
    var bestFraction = _kPlayThreshold; // Must beat the 0.5 threshold

    for (final entry in state.visibilityFractions.entries) {
      if (entry.value >= bestFraction) {
        bestFraction = entry.value;
        bestId = entry.key;
      }
    }

    // If we found a valid video that should be playing, wake it up
    if (bestId != null && state.activeVideoId != bestId) {
      state = state.copyWith(activeVideoId: bestId);
    }
  }

  /// Toggles the global mute state for all in-feed videos.
  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }
}
