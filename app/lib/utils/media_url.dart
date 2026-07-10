import 'package:medyo/config/config.dart';

/// Normalizes an image/audio path returned by the API into a single
/// absolute URL, so every widget/player consumes the same shape regardless
/// of whether the backend sent a full URL or a relative storage path.
///
/// ```
/// https://host/storage/file.jpg -> unchanged
/// /storage/file.jpg             -> https://host/storage/file.jpg
/// storage/file.jpg              -> https://host/storage/file.jpg
/// images/file.jpg               -> https://host/storage/images/file.jpg
/// null or empty                 -> null
/// ```
String? normalizeMediaUrl(String? raw, {String? host}) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  // Already a full URL - leave untouched (covers http and https).
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  // Not a URL and not a plausible relative web path (e.g. a raw filesystem
  // path like /var/www/storage/... or C:\...) - reject rather than pass a
  // broken value to an image/audio widget.
  if (trimmed.contains(r'\') || trimmed.startsWith('/var/')) {
    return null;
  }

  final effectiveHost = (host ?? AppConfig.hostUrl);
  final normalizedHost =
      effectiveHost.endsWith('/') ? effectiveHost.substring(0, effectiveHost.length - 1) : effectiveHost;

  final path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;

  // Avoid producing ".../storage/storage/..." when the path already
  // contains the storage prefix.
  if (path.startsWith('storage/')) {
    return '$normalizedHost/$path';
  }

  return '$normalizedHost/storage/$path';
}
