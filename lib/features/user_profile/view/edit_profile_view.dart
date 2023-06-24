import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/models/user_model.dart';

import '../../../common/rounded_small_button.dart';
import '../../../theme/pallete.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const EditProfileView(),
      );
  const EditProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _bannerImage;
  File? _profileImage;

  void changeBannerImage() async {
    final banner = await pickImage();
    if (banner != null) {
      setState(() {
        _bannerImage = banner;
      });
    }
    return;
  }

  void changeProfileImage() async {
    final profile = await pickImage();
    if (profile != null) {
      setState(() {
        _profileImage = profile;
      });
    }
    return;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(getCurrentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _bioController.text.trim().isEmpty) {
                return;
              }
              ref
                  .watch(userProfileControllerProvider.notifier)
                  .updateUserProfile(
                    context: context,
                    userModel: currentUser!.copyWith(
                      name: _nameController.text,
                      bio: _bioController.text,
                    ),
                    bannerFile: _bannerImage,
                    profileFile: _profileImage,
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: currentUser == null
          ? const Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: changeBannerImage,
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: _bannerImage != null
                              ? Image.file(
                                  _bannerImage!,
                                  fit: BoxFit.cover,
                                )
                              : currentUser.bannerPic.isEmpty
                                  ? Container(
                                      color: Pallete.blueColor,
                                    )
                                  : Image.network(
                                      currentUser.bannerPic,
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: GestureDetector(
                          onTap: changeProfileImage,
                          child: _profileImage != null
                              ? CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Pallete.whiteColor,
                                  backgroundImage: FileImage(_profileImage!),
                                )
                              : CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Pallete.whiteColor,
                                  backgroundImage:
                                      NetworkImage(currentUser.profilePic),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _nameController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _bioController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
    );
  }
}
