import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DetailsController extends GetxController {
  RxList<Map<String, dynamic>> goodsList = RxList<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    addGood();
  }

  void addGood() {
    final dimensionController = TextEditingController();
    final weightController = TextEditingController();
    final imageFilePath = Rx<String>("");
    const imageFileUrl = "";
    final newGood = {
      'dimension': dimensionController,
      'weight': weightController,
      'imageFilePath': imageFilePath,
      'imageFileUrl': imageFileUrl,
    };
    goodsList.add(newGood);
    update();
  }

  void done() {
    print(getAllGoodsDetails());
  }

  List<Map<String, dynamic>> getAllGoodsDetails() {
    List<Map<String, dynamic>> allGoodsDetails = [];
    for (int i = 0; i < goodsList.length; i++) {
      allGoodsDetails.add(getGoodDetails(i));
    }
    return allGoodsDetails;
  }

  Map<String, dynamic> getGoodDetails(int index) {
    final dimensionController =
        goodsList[index]['dimension'] as TextEditingController?;
    final weightController =
        goodsList[index]['weight'] as TextEditingController?;
    final imageFileUrl = goodsList[index]['imageFileUrl'];

    return {
      'dimension': dimensionController?.text ?? '',
      'weight': weightController?.text ?? '',
      'imageFileUrl': imageFileUrl,
    };
  }

  Future<void> pickImage(int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);
      String imageUrl = await uploadImgToFirebase(imageFile);
      goodsList[index]['imageFilePath'].value = pickedImage.path;
      goodsList[index]['imageFileUrl'] = imageUrl;
      update();
    }
  }

  Future<String> uploadImgToFirebase(File image) async {
    try {
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('trips')
          .child('goods_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(image);

      final imageUrl = await storageRef.getDownloadURL();
      print('file url -------------->');
      return imageUrl;
    } catch (e) {
      throw Exception("Failed to upload image to Firebase: $e");
    }
  }

  int getNumberOfGoods() {
    return goodsList.length;
  }
}
