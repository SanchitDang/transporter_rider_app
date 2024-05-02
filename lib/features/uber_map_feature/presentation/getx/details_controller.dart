import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transporter_rider_app/features/uber_map_feature/presentation/getx/trip_controller.dart';


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
    final newGood = {
      'dimension': dimensionController,
      'weight': weightController,
      'imageFilePath': imageFilePath,
    };
    goodsList.add(newGood);
    update();
  }

  void done(){
  }

  Future<void> pickImage(int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);
      goodsList[index]['imageFilePath'].value = pickedImage.path;
      update();
    }
  }

  int getNumberOfGoods() {
    return goodsList.length;
  }
}
