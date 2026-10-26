import '../../models/registration_request.dart';
import '../state/session.dart';
import 'auth_repository.dart';

enum RegistrationFilter { pending, approved, rejected }

/// Antrean pendaftaran (khusus pemegang `registration.read`/`approve`).
/// Penegakan hak akses dilakukan RLS dan RPC di backend, bukan di sini.
abstract class RegistrationRepository {
  Future<List<RegistrationRequest>> list(RegistrationFilter filter);

  /// [role] mengoreksi peran yang diajukan; `null` memakai peran yang diminta.
  Future<void> approve(String id, {UserRole? role});

  /// Alasan wajib; dikirim kepada pemohon.
  Future<void> reject(String id, String reason);
}

/// Data contoh untuk mode demonstrasi.
class DemoRegistrationRepository implements RegistrationRepository {
  final List<RegistrationRequest> _pending = [
    RegistrationRequest(
      id: 'demo-1',
      fullName: 'Dimas Pratama',
      username: 'dimas.pratama',
      email: 'dimas@example.com',
      requestedRole: UserRole.pamdal,
      submittedAt: DateTime(2026, 10, 23, 7, 30),
    ),
    RegistrationRequest(
      id: 'demo-2',
      fullName: 'Nadia Putri',
      username: 'nadia.putri',
      email: 'nadia@example.com',
      requestedRole: UserRole.pimpinan,
      submittedAt: DateTime(2026, 10, 23, 7, 12),
    ),
    RegistrationRequest(
      id: 'demo-3',
      fullName: 'Arif Maulana',
      username: 'arif.maulana',
      email: 'arif@example.com',
      requestedRole: UserRole.pamdal,
      submittedAt: DateTime(2026, 10, 23, 6, 50),
    ),
  ];
  final List<RegistrationRequest> _approved = [
    RegistrationRequest(
      id: 'demo-0',
      fullName: 'Siti Rahma',
      username: 'siti.rahma',
      email: 'siti@example.com',
      requestedRole: UserRole.pamdal,
      submittedAt: DateTime(2026, 10, 22, 16, 10),
    ),
  ];
  final List<RegistrationRequest> _rejected = [];

  @override
  Future<List<RegistrationRequest>> list(RegistrationFilter filter) async =>
      List.of(switch (filter) {
        RegistrationFilter.pending => _pending,
        RegistrationFilter.approved => _approved,
        RegistrationFilter.rejected => _rejected,
      });

  @override
  Future<void> approve(String id, {UserRole? role}) async {
    final i = _pending.indexWhere((r) => r.id == id);
    if (i < 0) throw const AuthFailure('Pengajuan sudah diproses');
    _approved.insert(0, _pending.removeAt(i));
  }

  @override
  Future<void> reject(String id, String reason) async {
    if (reason.trim().isEmpty) {
      throw const AuthFailure('Alasan penolakan wajib diisi');
    }
    final i = _pending.indexWhere((r) => r.id == id);
    if (i < 0) throw const AuthFailure('Pengajuan sudah diproses');
    final r = _pending.removeAt(i);
    _rejected.insert(
      0,
      RegistrationRequest(
        id: r.id,
        fullName: r.fullName,
        username: r.username,
        email: r.email,
        requestedRole: r.requestedRole,
        submittedAt: r.submittedAt,
        rejectionReason: reason.trim(),
      ),
    );
  }
}
