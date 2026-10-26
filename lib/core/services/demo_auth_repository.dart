import '../../models/profile.dart';
import '../state/session.dart';
import 'auth_repository.dart';

/// Mode demonstrasi tanpa backend: peran dan status ditentukan dari kata
/// kunci pada username. Dipakai bila `SUPABASE_URL`/`SUPABASE_ANON_KEY`
/// belum diberikan, dan pada pengujian.
class DemoAuthRepository implements AuthRepository {
  @override
  Future<Profile?> restoreSession() async => null;

  @override
  Future<Profile> signIn(String username, String password) async {
    final user = username.trim().toLowerCase();
    if (user.isEmpty || password.isEmpty) {
      throw const AuthFailure('Username atau password salah');
    }

    final AccountStatus status;
    if (user.contains('menunggu')) {
      status = AccountStatus.pending;
    } else if (user.contains('ditolak')) {
      status = AccountStatus.rejected;
    } else if (user.contains('nonaktif')) {
      status = AccountStatus.inactive;
    } else {
      status = AccountStatus.active;
    }

    final role = user.contains('pic') || user.contains('rina')
        ? UserRole.picPamdal
        : (user.contains('pimpinan') || user.contains('ratna'))
        ? UserRole.pimpinan
        : UserRole.pamdal;

    return Profile(
      id: 'demo-$user',
      username: user,
      fullName: status == AccountStatus.active
          ? role.demoName
          : 'Dimas Pratama',
      email: status == AccountStatus.active
          ? role.demoEmail
          : 'dimas@example.com',
      phone: '+62 • disamarkan',
      status: status,
      role: status == AccountStatus.active ? role : null,
      requestedRole: UserRole.pamdal,
      rejectionReason: status == AccountStatus.rejected
          ? 'Data penugasan belum sesuai dengan daftar personel. Silakan konfirmasi identitas dan surat penugasan kepada PIC PAMDAL.'
          : null,
      statusUpdatedAt: DateTime(2026, 10, 23, 7, 35),
    );
  }

  @override
  Future<void> register(RegistrationData data) async {}

  @override
  Future<Profile?> verifySignupOtp(String email, String code) async => null;

  @override
  Future<void> resendSignupOtp(String email) async {}

  @override
  Future<void> sendRecoveryOtp(String email) async {}

  @override
  Future<void> verifyRecoveryOtp(String email, String code) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> signOut() async {}
}
