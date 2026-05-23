import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the app version from pubspec.yaml at runtime.
/// Automatically reflects whatever version is set in pubspec — no manual updates needed.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  // e.g. "1.3.0" — add build number with "${info.version}+${info.buildNumber}"
  return info.version;
});
