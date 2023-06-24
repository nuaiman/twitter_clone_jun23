import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../constants/appwrite_constants.dart';
import '../core/failure.dart';
import '../core/providers.dart';
import '../core/type_defs.dart';
import '../models/user_model.dart';

abstract class IUserApi {
  FutureEitherVoid saveUserData(UserModel userModel);
  Future<Document> getUserDetails(String uid);
  Future<List<Document>> searchUserByName(String name);
  FutureEitherVoid updateUserData(UserModel userModel);
  Stream<RealtimeMessage> getLatestProfileData();
  FutureEitherVoid followUser(UserModel user);
  FutureEitherVoid addToFollowing(UserModel currentUser);
}

// -----------------------------------------------------------------------------

class UserApi implements IUserApi {
  final Databases _db;
  final Realtime _realtime;
  UserApi({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
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
  Future<Document> getUserDetails(String uid) async {
    final document = await _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      documentId: uid,
    );

    return document;
  }

  @override
  Future<List<Document>> searchUserByName(String name) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      queries: [
        Query.search('name', name),
      ],
    );
    return documents.documents;
  }

  @override
  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: userModel.uid,
        data: userModel.toMap(),
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
  Stream<RealtimeMessage> getLatestProfileData() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.usersCollection}.documents'
    ]).stream;
  }

  // @override
  // Stream<RealtimeMessage> getLatestProfileData(String uid) {
  //   return _realtime.subscribe([
  //     'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.usersCollection}.documents.$uid'
  //   ]).stream;
  // }

  @override
  FutureEitherVoid followUser(UserModel user) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: user.uid,
        data: {
          'followers': user.followers,
        },
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
  FutureEitherVoid addToFollowing(UserModel currentUser) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: currentUser.uid,
        data: {
          'following': currentUser.following,
        },
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
          Failure(e.message ?? 'Some unexpected error occured!', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}

// -----------------------------------------------------------------------------

final userApiProvider = Provider((ref) {
  final db = ref.watch(appwriteDatabaseProvider);
  final realTime = ref.watch(appwriteRealtimeProvider);
  return UserApi(db: db, realtime: realTime);
});
