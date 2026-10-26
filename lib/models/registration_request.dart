import '../core/state/session.dart';

/// Pengajuan pendaftaran anggota baru (baris `personnel` berstatus pending,
/// disetujui, atau ditolak).
class RegistrationRequest {
  const RegistrationRequest({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.requestedRole,
    required this.submittedAt,
    this.rejectionReason,
  });

  final String id;
  final String fullName;
  final String username;
  final String email;
  final UserRole requestedRole;
  final DateTime submittedAt;
  final String? rejectionReason;

  factory RegistrationRequest.fromJson(
    Map<String, dynamic> json, {
    required Map<int, String> roleNames,
  }) {
    final roleName = roleNames[json['requested_role_id']];
    return RegistrationRequest(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      requestedRole: roleName == 'pimpinan'
          ? UserRole.pimpinan
          : UserRole.pamdal,
      submittedAt:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}
