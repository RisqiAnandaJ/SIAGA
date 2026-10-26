import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../services/auth_repository.dart';
import '../services/demo_auth_repository.dart';
import '../services/registration_repository.dart';
import '../theme/siaga_colors.dart';

/// Tiga peran resmi SIAGA.
enum UserRole { pamdal, picPamdal, pimpinan }

/// Status akun: hanya `active` yang boleh masuk.
enum AccountStatus { active, pending, rejected, inactive }

extension UserRoleLabels on UserRole {
  String get label => switch (this) {
    UserRole.pamdal => 'PAMDAL',
    UserRole.picPamdal => 'PIC PAMDAL',
    UserRole.pimpinan => 'Pimpinan',
  };

  /// PIC dan Pimpinan memakai lencana emas; PAMDAL hijau zamrud.
  bool get isGoldBadge => this != UserRole.pamdal;

  Color get badgeColor =>
      isGoldBadge ? SiagaColors.padiGold : SiagaColors.kapasEmerald;

  String get demoName => switch (this) {
    UserRole.pamdal => 'Budi Santoso',
    UserRole.picPamdal => 'Rina Wulandari',
    UserRole.pimpinan => 'Ratna Kusuma',
  };

  String get demoUsername => switch (this) {
    UserRole.pamdal => 'budi.santoso',
    UserRole.picPamdal => 'rina.wulandari',
    UserRole.pimpinan => 'ratna.kusuma',
  };

  String get demoEmail => switch (this) {
    UserRole.pamdal => 'budi@example.com',
    UserRole.picPamdal => 'rina@example.com',
    UserRole.pimpinan => 'ratna@example.com',
  };

  String get initials {
    final parts = demoName.split(' ');
    return parts.map((p) => p[0]).take(2).join();
  }
}

/// Sesi aplikasi: peran aktif, tab bawah, dan status patroli.
/// Memakai ChangeNotifier bawaan Flutter (tanpa pustaka state management).
class AppSession extends ChangeNotifier {
  AppSession({AuthRepository? auth, RegistrationRepository? registrations})
    : auth = auth ?? DemoAuthRepository(),
      registrations = registrations ?? DemoRegistrationRepository();

  /// Akses autentikasi (Supabase bila terkonfigurasi, selain itu demonstrasi).
  final AuthRepository auth;

  /// Antrean pendaftaran (khusus PIC PAMDAL).
  final RegistrationRepository registrations;

  Profile? _profile;
  int _tab = 0;
  bool _patrolActive = false;
  SiagaThemeMode _themeMode = SiagaThemeMode.spatialNavy;

  Profile? get profile => _profile;
  UserRole? get role => _profile?.role;
  String get displayName => _profile?.fullName ?? role?.demoName ?? '';
  int get tab => _tab;
  bool get patrolActive => _patrolActive;
  SiagaThemeMode get themeMode => _themeMode;

  /// Menetapkan sesi untuk profil aktif.
  void signIn(Profile profile) {
    _profile = profile;
    _tab = 0;
    notifyListeners();
  }

  /// Mengakhiri sesi di server dan di aplikasi.
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on AuthFailure {
      // Sesi lokal tetap dibersihkan walau jaringan gagal.
    }
    _profile = null;
    _tab = 0;
    _patrolActive = false;
    notifyListeners();
  }

  void selectTab(int index) {
    if (index == _tab) return;
    _tab = index;
    notifyListeners();
  }

  void setPatrolActive(bool value) {
    _patrolActive = value;
    notifyListeners();
  }

  void setThemeMode(SiagaThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// Menyediakan [AppSession] ke seluruh pohon widget.
class SessionScope extends InheritedNotifier<AppSession> {
  const SessionScope({
    super.key,
    required AppSession session,
    required super.child,
  }) : super(notifier: session);

  static AppSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope tidak ditemukan di pohon widget');
    return scope!.notifier!;
  }

  /// Membaca tanpa berlangganan perubahan (untuk handler event).
  static AppSession read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope tidak ditemukan di pohon widget');
    return scope!.notifier!;
  }
}
