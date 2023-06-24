import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/models/user_model.dart';

class ExploreControllerNotifier extends StateNotifier<bool> {
  final UserApi _userApi;
  ExploreControllerNotifier({required UserApi userApi})
      : _userApi = userApi,
        super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userApi.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}

// -----------------------------------------------------------------------------

final exploreControllerProvider =
    StateNotifierProvider<ExploreControllerNotifier, bool>((ref) {
  final userApi = ref.watch(userApiProvider);
  return ExploreControllerNotifier(userApi: userApi);
});

final searchUserProvider = FutureProvider.family((ref, String name) async {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});
