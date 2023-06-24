import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter_clone/constants/assets_constants.dart';
import 'package:twitter_clone/core/enum/notification_type_enum.dart';
import 'package:twitter_clone/models/notification_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: notification.notificationType == NotificationType.follow
          ? const Icon(
              Icons.person,
              color: Pallete.blueColor,
            )
          : notification.notificationType == NotificationType.like
              ? SvgPicture.asset(
                  AssetsConstants.likeFilledIcon,
                  colorFilter:
                      const ColorFilter.mode(Pallete.redColor, BlendMode.srcIn),
                  height: 20,
                )
              : notification.notificationType == NotificationType.retweet
                  ? SvgPicture.asset(
                      AssetsConstants.likeFilledIcon,
                      colorFilter: const ColorFilter.mode(
                          Pallete.redColor, BlendMode.srcIn),
                      height: 20,
                    )
                  : null,
      title: Text(notification.text),
    );
  }
}
