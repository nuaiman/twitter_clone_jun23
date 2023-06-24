import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

showSnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

String getNameFromEmail(String email) {
  return email.split('@')[0];
}

Future<List<File>> pickImages() async {
  List<File> images = [];
  ImagePicker imagePicker = ImagePicker();
  final pickedImages = await imagePicker.pickMultiImage();

  if (pickedImages.isNotEmpty) {
    for (final image in pickedImages) {
      images.add(File(image.path));
    }
  }

  return images;
}

Future<File?> pickImage() async {
  ImagePicker imagePicker = ImagePicker();
  final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
  if (pickedImage != null) {
    return File(pickedImage.path);
  }
  return null;
}
