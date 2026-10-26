import '../core/state/session.dart';

/// Profil personel (baris `personnel` beserta nama peran).
class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    this.role,
    this.requestedRole,
    this.rejectionReason,
    this.statusUpdatedAt,
    this.createdAt,
  });

  final String id;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final AccountStatus status;

  /// Peran aktif; `null` sampai disetujui PIC PAMDAL.
  final UserRole? role;
  final UserRole? requestedRole;
  final String? rejectionReason;
  final DateTime? statusUpdatedAt;
  final DateTime? createdAt;

  String get firstName => fullName.trim().split(' ').first;

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    required Map<int, String> roleNames,
  }) {
    UserRole? roleOf(Object? id) {
      final name = id is int ? roleNames[id] : null;
      return switch (name) {
        'pamdal' => UserRole.pamdal,
        'pic_pamdal' => UserRole.picPamdal,
        'pimpinan' => UserRole.pimpinan,
        _ => null,
      };
    }

    DateTime? time(Object? v) =>
        v is String ? DateTime.tryParse(v)?.toLocal() : null;

    return Profile(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: switch (json['status']) {
        'active' => AccountStatus.active,
        'rejected' => AccountStatus.rejected,
        'inactive' => AccountStatus.inactive,
        _ => AccountStatus.pending,
      },
      role: roleOf(json['role_id']),
      requestedRole: roleOf(json['requested_role_id']),
      rejectionReason: json['rejection_reason'] as String?,
      statusUpdatedAt: time(json['approved_at']) ?? time(json['updated_at']),
      createdAt: time(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'status': status.name,
    'rejection_reason': rejectionReason,
  };

  Profile copyWith({AccountStatus? status, UserRole? role}) => Profile(
    id: id,
    username: username,
    fullName: fullName,
    email: email,
    phone: phone,
    status: status ?? this.status,
    role: role ?? this.role,
    requestedRole: requestedRole,
    rejectionReason: rejectionReason,
    statusUpdatedAt: statusUpdatedAt,
    createdAt: createdAt,
  );
}
