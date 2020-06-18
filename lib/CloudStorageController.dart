import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageController {
  final storage = FirebaseStorage.instance;

  Future<String> uploadGroupImage({File image, String name}) async {
    StorageReference ref = storage.ref().child("groups/images/$name");
    StorageUploadTask uploadTask = ref.putFile(image);
    return uploadTask.onComplete.then((snapshot) {
      return snapshot.ref.getDownloadURL()
          .then((value) => value.toString());
    });
  }
}