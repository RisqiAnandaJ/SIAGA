import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/registration_request.dart';
import '../state/session.dart';
import 'auth_repository.dart';
import 'registration_repository.dart';

class SupabaseRegistrationRepository implements RegistrationRepository {
  SupabaseRegistrationRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on PostgrestException catch (e) {
      // 42501 = tidak berwenang; P0001 = pesan dari `raise exception` di RPC.
      if (e.code == '42501') {
        throw const AuthFailure('Anda tidak berwenang melakukan aksi ini.');
      }
      if (e.code == 'P0001' && e.message.isNotEmpty) {
        throw AuthFailure(e.message);
      }
      throw const AuthFailure(
        'Terjadi kesalahan pada server. Coba lagi nanti.',
      );
    } on AuthException {
      throw const AuthFailure('Sesi berakhir. Silakan masuk kembali.');
    } on SocketException {
      throw const AuthFailure(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    }
  }

  @override
  Future<List<RegistrationRequest>> list(RegistrationFilter filter) =>
      _guard(() async {
        final roles = await _client.from('roles').select('id, name');
        final names = {
          for (final r in roles) r['id'] as int: r['name'] as String,
        };
        final base = _client.from('personnel').select();
        final rows = switch (filter) {
          RegistrationFilter.pending =>
            await base.eq('status', 'pending').order('created_at'),
          RegistrationFilter.approved =>
            await base
                .eq('status', 'active')
                .not('approved_by', 'is', null)
                .order('approved_at', ascending: false)
                .limit(20),
          RegistrationFilter.rejected =>
            await base
                .eq('status', 'rejected')
                .order('approved_at', ascending: false)
                .limit(20),
        };
        return [
          for (final row in rows)
            RegistrationRequest.fromJson(row, roleNames: names),
        ];
      });

  @override
  Future<void> approve(String id, {UserRole? role}) => _guard(() async {
    await _client.rpc<dynamic>(
      'approve_registration',
      params: {
        'p_id': id,
        'p_role': role == null
            ? null
            : (role == UserRole.pimpinan ? 'pimpinan' : 'pamdal'),
      },
    );
  });

  @override
  Future<void> reject(String id, String reason) => _guard(() async {
    await _client.rpc<dynamic>(
      'reject_registration',
      params: {'p_id': id, 'p_reason': reason.trim()},
    );
  });
}
