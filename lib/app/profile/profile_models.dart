import 'package:homeu/app/auth/homeu_session.dart';

class HomeUProfileData {
  const HomeUProfileData({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl,
  });

  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final HomeURole role;
  final String? profileImageUrl;

  HomeUProfileData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    HomeURole? role,
    String? profileImageUrl,
  }) {
    return HomeUProfileData(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  static HomeURole mapRole(String? role) {
    if (role?.trim().toLowerCase() == 'owner') {
      return HomeURole.owner;
    }
    return HomeURole.tenant;
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory HomeUProfileData.fromCacheMap(Map<String, dynamic> map) {
    return HomeUProfileData(
      userId: map['user_id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phoneNumber: map['phone_number']?.toString() ?? '',
      role: mapRole(map['role']?.toString()),
      profileImageUrl: map['profile_image_url']?.toString(),
    );
  }
}

