import 'package:flutter/material.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/features/user_profile/widget/user_profile.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

class SearchTile extends StatelessWidget {
  const SearchTile({super.key, required this.userModel});

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(UserProfileView.route(userModel));
      },
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Pallete.whiteColor,
        backgroundImage: NetworkImage(userModel.profilePic),
      ),
      title: Text(
        userModel.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${userModel.name}',
            style: const TextStyle(fontSize: 16, color: Pallete.greyColor),
          ),
          Text(
            userModel.bio,
            style: const TextStyle(fontSize: 16, color: Pallete.whiteColor),
          ),
        ],
      ),
    );
  }
}
