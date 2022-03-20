import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageClient {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadRecording({
    required String fileName,
    required File audioFile,
  }) async {
    final ref = storage.ref('audio/$fileName');

    try {
      final uploadTask = await ref.putFile(audioFile);

      if (uploadTask.state == TaskState.success) {
        var downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }
    } on FirebaseException catch (e) {
      log(e.message.toString());
    } catch (e) {
      log(e.toString());
    }

    return null;
  }
}
