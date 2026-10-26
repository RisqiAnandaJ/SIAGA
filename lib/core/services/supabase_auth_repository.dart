import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';
import '../state/session.dart';
import 'auth_repository.dart';

/// Implementasi nyata di atas Supabase Auth + tabel `personnel`.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  static const _genericLogin = 'Username atau password salah';

  Future<T> _guard<T>(Future<T> Function() body, {String? otpContext}) async {
    try {
      return await body();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuth(e, otpContext: otpContext));
    } on PostgrestException {
      throw const AuthFailure(
        'Terjadi kesalahan pada server. Coba lagi nanti.',
      );
    } on SocketException {
      throw const AuthFailure(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    } on HttpException {
      throw const AuthFailure(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    }
  }

  String _mapAuth(AuthException e, {String? otpContext}) {
    final code = e.code ?? '';
    final status = e.statusCode;
    if (status == '429' || code.contains('rate_limit')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
    }
    if (otpContext != null &&
        (code.contains('otp') || e.message.toLowerCase().contains('token'))) {
      return 'Kode salah atau sudah kedaluwarsa.';
    }
    if (code == 'invalid_credentials' ||
        e.message.toLowerCase().contains('invalid login')) {
      return _genericLogin;
    }
    if (code == 'same_password') {
      return 'Gunakan password yang berbeda dari sebelumnya.';
    }
    if (code == 'email_not_confirmed') {
      return 'Email belum diverifikasi. Selesaikan verifikasi OTP terlebih dahulu.';
    }
    return 'Permintaan gagal. Coba lagi.';
  }

  Future<Map<int, String>> _roleNames() async {
    final rows = await _client.from('roles').select('id, name');
    return {for (final r in rows) r['id'] as int: r['name'] as String};
  }

  Future<Profile?> _loadProfile(String userId) async {
    final row = await _client
        .from('personnel')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromJson(row, roleNames: await _roleNames());
  }

  @override
  Future<Profile?> restoreSession() => _guard(() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final profile = await _loadProfile(user.id);
    if (profile == null || profile.status != AccountStatus.active) {
      await _client.auth.signOut();
      return profile;
    }
    return profile;
  });

  @override
  Future<Profile> signIn(String username, String password) => _guard(() async {
    final email = await _client.rpc<dynamic>(
      'get_login_email',
      params: {'p_username': username.trim()},
    );
    if (email is! String || email.isEmpty) {
      throw const AuthFailure(_genericLogin);
    }
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) throw const AuthFailure(_genericLogin);

    final profile = await _loadProfile(user.id);
    if (profile == null) {
      await _client.auth.signOut();
      throw const AuthFailure(_genericLogin);
    }
    if (profile.status != AccountStatus.active) {
      await _client.auth.signOut();
    }
    return profile;
  });

  @override
  Future<void> register(RegistrationData data) => _guard(() async {
    final availability = await _client.rpc<dynamic>(
      'check_registration_available',
      params: {
        'p_username': data.username,
        'p_email': data.email,
        'p_phone': data.phone,
      },
    );
    if (availability is Map) {
      if (availability['username_taken'] == true) {
        throw const AuthFailure('Username sudah dipakai', field: 'username');
      }
      if (availability['email_taken'] == true) {
        throw const AuthFailure('Email sudah terdaftar', field: 'email');
      }
      if (availability['phone_taken'] == true) {
        throw const AuthFailure(
          'Nomor handphone sudah terdaftar',
          field: 'phone',
        );
      }
    }
    final res = await _client.auth.signUp(
      email: data.email,
      password: data.password,
      data: {
        'username': data.username,
        'full_name': data.fullName,
        'phone': data.phone,
        'requested_role': data.requestedRole,
      },
    );
    // Supabase menyamarkan email yang sudah terdaftar dengan identities kosong.
    if (res.user?.identities?.isEmpty ?? false) {
      throw const AuthFailure('Email sudah terdaftar', field: 'email');
    }
  });

  @override
  Future<Profile?> verifySignupOtp(String email, String code) =>
      _guard(() async {
        final res = await _client.auth.verifyOTP(
          email: email,
          token: code,
          type: OtpType.signup,
        );
        final user = res.user;
        if (user == null) return null;
        return _loadProfile(user.id);
      }, otpContext: 'signup');

  @override
  Future<void> resendSignupOtp(String email) =>
      _guard(() => _client.auth.resend(type: OtpType.signup, email: email));

  @override
  Future<void> sendRecoveryOtp(String email) => _guard(() async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      // Email tak terdaftar tidak boleh terungkap; hanya batas laju yang dilaporkan.
      if (e.statusCode == '429') rethrow;
    }
  });

  @override
  Future<void> verifyRecoveryOtp(String email, String code) => _guard(() async {
    await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.recovery,
    );
  }, otpContext: 'recovery');

  @override
  Future<void> updatePassword(String newPassword) => _guard(() async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  });

  @override
  Future<void> signOut() => _guard(() => _client.auth.signOut());
}
