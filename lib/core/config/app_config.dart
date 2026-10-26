/// Konfigurasi lingkungan, dikirim melalui `--dart-define`. Jangan menanamkan
/// kunci rahasia (service role, Brevo, HiveMQ admin) di sini.
///
/// Contoh:
/// `flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co
///  --dart-define=SUPABASE_ANON_KEY=eyJ...`
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Tanpa URL dan anon key, aplikasi berjalan dalam mode demonstrasi.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
