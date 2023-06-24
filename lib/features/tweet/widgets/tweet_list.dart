import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

import '../../../constants/appwrite_constants.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    if (data.events.contains(
                        'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create')) {
                      tweets.add(TweetModel.fromMap(data.payload));
                    } else if (data.events.contains(
                        'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update')) {
                      final startingPoint =
                          data.events[0].lastIndexOf('documents.');
                      final endingPoint = data.events[0].lastIndexOf('.update');
                      final tweetId = data.events[0]
                          .substring(startingPoint + 10, endingPoint);
                      var tweet = tweets
                          .where((element) => element.id == tweetId)
                          .first;
                      final tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweetId);
                      tweet = TweetModel.fromMap(data.payload);
                      tweets.insert(tweetIndex, tweet);
                    }

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
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () {
                    return ListView.separated(
                      // reverse: true,
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
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
