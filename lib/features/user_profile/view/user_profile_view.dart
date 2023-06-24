import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/models/user_model.dart';

import '../../../constants/appwrite_constants.dart';
import '../controller/user_profile_controller.dart';
import '../widget/user_profile.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(
        builder: (context) => UserProfileView(userModel: userModel),
      );
  const UserProfileView({super.key, required this.userModel});

  final UserModel userModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;
    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
            data: (data) {
              if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${userModel.uid}.update')) {
                copyOfUser = UserModel.fromMap(data.payload);
                return UserProfile(userModel: copyOfUser);
              }
              return UserProfile(userModel: copyOfUser);
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () {
              return UserProfile(userModel: copyOfUser);
              // return Loader();
            },
          ),
    );
  }
}
