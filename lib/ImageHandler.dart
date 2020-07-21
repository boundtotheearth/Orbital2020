import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageHandler {
  static Future<File> pickImage() {
    return ImagePicker().getImage(source: ImageSource.gallery)
        .then((pickedFile) {
      File file = File(pickedFile?.path);
      return file;
    });
  }

  static Future<File> cropImage(File file) {
    return ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )).then((croppedFile) {
          return croppedFile ?? null;
    });

  }

  static Future<File> compressImage(File file) {
    return getTemporaryDirectory().then((dir) {
      return dir.absolute.path + "/temp.jpg";
    }).then((targetPath) {
      return FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 88,
      );
    });
  }

  static Future<File> pickCropCompress() {
    return pickImage().then((file) => cropImage(file)).then((croppedFile) => compressImage(croppedFile));
  }
}