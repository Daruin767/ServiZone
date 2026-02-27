import 'package:flutter_bloc/flutter_bloc.dart';

enum UserRole { guest, client, provider, admin }

class AuthState {
  final bool isAuthenticated;
  final UserRole role;
  final String? userId;
  
  AuthState({
    this.isAuthenticated = false,
    this.role = UserRole.guest,
    this.userId,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    UserRole? role,
    String? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      userId: userId ?? this.userId,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());
  
  Future<void> login(String email, String password) async {
    emit(state.copyWith(isAuthenticated: true, role: UserRole.client));
  }
  
  Future<void> logout() async {
    emit(AuthState());
  }
  
  void setRole(UserRole role) {
    emit(state.copyWith(role: role));
  }
}