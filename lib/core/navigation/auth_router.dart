import 'package:flutter/material.dart';

import '../../features/auth/login_page.dart';
import '../../features/auth/status_pages.dart';
import '../../models/profile.dart';
import '../state/session.dart';
import 'role_shell.dart';

/// Menentukan layar tujuan setelah autentikasi berdasarkan status akun.
/// Akun aktif membuka [RoleShell] dan menetapkan sesi.
Widget screenForProfile(BuildContext context, Profile profile) {
  switch (profile.status) {
    case AccountStatus.active:
      SessionScope.read(context).signIn(profile);
      return const RoleShell();
    case AccountStatus.pending:
      return PendingApprovalPage(
        name: profile.firstName,
        email: profile.email,
        requestedRole: profile.requestedRole?.label ?? 'PAMDAL',
        submittedAt: profile.createdAt,
      );
    case AccountStatus.rejected:
      return RegistrationRejectedPage(
        reason: profile.rejectionReason,
        reviewedAt: profile.statusUpdatedAt,
      );
    case AccountStatus.inactive:
      return InactiveAccountPage(
        name: profile.fullName,
        updatedAt: profile.statusUpdatedAt,
      );
  }
}

/// Membuka [screenForProfile] dan menghapus riwayat navigasi sebelumnya.
void openForProfile(BuildContext context, Profile profile) {
  final page = screenForProfile(context, profile);
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => page),
    (_) => false,
  );
}

/// Kembali ke layar masuk setelah sesi berakhir.
void openLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    (_) => false,
  );
}
