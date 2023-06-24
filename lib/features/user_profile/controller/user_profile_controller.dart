import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/notification_api.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

import '../../../core/enum/notification_type_enum.dart';

class UserProfileControllerNotifier extends StateNotifier<bool> {
  final TweetApi _tweetApi;
  final StorageApi _storageApi;
  final UserApi _userApi;
  final NotificationControllerNotifier _notificationControllerNotifier;
  UserProfileControllerNotifier({
    required TweetApi tweetApi,
    required StorageApi storageApi,
    required UserApi userApi,
    required NotificationControllerNotifier notificationControllerNotifier,
  })  : _tweetApi = tweetApi,
        _storageApi = storageApi,
        _userApi = userApi,
        _notificationControllerNotifier = notificationControllerNotifier,
        super(false);

  Future<List<TweetModel>> getUserTweets(String uid) async {
    final response = await _tweetApi.getUserTweets(uid);
    return response.map((tweet) {
      return TweetModel.fromMap(tweet.data);
    }).toList();
  }

  void updateUserProfile({
    required BuildContext context,
    required UserModel userModel,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    if (bannerFile != null) {
      final bannerUrl = await _storageApi.uploadImages([bannerFile]);
      userModel = userModel.copyWith(bannerPic: bannerUrl[0]);
    }
    if (profileFile != null) {
      final profileUrl = await _storageApi.uploadImages([profileFile]);
      userModel = userModel.copyWith(profilePic: profileUrl[0]);
    }
    final result = await _userApi.updateUserData(userModel);

    result.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Navigator.of(context).pop(),
    );
  }

  void followUser(
      {required UserModel user,
      required BuildContext context,
      required UserModel currentUser}) async {
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }
    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);

    final result = await _userApi.followUser(user);
    result.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        final res = await _userApi.addToFollowing(currentUser);
        res.fold(
          (l) => showSnackbar(context, l.message),
          (r) {
            _notificationControllerNotifier.createNotification(
              text: '${currentUser.name} followed to you!',
              postId: '',
              uid: user.uid,
              notificationType: NotificationType.follow,
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileControllerNotifier, bool>((ref) {
  final tweetApi = ref.watch(tweetApiProvider);
  final storageApi = ref.watch(storageApiProvider);
  final userApi = ref.watch(userApiProvider);
  final notificationControllerNotifier =
      ref.watch(notificationControllerProvider.notifier);
  return UserProfileControllerNotifier(
    tweetApi: tweetApi,
    storageApi: storageApi,
    userApi: userApi,
    notificationControllerNotifier: notificationControllerNotifier,
  );
});

final userTweetProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userApi = ref.watch(userApiProvider);
  return userApi.getLatestProfileData();
});
