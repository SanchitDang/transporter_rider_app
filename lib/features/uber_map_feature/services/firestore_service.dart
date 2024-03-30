import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _tripsCollection =
  FirebaseFirestore.instance.collection('trips');

  Future<void> uploadToFirebase(String tripId, File image) async {
    try {
      // Upload image to Firebase Storage
      final firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('trips')
          .child(tripId)
          .child('image.jpg'); // Change 'image.jpg' to desired file name

      await storageRef.putFile(image);

      // Get download URL
      final imageUrl = await storageRef.getDownloadURL();

      // Update Firestore with image URL
      await _tripsCollection.doc(tripId).update({
        'good_picture': imageUrl,
      });
    } catch (e) {
      throw Exception("Failed to upload image to Firebase: $e");
    }
  }

  Future<void> openImagePickerBottomSheet(BuildContext context, String tripId) async {
    final ImagePicker _picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.getImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  File image = File(pickedFile.path);
                  await uploadToFirebase(tripId, image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.getImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  File image = File(pickedFile.path);
                  await uploadToFirebase(tripId, image);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
