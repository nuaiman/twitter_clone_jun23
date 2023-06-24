import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';

import '../../../common/error_page.dart';
import '../../../common/loading_page.dart';
import '../../../theme/pallete.dart';
import '../widgets/tweet_card.dart';

class HashtagView extends ConsumerWidget {
  static route(String hashtag) => MaterialPageRoute(
        builder: (context) => HashtagView(hashtag: hashtag),
      );
  const HashtagView({super.key, required this.hashtag});

  final String hashtag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hashtag),
        centerTitle: true,
      ),
      body: ref.watch(getTweetByHashtagProvider(hashtag)).when(
            data: (tweets) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  thickness: 0.2,
                  color: Pallete.greyColor,
                ),
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  final tweet = tweets[index];
                  return TweetCard(
                    tweetModel: tweet,
                  );
                },
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
