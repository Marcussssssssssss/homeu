import 'package:homeu/app/auth/homeu_session.dart';

enum HomeURiskStatus {
  normal,
  suspicious,
  highRisk,
}

enum HomeUAccountStatus {
  active,
  suspended,
  removed,
}

class HomeUProfileData {
  const HomeUProfileData({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.riskStatus = HomeURiskStatus.normal,
    this.accountStatus = HomeUAccountStatus.active,
    this.riskReason,
    this.moderatedBy,
    this.moderatedAt,
  });

  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final HomeURole role;
  final String? profileImageUrl;
  final HomeURiskStatus riskStatus;
  final HomeUAccountStatus accountStatus;
  final String? riskReason;
  final String? moderatedBy;
  final String? moderatedAt;

  HomeUProfileData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    HomeURole? role,
    String? profileImageUrl,
    HomeURiskStatus? riskStatus,
    HomeUAccountStatus? accountStatus,
    String? riskReason,
    String? moderatedBy,
    String? moderatedAt,
  }) {
    return HomeUProfileData(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      riskStatus: riskStatus ?? this.riskStatus,
      accountStatus: accountStatus ?? this.accountStatus,
      riskReason: riskReason ?? this.riskReason,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      moderatedAt: moderatedAt ?? this.moderatedAt,
    );
  }

  static HomeURole mapRole(String? role) {
    final lower = role?.trim().toLowerCase();
    if (lower == 'owner') return HomeURole.owner;
    if (lower == 'admin') return HomeURole.admin;
    return HomeURole.tenant;
  }

  static HomeURiskStatus mapRiskStatus(String? status) {
    final lower = status?.trim().toLowerCase();
    if (lower == 'suspicious') return HomeURiskStatus.suspicious;
    if (lower == 'high_risk') return HomeURiskStatus.highRisk;
    return HomeURiskStatus.normal;
  }

  static HomeUAccountStatus mapAccountStatus(String? status) {
    final lower = status?.trim().toLowerCase();
    if (lower == 'suspended') return HomeUAccountStatus.suspended;
    if (lower == 'removed') return HomeUAccountStatus.removed;
    return HomeUAccountStatus.active;
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'user_id': userId,
      'id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'risk_status': riskStatus.name,
      'account_status': accountStatus.name,
      'risk_reason': riskReason,
      'moderated_by': moderatedBy,
      'moderated_at': moderatedAt,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory HomeUProfileData.fromCacheMap(Map<String, dynamic> map) {
    final id = (map['id'] ?? map['user_id'])?.toString() ?? '';
    return HomeUProfileData(
      userId: id,
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phoneNumber: map['phone_number']?.toString() ?? '',
      role: mapRole(map['role']?.toString()),
      profileImageUrl: map['profile_image_url']?.toString(),
      riskStatus: mapRiskStatus(map['risk_status']?.toString()),
      accountStatus: mapAccountStatus(map['account_status']?.toString()),
      riskReason: map['risk_reason']?.toString(),
      moderatedBy: map['moderated_by']?.toString(),
      moderatedAt: map['moderated_at']?.toString(),
    );
  }
}
