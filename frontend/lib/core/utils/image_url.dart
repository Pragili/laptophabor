import '../config/env.dart';

/// Resolves an image reference returned by the API into a loadable URL.
/// - Absolute URLs (http/https) are returned unchanged.
/// - Relative paths (e.g. '/uploads/laptop-0.png') are prefixed with the API origin,
///   so images load correctly on emulator, device and web alike.
String resolveImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  final path = raw.startsWith('/') ? raw : '/$raw';
  return '${Env.origin}$path';
}
