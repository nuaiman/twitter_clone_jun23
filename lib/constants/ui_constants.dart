import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../features/explore/view/explore_view.dart';
import '../features/notifications/view/notification_view.dart';
import '../features/tweet/widgets/tweet_list.dart';
import '../theme/pallete.dart';
import 'assets_constants.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        colorFilter:
            const ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
        height: 30,
      ),
      centerTitle: true,
    );
  }

  static const List<Widget> bottomTabBarPages = [
    TweetList(),
    ExploreView(),
    NotificationsView(),
  ];
}
