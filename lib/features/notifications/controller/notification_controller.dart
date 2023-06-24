import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/notification_api.dart';
import 'package:twitter_clone/core/enum/notification_type_enum.dart';
import 'package:twitter_clone/models/notification_model.dart';

class NotificationControllerNotifier extends StateNotifier<bool> {
  final NotificationApi _notificationApi;
  NotificationControllerNotifier({required NotificationApi notificationApi})
      : _notificationApi = notificationApi,
        super(false);

  void createNotification(
      {required String text,
      required String postId,
      required String uid,
      required NotificationType notificationType}) async {
    final notification = NotificationModel(
      text: text,
      postId: postId,
      id: '',
      uid: uid,
      notificationType: notificationType,
    );
    final result = await _notificationApi.createNotification(notification);
    result.fold((l) => null, (r) => null);
  }

  Future<List<NotificationModel>> getNotification(String uid) async {
    final notifications = await _notificationApi.getNotifications(uid);
    return notifications.map((e) => NotificationModel.fromMap(e.data)).toList();
  }
}

// -----------------------------------------------------------------------------

final notificationControllerProvider =
    StateNotifierProvider<NotificationControllerNotifier, bool>((ref) {
  final notificationApi = ref.watch(notificationApiProvider);
  return NotificationControllerNotifier(notificationApi: notificationApi);
});

// final notificationControllerProvider = Provider((ref) {
//   final notificationApi = ref.watch(notificationApiProvider);
//   return NotificationControllerNotifier(notificationApi: notificationApi);
// });

final latestNotificationProvider = StreamProvider((ref) {
  final notificationApi = ref.watch(notificationApiProvider);
  return notificationApi.getLatestNotification();
});

final getNotificationsProvider = FutureProvider.family((ref, String uid) async {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return notificationController.getNotification(uid);
});
