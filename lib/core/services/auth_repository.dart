import '../../models/profile.dart';

/// Galat yang aman ditampilkan kepada pengguna (Bahasa Indonesia).
/// [field] menandai kolom formulir yang bermasalah (mis. `username`).
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.field});

  final String message;
  final String? field;

  @override
  String toString() => message;
}

class RegistrationData {
  const RegistrationData({
    required this.fullName,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.requestedRole,
  });

  final String fullName;
  final String username;
  final String password;
  final String email;

  /// Sudah dinormalkan ke `+62...`.
  final String phone;

  /// `pamdal` atau `pimpinan`. `pic_pamdal` tidak tersedia pada pendaftaran.
  final String requestedRole;
}

/// Lapisan akses autentikasi. Layar tidak boleh memanggil Supabase langsung.
abstract class AuthRepository {
  /// Memulihkan sesi tersimpan; `null` bila tidak ada sesi.
  Future<Profile?> restoreSession();

  /// Masuk dengan username + password. Hanya akun `active` yang mempertahankan
  /// sesi; akun lain dikembalikan dengan statusnya, sesi diakhiri.
  Future<Profile> signIn(String username, String password);

  /// Membuat akun dan mengirim OTP email. Melempar [AuthFailure] bila
  /// username, email, atau nomor HP sudah terpakai.
  Future<void> register(RegistrationData data);

  Future<Profile?> verifySignupOtp(String email, String code);
  Future<void> resendSignupOtp(String email);

  Future<void> sendRecoveryOtp(String email);
  Future<void> verifyRecoveryOtp(String email, String code);
  Future<void> updatePassword(String newPassword);

  Future<void> signOut();
}
