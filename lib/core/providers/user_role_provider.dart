import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { buyer, seller, garage }

class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.buyer);

  void setRole(UserRole role) => state = role;
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>((ref) {
  return UserRoleNotifier();
});
