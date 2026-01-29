import 'dart:io';
import '../services/supabase_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final _client = SupabaseService.instance.client;

  // Upload profile picture
  Future<String> uploadProfilePicture(File file) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileExt = file.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await _client.storage
          .from('profile-pictures')
          .upload(filePath, file);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  // Get profile picture URL (signed URL for private bucket)
  Future<String> getProfilePictureUrl(String filePath) async {
    try {
      final signedUrl = await _client.storage
          .from('profile-pictures')
          .createSignedUrl(filePath, 3600); // 1 hour expiry
      return signedUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String filePath) async {
    try {
      await _client.storage.from('profile-pictures').remove([filePath]);
    } catch (e) {
      rethrow;
    }
  }

  // Upload mentor document
  Future<String> uploadMentorDocument(File file) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileExt = file.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await _client.storage
          .from('mentor-documents')
          .upload(filePath, file);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  // Get mentor document URL (signed URL for private bucket)
  Future<String> getMentorDocumentUrl(String filePath) async {
    try {
      final signedUrl = await _client.storage
          .from('mentor-documents')
          .createSignedUrl(filePath, 3600); // 1 hour expiry
      return signedUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Delete mentor document
  Future<void> deleteMentorDocument(String filePath) async {
    try {
      await _client.storage.from('mentor-documents').remove([filePath]);
    } catch (e) {
      rethrow;
    }
  }

  // List user files in a bucket
  Future<List<String>> listUserFiles(String bucketName) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final files = await _client.storage.from(bucketName).list(path: user.id);

      return files.map((file) => file.name).toList();
    } catch (e) {
      rethrow;
    }
  }
}