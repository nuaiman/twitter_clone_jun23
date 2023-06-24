import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/theme/pallete.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserDetailsProvider).value;
    return currentUser == null
        ? const Loader()
        : SafeArea(
            child: Drawer(
              backgroundColor: Pallete.backgroundColor,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  ListTile(
                    leading: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                    title: const Text(
                      'My profile',
                      style: TextStyle(fontSize: 22),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(UserProfileView.route(currentUser));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.payment,
                      size: 30,
                    ),
                    title: const Text(
                      'Twitter blue',
                      style: TextStyle(fontSize: 22),
                    ),
                    onTap: () {
                      ref
                          .read(userProfileControllerProvider.notifier)
                          .updateUserProfile(
                            context: context,
                            userModel:
                                currentUser.copyWith(isTwitterBlue: true),
                            bannerFile: null,
                            profileFile: null,
                          );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      size: 30,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 22),
                    ),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout(context);
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
