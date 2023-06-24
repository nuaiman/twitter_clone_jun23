import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/models/notification_model.dart';

import '../../../common/error_page.dart';
import '../../../constants/appwrite_constants.dart';
import '../../../theme/pallete.dart';
import '../../tweet/widgets/tweet_card.dart';
import '../widgets/notification_tile.dart';

class NotificationsView extends ConsumerWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const NotificationsView(),
      );
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uid)).when(
                data: (notifications) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.notificationsCollection}.documents.*.create')) {
                            final latestNotifications =
                                NotificationModel.fromMap(data.payload);
                            if (latestNotifications.uid == currentUser.uid) {
                              notifications.add(latestNotifications);
                            }
                          }

                          return ListView.separated(
                            separatorBuilder: (context, index) => const Divider(
                              thickness: 0.2,
                              color: Pallete.greyColor,
                            ),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return NotificationTile(
                                notification: notification,
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
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return NotificationTile(
                                notification: notification,
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
