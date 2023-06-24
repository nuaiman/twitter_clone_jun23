import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/enum/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/view/tweet_reply_view.dart';
import 'package:twitter_clone/features/tweet/widgets/hashtag_text.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card_carousel_image.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card_icon_button.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../common/error_page.dart';
import '../../../common/loading_page.dart';

class TweetCard extends ConsumerWidget {
  const TweetCard({
    super.key,
    required this.tweetModel,
  });

  final TweetModel tweetModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : ref.watch(getUserDetailsProvider(tweetModel.uid)).when(
              data: (user) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(UserProfileView.route(user));
                            },
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Pallete.whiteColor,
                              backgroundImage: NetworkImage(user.profilePic),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tweetModel.retweetedBy.isNotEmpty)
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsConstants.retweetIcon,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                          Pallete.greyColor, BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${tweetModel.retweetedBy} retweeted',
                                      style: const TextStyle(
                                        color: Pallete.greyColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: user.isTwitterBlue ? 1 : 5),
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ),
                                  if (user.isTwitterBlue)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SvgPicture.asset(
                                          AssetsConstants.verifiedIcon),
                                    ),
                                  Text(
                                    '@${user.name} . ${timeago.format(tweetModel.tweetedAt, locale: 'en_short').replaceAll('~', '')}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Pallete.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              if (tweetModel.repliedTo.isNotEmpty)
                                ref
                                    .watch(getTweetByIdProvider(
                                        tweetModel.repliedTo))
                                    .when(
                                      data: (repliedToTweet) {
                                        final replyingToUser = ref
                                            .watch(getUserDetailsProvider(
                                                repliedToTweet.uid))
                                            .value;
                                        return RichText(
                                          text: TextSpan(
                                            text: 'replied to ',
                                            style: TextStyle(
                                              color: Pallete.greyColor,
                                              fontSize: 16,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '@${replyingToUser?.name}',
                                                style: TextStyle(
                                                  color: Pallete.blueColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const SizedBox(),
                                    ),
                              const SizedBox(height: 5),
                              HashtagText(text: tweetModel.text),
                              if (tweetModel.tweetType == TweetType.image)
                                TweetCardCarouselImages(
                                  imageLinks: tweetModel.imageLinks,
                                ),
                              if (tweetModel.link.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: 'https://${tweetModel.link}',
                                ),
                              ],
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 5, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TweetCardIconButton(
                                      pathName: AssetsConstants.viewsIcon,
                                      text: (tweetModel.commentIds.length +
                                              tweetModel.reshareCount +
                                              tweetModel.likes.length)
                                          .toString(),
                                      ontap: () {},
                                    ),
                                    TweetCardIconButton(
                                      pathName: AssetsConstants.commentIcon,
                                      text: (tweetModel.commentIds.length)
                                          .toString(),
                                      ontap: () {
                                        Navigator.of(context).push(
                                            TweetReplyView.route(tweetModel));
                                      },
                                    ),
                                    TweetCardIconButton(
                                      pathName: AssetsConstants.retweetIcon,
                                      text:
                                          (tweetModel.reshareCount).toString(),
                                      ontap: () {},
                                    ),
                                    LikeButton(
                                      size: 25,
                                      onTap: (isLiked) async {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .likeTweet(tweetModel, currentUser);

                                        return !isLiked;
                                      },
                                      isLiked: tweetModel.likes
                                          .contains(currentUser.uid),
                                      likeBuilder: (isLiked) {
                                        return isLiked
                                            ? SvgPicture.asset(
                                                AssetsConstants.likeFilledIcon,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        Pallete.redColor,
                                                        BlendMode.srcIn),
                                              )
                                            : SvgPicture.asset(
                                                AssetsConstants
                                                    .likeOutlinedIcon,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        Pallete.greyColor,
                                                        BlendMode.srcIn),
                                              );
                                      },
                                      likeCount: tweetModel.likes.length,
                                      countBuilder: (likeCount, isLiked, text) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: isLiked
                                                  ? Pallete.redColor
                                                  : Pallete.whiteColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // TweetCardIconButton(
                                    //   pathName: AssetsConstants.likeOutlinedIcon,
                                    //   text: (tweetModel.likes.length).toString(),
                                    //   ontap: () {},
                                    // ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .reshareTweet(
                                              context,
                                              tweetModel,
                                              currentUser,
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            );
  }
}
