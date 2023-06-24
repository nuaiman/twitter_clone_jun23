import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

import '../../../common/error_page.dart';
import '../../../common/loading_page.dart';
import '../../../constants/appwrite_constants.dart';
import '../../../theme/pallete.dart';

class TweetReplyView extends ConsumerWidget {
  static route(TweetModel tweet) => MaterialPageRoute(
        builder: (context) => TweetReplyView(tweet: tweet),
      );
  const TweetReplyView({
    super.key,
    required this.tweet,
  });

  final TweetModel tweet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: Column(
        children: [
          Card(child: TweetCard(tweetModel: tweet)),
          ref.watch(getTweetRepliesProvider(tweet)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = TweetModel.fromMap(data.payload);

                          bool isTweetAlreadyPresent = false;
                          for (final tweetMod in tweets) {
                            if (tweetMod.id == latestTweet.id) {
                              isTweetAlreadyPresent = true;
                              break;
                            }
                          }

                          if (!isTweetAlreadyPresent &&
                              latestTweet.repliedTo == tweet.id) {
                            if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create')) {
                              tweets.add(TweetModel.fromMap(data.payload));
                            } else if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update')) {
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endingPoint =
                                  data.events[0].lastIndexOf('.update');
                              final tweetId = data.events[0]
                                  .substring(startingPoint + 10, endingPoint);
                              var tweet = tweets
                                  .where((element) => element.id == tweetId)
                                  .first;
                              final tweetIndex = tweets.indexOf(tweet);
                              tweets.removeWhere(
                                  (element) => element.id == tweetId);
                              tweet = TweetModel.fromMap(data.payload);
                              tweets.insert(tweetIndex, tweet);
                            }
                          }

                          return Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Divider(
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
                            ),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () {
                          return Expanded(
                            child: ListView.separated(
                              // reverse: true,
                              separatorBuilder: (context, index) =>
                                  const Divider(
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
                            ),
                          );
                        },
                      );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
        ],
      ),
      bottomNavigationBar: TextField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        decoration: const InputDecoration(hintText: 'Tweet your reply'),
        onSubmitted: (value) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
                context: context,
                images: [],
                text: value,
                repliedTo: tweet.id,
                repliedToUserId: tweet.uid,
              );
        },
      ),
    );
  }
}
