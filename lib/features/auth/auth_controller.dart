import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/auth_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for current user stream
final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Auth controller for state management
class AuthController extends Notifier<AsyncValue<void>> {
  late final AuthService _authService;

  @override
  AsyncValue<void> build() {
    _authService = ref.read(authServiceProvider);
    return const AsyncValue.data(null);
  }

  /// Sign in
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signInWithEmail(email, password);
    });
  }

  /// Create account
  Future<void> createAccount(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.createAccount(email, password);
    });
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.sendPasswordResetEmail(email);
    });
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signOut();
    });
  }
}

/// Provider for AuthController
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(() {
  return AuthController();
});
