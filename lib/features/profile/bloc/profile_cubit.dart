// features/profile/bloc/profile_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/secure_storage.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileLoading()) {
    _authSubscription = SecureStorage.authChanges.listen((_) {
      loadProfile();
    });
  }
  StreamSubscription<void>? _authSubscription;

  Future<void> loadProfile() async {
    emit(const ProfileLoading());

    final token = await SecureStorage.getToken();
    final name = await SecureStorage.getName();
    final phone = await SecureStorage.getPhone();
    final avatar = await SecureStorage.getAvatar();

    if (token == null || token.isEmpty) {
      emit(const ProfileGuest());
      return;
    }

    emit(
      ProfileAuthenticated(
        name: name?.isNotEmpty == true ? name! : 'Путешественник',
        phone: phone ?? '',
        avatarUrl: avatar,
        ecoPoints: 0,
      ),
    );
  }

  Future<void> refreshAfterAuth() async {
    await loadProfile();
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
