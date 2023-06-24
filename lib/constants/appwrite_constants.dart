class AppwriteConstants {
  static const String projectId = '';
  static const String databaseId = '';
  static const String endPoint = '';

  static const String usersCollection = '';
  static const String tweetsCollection = '';
  static const String notificationsCollection = '';

  static const String imagesBucket = '';

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
