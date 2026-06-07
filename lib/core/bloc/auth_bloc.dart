import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../constants/app_constants.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../utils/error_utils.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final LoginRequest request;
  const AuthLoginRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class AuthRegisterPatientRequested extends AuthEvent {
  final RegisterPatientRequest request;
  const AuthRegisterPatientRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class AuthRegisterDoctorRequested extends AuthEvent {
  final RegisterDoctorRequest request;
  const AuthRegisterDoctorRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class AuthRegisterClinicRequested extends AuthEvent {
  final RegisterClinicRequest request;
  const AuthRegisterClinicRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role;
  final AuthResponse auth;
  const AuthAuthenticated({required this.role, required this.auth});
  @override
  List<Object?> get props => [role, auth];
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});
  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<void>? _authInvalidatedSub;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterPatientRequested>(_onAuthRegisterPatientRequested);
    on<AuthRegisterDoctorRequested>(_onAuthRegisterDoctorRequested);
    on<AuthRegisterClinicRequested>(_onAuthRegisterClinicRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    // Listen for auth invalidation (e.g., expired refresh token)
    _authInvalidatedSub = _authService.onAuthInvalidated.listen((_) {
      add(AuthLogoutRequested());
    });
  }

  @override
  Future<void> close() {
    _authInvalidatedSub?.cancel();
    return super.close();
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authService.initialize();

    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && _authService.currentAuth != null) {
      final role = _authService.currentAuth!.role;
      emit(AuthAuthenticated(role: role, auth: _authService.currentAuth!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.login(event.request);
      if (response.isSuccess && response.data != null) {
        emit(AuthAuthenticated(
          role: response.data!.role,
          auth: response.data!,
        ));
      } else {
        emit(AuthFailure(response.message.isNotEmpty ? response.message : 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(errorMessage(e)));
    }
  }

  Future<void> _onAuthRegisterPatientRequested(
    AuthRegisterPatientRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.registerPatient(event.request);
      if (response.isSuccess && response.data != null) {
        emit(AuthAuthenticated(
          role: response.data!.role,
          auth: response.data!,
        ));
      } else {
        emit(AuthFailure(response.message.isNotEmpty ? response.message : 'Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(errorMessage(e)));
    }
  }

  Future<void> _onAuthRegisterDoctorRequested(
    AuthRegisterDoctorRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.registerDoctor(event.request);
      if (response.isSuccess && response.data != null) {
        emit(AuthAuthenticated(
          role: response.data!.role,
          auth: response.data!,
        ));
      } else {
        emit(AuthFailure(response.message.isNotEmpty ? response.message : 'Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(errorMessage(e)));
    }
  }

  Future<void> _onAuthRegisterClinicRequested(
    AuthRegisterClinicRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.registerClinic(event.request);
      if (response.isSuccess && response.data != null) {
        emit(AuthAuthenticated(
          role: response.data!.role,
          auth: response.data!,
        ));
      } else {
        emit(AuthFailure(response.message.isNotEmpty ? response.message : 'Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(errorMessage(e)));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthUnauthenticated) return; // Prevent logout loop
    emit(AuthLoading());
    await _authService.logout();
    emit(const AuthUnauthenticated());
  }
}
