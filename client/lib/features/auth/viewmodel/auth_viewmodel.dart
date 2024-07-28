import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/user_model.dart';
import '../../../core/providers/current_user_notifier.dart';
import '../repositories/auth_local_repository.dart';
import '../repositories/auth_remote_repository.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late final AuthRemoteRepository _authRemoteRepository;
  late final AuthLocalRepository _authLocalRepository;
  late final CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );

    res.fold((l) {
      state = AsyncValue.error(l.message, StackTrace.current);
    }, (r) {
      state = AsyncValue.data(r);
    });
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.login(
      email: email,
      password: password,
    );

    res.fold((l) {
      state = AsyncValue.error(l.message, StackTrace.current);
    }, (r) async {
      await _authLocalRepository.setToken(r.token);
      _currentUserNotifier.addUser(r);
      state = AsyncValue.data(r);
    });
  }

  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();
    if (token != null) {
      final response = await _authRemoteRepository.getCurrentUserData(token);
      final val = response.fold(
        (l) => state = AsyncValue.error(l.message, StackTrace.current),
        (r) {
          _currentUserNotifier.addUser(r);
          return state = AsyncValue.data(r);
        },
      );
      return val.value;
    }
    return null;
  }
}
