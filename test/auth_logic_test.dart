import 'package:flutter_test/flutter_test.dart';
import 'package:siaga/core/services/auth_repository.dart';
import 'package:siaga/core/services/demo_auth_repository.dart';
import 'package:siaga/core/state/session.dart';
import 'package:siaga/core/utils/phone.dart';
import 'package:siaga/models/profile.dart';

void main() {
  group('normalizeIndonesianPhone', () {
    test('accepts local, 62-prefixed, and +62 formats', () {
      expect(normalizeIndonesianPhone('0812-3456-7890'), '+6281234567890');
      expect(normalizeIndonesianPhone('6281234567890'), '+6281234567890');
      expect(normalizeIndonesianPhone('+62 812 3456 7890'), '+6281234567890');
      expect(normalizeIndonesianPhone('81234567890'), '+6281234567890');
    });

    test('rejects too short, too long, and non-mobile numbers', () {
      expect(normalizeIndonesianPhone('0812'), isNull);
      expect(normalizeIndonesianPhone('0812345678901234'), isNull);
      expect(normalizeIndonesianPhone('02112345678'), isNull);
      expect(normalizeIndonesianPhone(''), isNull);
    });
  });

  test('maskPhone hides the middle digits', () {
    expect(maskPhone('+6281234567890'), '+62 8•••••••890');
    expect(maskPhone('+62 • disamarkan'), '+62 • disamarkan');
  });

  group('Profile.fromJson', () {
    const roles = {1: 'pamdal', 2: 'pic_pamdal', 3: 'pimpinan'};

    test('maps an active PIC row', () {
      final p = Profile.fromJson({
        'id': 'u1',
        'username': 'rina.wulandari',
        'full_name': 'Rina Wulandari',
        'email': 'rina@example.com',
        'phone': '+6281234567890',
        'status': 'active',
        'role_id': 2,
        'requested_role_id': 1,
        'approved_at': '2026-10-23T00:35:00Z',
      }, roleNames: roles);
      expect(p.status, AccountStatus.active);
      expect(p.role, UserRole.picPamdal);
      expect(p.requestedRole, UserRole.pamdal);
      expect(p.firstName, 'Rina');
      expect(p.statusUpdatedAt, isNotNull);
    });

    test(
      'pending row has no role and unknown status falls back to pending',
      () {
        final p = Profile.fromJson({
          'id': 'u2',
          'full_name': 'Dimas Pratama',
          'status': 'weird',
          'role_id': null,
          'requested_role_id': 1,
        }, roleNames: roles);
        expect(p.status, AccountStatus.pending);
        expect(p.role, isNull);
      },
    );
  });

  group('DemoAuthRepository', () {
    final repo = DemoAuthRepository();

    test('empty credentials fail with the generic message', () async {
      expect(
        () => repo.signIn('', ''),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            'Username atau password salah',
          ),
        ),
      );
    });

    test(
      'status keywords produce non-active profiles without a role',
      () async {
        final pending = await repo.signIn('akun.menunggu', 'x');
        final rejected = await repo.signIn('akun.ditolak', 'x');
        final inactive = await repo.signIn('akun.nonaktif', 'x');
        expect(pending.status, AccountStatus.pending);
        expect(rejected.status, AccountStatus.rejected);
        expect(rejected.rejectionReason, isNotEmpty);
        expect(inactive.status, AccountStatus.inactive);
        for (final p in [pending, rejected, inactive]) {
          expect(p.role, isNull);
        }
      },
    );
  });
}
