import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../apis/auth_api.dart';
import '../../../apis/user_api.dart';
import '../../../core/utils.dart';
import '../../../models/user_model.dart';
import '../../home/view/home_view.dart';
import '../view/login_view.dart';

class AuthControllerNotifier extends StateNotifier<bool> {
  final AuthApi _authApi;
  final UserApi _userApi;
  AuthControllerNotifier({
    required AuthApi authApi,
    required UserApi userApi,
  })  : _authApi = authApi,
        _userApi = userApi,
        super(false);

  void signup(
      {required BuildContext context,
      required String email,
      required String password}) async {
    state = true;
    final response = await _authApi.signup(email: email, password: password);
    response.fold(
      (l) {
        showSnackbar(context, l.message);
        state = false;
      },
      (r) async {
        UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: '',
          bannerPic: '',
          uid: r.$id,
          bio: '',
          isTwitterBlue: false,
        );
        final response = await _userApi.saveUserData(userModel);
        response.fold(
          (l) {
            showSnackbar(context, l.message);
            state = false;
          },
          (r) {
            showSnackbar(context, 'Account created, Please LOGIN.');
            state = false;
            Navigator.of(context).push(LoginView.route());
          },
        );
      },
    );
  }

  void login(
      {required BuildContext context,
      required String email,
      required String password}) async {
    state = true;
    final response = await _authApi.login(email: email, password: password);
    response.fold(
      (l) {
        showSnackbar(context, l.message);
        state = false;
      },
      (r) {
        showSnackbar(context, 'LOGIN successful!');
        state = false;
        Navigator.of(context).push(HomeView.route());
      },
    );
  }

  Future<User?> getCurrentUserAccount() async {
    return await _authApi.getCurrentUserAccount();
  }

  Future<UserModel> getUserDetails(String uid) async {
    final document = await _userApi.getUserDetails(uid);
    final user = UserModel.fromMap(document.data);
    return user;
  }

  void logout(BuildContext context) async {
    final response = await _authApi.logout();
    response.fold((l) => null, (r) {
      Navigator.of(context).pushAndRemoveUntil(
        LoginView.route(),
        (route) => false,
      );
    });
  }
}

// -----------------------------------------------------------------------------

final authControllerProvider =
    StateNotifierProvider<AuthControllerNotifier, bool>((ref) {
  final authApi = ref.watch(authApiProvider);
  final userApi = ref.watch(userApiProvider);
  return AuthControllerNotifier(authApi: authApi, userApi: userApi);
});

final getCurrentUserAccountProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getCurrentUserAccount();
});

final getUserDetailsProvider = FutureProvider.family((ref, String uid) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserDetails(uid);
});

final getCurrentUserDetailsProvider = FutureProvider((ref) async {
  final uid = ref.watch(getCurrentUserAccountProvider).value!.$id;
  final currentUser = ref.watch(getUserDetailsProvider(uid));
  return currentUser.value;
});
