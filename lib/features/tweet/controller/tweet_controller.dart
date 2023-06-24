import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/core/enum/notification_type_enum.dart';
import 'package:twitter_clone/core/enum/tweet_type_enum.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/home/view/home_view.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

class TweetControllerNotifier extends StateNotifier<bool> {
  final Ref _ref;
  final TweetApi _tweetApi;
  final StorageApi _storageApi;
  final NotificationControllerNotifier _notificationControllerNotifier;
  TweetControllerNotifier({
    required Ref ref,
    required TweetApi tweetApi,
    required StorageApi storageApi,
    required NotificationControllerNotifier notificationControllerNotifier,
  })  : _ref = ref,
        _tweetApi = tweetApi,
        _storageApi = storageApi,
        _notificationControllerNotifier = notificationControllerNotifier,
        super(false);

  void shareTweet({
    required BuildContext context,
    required List<File> images,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    if (text.isEmpty) {
      showSnackbar(context, 'Please enter text');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
          context: context,
          images: images,
          text: text,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    } else {
      _shareTextTweet(
          context: context,
          text: text,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    }
  }

  void _shareImageTweet({
    required BuildContext context,
    required List<File> images,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagFromText(text);
    final link = _getLinkFromText(text);
    final imageLinks = await _storageApi.uploadImages(images);
    final user = _ref.read(getCurrentUserDetailsProvider).value!;
    TweetModel tweetModel = TweetModel(
        text: text,
        hashtags: hashtags,
        link: link,
        imageLinks: imageLinks,
        uid: user.uid,
        tweetType: TweetType.image,
        tweetedAt: DateTime.now(),
        likes: [],
        commentIds: [],
        reshareCount: 0,
        id: '',
        retweetedBy: '',
        repliedTo: repliedTo);
    final response = await _tweetApi.shareTweet(tweetModel);
    response.fold(
      (l) {
        showSnackbar(context, l.message);
        state = false;
      },
      (r) {
        if (repliedToUserId.isNotEmpty) {
          _notificationControllerNotifier.createNotification(
            text: '${user.name} replied to your tweet!',
            postId: r.$id,
            uid: repliedToUserId,
            notificationType: NotificationType.reply,
          );
        }
        state = false;
        Navigator.of(context).push(HomeView.route());
      },
    );
  }

  void _shareTextTweet({
    required BuildContext context,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagFromText(text);
    final link = _getLinkFromText(text);
    final user = _ref.read(getCurrentUserDetailsProvider).value!;
    TweetModel tweetModel = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: [],
      commentIds: [],
      reshareCount: 0,
      id: '',
      retweetedBy: '',
      repliedTo: repliedTo,
    );
    final response = await _tweetApi.shareTweet(tweetModel);
    response.fold(
      (l) {
        showSnackbar(context, l.message);
        state = false;
      },
      (r) {
        if (repliedToUserId.isNotEmpty) {
          _notificationControllerNotifier.createNotification(
            text: '${user.name} replied to your tweet!',
            postId: r.$id,
            uid: repliedToUserId,
            notificationType: NotificationType.reply,
          );
        }
        state = false;
        Navigator.of(context).push(HomeView.route());
      },
    );
  }

  String _getLinkFromText(String text) {
    String link = '';
    List<String> wordsInSentences = text.split(' ');
    for (String word in wordsInSentences) {
      if (word.startsWith('http://') ||
          word.startsWith('https://') ||
          word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashtagFromText(String text) {
    List<String> hashtags = [];
    List<String> wordsInSentences = text.split(' ');
    for (String word in wordsInSentences) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }

  Future<List<TweetModel>> getTweets() async {
    final tweetList = await _tweetApi.getTweets();
    final listOfTweets =
        tweetList.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
    return listOfTweets;
  }

  void likeTweet(TweetModel tweetModel, UserModel userModel) async {
    List<String> likes = tweetModel.likes;
    if (tweetModel.likes.contains(userModel.uid)) {
      likes.remove(userModel.uid);
    } else {
      likes.add(userModel.uid);
    }

    tweetModel = tweetModel.copyWith(likes: likes);

    final response = await _tweetApi.likeTweet(tweetModel);

    response.fold(
      (l) => print(l.message),
      (r) {
        _notificationControllerNotifier.createNotification(
          text: '${userModel.name} liked your tweet!',
          postId: tweetModel.id,
          uid: tweetModel.uid,
          notificationType: NotificationType.like,
        );
      },
    );
  }

  void reshareTweet(BuildContext context, TweetModel tweetModel,
      UserModel currentUser) async {
    tweetModel = tweetModel.copyWith(
      retweetedBy: currentUser.name,
      likes: [],
      commentIds: [],
      reshareCount: tweetModel.reshareCount + 1,
    );
    final response = await _tweetApi.updateTweetReshareCount(tweetModel);
    response.fold(
      (l) => showSnackbar(context, l.message),
      (r) async {
        tweetModel = tweetModel.copyWith(
          id: ID.unique(),
          reshareCount: 0,
          tweetedAt: DateTime.now(),
        );
        final response = await _tweetApi.shareTweet(tweetModel);

        response.fold(
          (l) => showSnackbar(context, l.message),
          (r) async {
            _notificationControllerNotifier.createNotification(
              text: '${currentUser.name} reshared your tweet!',
              postId: tweetModel.id,
              uid: tweetModel.uid,
              notificationType: NotificationType.like,
            );
          },
        );
      },
    );
  }

  Future<List<TweetModel>> getTweetReplies(TweetModel tweet) async {
    final documents = await _tweetApi.getTweetReplies(tweet);
    return documents.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }

  Future<TweetModel> getTweetById(String id) async {
    final document = await _tweetApi.getTweetById(id);
    return TweetModel.fromMap(document.data);
  }

  Future<List<TweetModel>> getTweetsByHashtag(String hashtag) async {
    final documents = await _tweetApi.getTweetsByHashtag(hashtag);
    return documents.map((tweet) => TweetModel.fromMap(tweet.data)).toList();
  }
}

// -----------------------------------------------------------------------------

final tweetControllerProvider =
    StateNotifierProvider<TweetControllerNotifier, bool>((ref) {
  final tweetApi = ref.watch(tweetApiProvider);
  final storageApi = ref.watch(storageApiProvider);
  final notificationControllerNotifier =
      ref.watch(notificationControllerProvider.notifier);
  return TweetControllerNotifier(
    ref: ref,
    tweetApi: tweetApi,
    storageApi: storageApi,
    notificationControllerNotifier: notificationControllerNotifier,
  );
});

final getTweetsProvider = FutureProvider((ref) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getLatestTweetProvider = StreamProvider.autoDispose((ref) {
  final tweetApi = ref.watch(tweetApiProvider);
  return tweetApi.getLatestTweet();
});

final getTweetRepliesProvider =
    FutureProvider.family((ref, TweetModel tweet) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetReplies(tweet);
});

final getTweetByIdProvider = FutureProvider.family((ref, String id) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
});

final getTweetByHashtagProvider =
    FutureProvider.family((ref, String hashtag) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetsByHashtag(hashtag);
});
