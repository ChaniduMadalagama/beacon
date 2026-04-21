import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get userStateChanges;
  Future<void> signInWithGoogle();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signInWithApple();
  Future<void> signOut();
}
