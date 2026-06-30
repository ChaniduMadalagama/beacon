import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthUser?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<_UserChanged>(_onUserChanged);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _userSubscription?.cancel();
    _userSubscription = _authRepository.userStateChanges.listen((user) {
      add(_UserChanged(user));
    });
  }

  // Private event to handle user state changes from the repository stream
  void _onUserChanged(_UserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithAppleRequested(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithApple();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signUpWithEmailAndPassword(
        event.email,
        event.password,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const AuthMessage('Password reset email has been sent. Please check your inbox.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

// Internal event for handling stream updates
class _UserChanged extends AuthEvent {
  final AuthUser? user;
  const _UserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

/**
 * --- FILE SUMMARY ---
 * This file is the "Authentication Brain." 
 * It manages everything related to logging in and out. It uses Bloc 
 * to listen to events (like clicking a button) and tells the app 
 * if the user is 'Authenticated' or not.
 *
 * --- FUNCTION BREAKDOWN ---
 * 
 * 1. _onSubscriptionRequested:
 *    - The "Live Watcher." It starts listening to the AuthRepository 
 *      to see if a user logs in or out anywhere in the app.
 * 
 * 2. _onUserChanged:
 *    - The "Decision Maker." Whenever the watcher sees a change, 
 *      this function decides if the app should show the Dashboard 
 *      (Authenticated) or the Login screen (Unauthenticated).
 * 
 * 3. SignIn/SignUp/SignOut Functions:
 *    - The "Action Handlers." They tell the repository to talk to 
 *      Google or Firebase to perform the actual login work.
 * 
 * --- HOW TO ACCESS ---
 * You access this brain in your UI using: 'context.read<AuthBloc>()'.
 * This works because we provided the Bloc at the very top of the app 
 * inside 'main.dart'. The '_userSubscription' is just an internal 
 * tool the brain uses to "listen" for changes; the UI doesn't talk 
 * to the subscription directly.
 */
