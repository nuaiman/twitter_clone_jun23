import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/core/type_defs.dart';
import 'package:twitter_clone/models/notification_model.dart';

import '../core/failure.dart';

abstract class INotificationAPi {
  FutureEitherVoid createNotification(NotificationModel notification);
  Future<List<Document>> getNotifications(String uid);
  Stream<RealtimeMessage> getLatestNotification();
}

// -----------------------------------------------------------------------------

class NotificationApi implements INotificationAPi {
  final Databases _db;
  final Realtime _realtime;
  NotificationApi({required Databases db, required realTime})
      : _db = db,
        _realtime = realTime;

  @override
  FutureEitherVoid createNotification(NotificationModel notification) async {
    try {
      await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notificationsCollection,
        documentId: ID.unique(),
        data: notification.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? 'Some unexpected error occured!', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<List<Document>> getNotifications(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.notificationsCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestNotification() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.notificationsCollection}.documents'
    ]).stream;
  }
}

// -----------------------------------------------------------------------------

final notificationApiProvider = Provider((ref) {
  final db = ref.watch(appwriteDatabaseProvider);
  final realTime = ref.watch(appwriteRealtimeProvider);
  return NotificationApi(db: db, realTime: realTime);
});
