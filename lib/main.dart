import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/services/supabase_auth_repository.dart';
import 'core/services/supabase_registration_repository.dart';
import 'core/state/session.dart';
import 'core/theme/siaga_colors.dart';
import 'features/auth/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: SiagaColors.abyssalNavy,
    ),
  );

  // Tanpa SUPABASE_URL/SUPABASE_ANON_KEY aplikasi berjalan dalam mode demonstrasi.
  AppSession session = AppSession();
  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    final client = Supabase.instance.client;
    session = AppSession(
      auth: SupabaseAuthRepository(client),
      registrations: SupabaseRegistrationRepository(client),
    );
  }
  runApp(SiagaApp(session: session));
}

class SiagaApp extends StatefulWidget {
  const SiagaApp({super.key, this.session});

  /// Dapat diganti pada pengujian; bawaannya mode demonstrasi.
  final AppSession? session;

  @override
  State<SiagaApp> createState() => _SiagaAppState();
}

class _SiagaAppState extends State<SiagaApp> {
  late final AppSession _session = widget.session ?? AppSession();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: _session,
      child: MaterialApp(
        title: 'SIAGA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: SiagaColors.abyssalNavy,
          colorScheme: const ColorScheme.dark(
            primary: SiagaColors.padiGold,
            secondary: SiagaColors.kapasEmerald,
            error: SiagaColors.garudaCrimson,
            surface: SiagaColors.kemendagriNavy,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          splashFactory: InkRipple.splashFactory,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
