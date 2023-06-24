import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/common/rounded_small_button.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter_clone/features/user_profile/view/edit_profile_view.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

import '../../../constants/appwrite_constants.dart';
import '../../../constants/assets_constants.dart';
import '../../../models/tweet_model.dart';
import '../../explore/widgets/follow_count.dart';
import '../../tweet/controller/tweet_controller.dart';
import '../../tweet/widgets/tweet_card.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key, required this.userModel});

  final UserModel userModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserDetailsProvider).value;
    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: userModel.bannerPic.isEmpty
                            ? Container(
                                color: Pallete.blueColor,
                              )
                            : Image.network(userModel.bannerPic),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Pallete.whiteColor,
                          backgroundImage: NetworkImage(userModel.profilePic),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: RoundedSmallButton(
                          labeltext: currentUser.uid == userModel.uid
                              ? 'Edit Profile'
                              : currentUser.following.contains(userModel.uid)
                                  ? 'Unfollow'
                                  : 'Follow',
                          onTap: () {
                            if (currentUser.uid == userModel.uid) {
                              Navigator.of(context)
                                  .push(EditProfileView.route());
                            } else {
                              ref
                                  .read(userProfileControllerProvider.notifier)
                                  .followUser(
                                    user: userModel,
                                    context: context,
                                    currentUser: currentUser,
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          userModel.name,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              '@${userModel.name}',
                              style: const TextStyle(
                                  fontSize: 17, color: Pallete.greyColor),
                            ),
                            if (currentUser.isTwitterBlue)
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: SvgPicture.asset(
                                    AssetsConstants.verifiedIcon),
                              ),
                          ],
                        ),
                        Text(
                          userModel.bio,
                          style: const TextStyle(
                              fontSize: 17, color: Pallete.greyColor),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            FollowCount(
                              count: userModel.following.length,
                              text: 'Following',
                            ),
                            const SizedBox(width: 15),
                            FollowCount(
                              count: userModel.followers.length,
                              text: 'Followers',
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Divider(
                          color: Pallete.whiteColor,
                          thickness: 0.3,
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: ref.watch(userTweetProvider(userModel.uid)).when(
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

                            return ListView.separated(
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
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return ListView.separated(
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
                            );
                          },
                        );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          );
  }
}
