import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUAuthService {
  HomeUAuthService._();

  static final HomeUAuthService instance = HomeUAuthService._();

  Session? get currentSession {
    if (!AppSupabase.isInitialized) {
      return null;
    }
    return AppSupabase.auth.currentSession;
  }

  bool get hasActiveSession => currentSession != null;

  bool get hasVerifiedSession {
    final session = currentSession;
    if (session == null) {
      return false;
    }
    return isUserEmailVerified(session.user);
  }

  Stream<AuthState> get onAuthStateChanged {
    if (!AppSupabase.isInitialized) {
      return const Stream<AuthState>.empty();
    }
    return AppSupabase.auth.onAuthStateChange;
  }

  String? get currentUserId => currentSession?.user.id;

  Future<HomeURole?> fetchCurrentUserRole() async {
    final userId = currentUserId;
    if (userId == null) {
      return null;
    }
    return fetchRoleByUserId(userId);
  }

  Future<HomeURole?> fetchRoleByUserId(String userId) async {
    if (!AppSupabase.isInitialized) {
      return null;
    }

    final dynamic row = await AppSupabase.client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    if (row is! Map<String, dynamic>) {
      return null;
    }

    final role = row['role']?.toString().trim().toLowerCase();
    if (role == 'owner') {
      return HomeURole.owner;
    }
    if (role == 'tenant') {
      return HomeURole.tenant;
    }
    return null;
  }

  bool isUserEmailVerified(User user) {
    final confirmedAt = user.emailConfirmedAt;
    return confirmedAt != null && confirmedAt.toString().trim().isNotEmpty;
  }

  Future<void> signOut() async {
    if (!AppSupabase.isInitialized) {
      return;
    }
    await AppSupabase.auth.signOut();
  }
}

