class Env {
  /// Android emulator -> host machine is 10.0.2.2 ; iOS sim/web -> localhost.
  /// Change to your machine's LAN IP when running on a physical device.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );

  /// API origin without the trailing '/api' — used to resolve relative
  /// media paths (e.g. '/uploads/laptop-0.png') returned by the backend.
  static String get origin =>
      baseUrl.endsWith('/api') ? baseUrl.substring(0, baseUrl.length - 4) : baseUrl;
}
