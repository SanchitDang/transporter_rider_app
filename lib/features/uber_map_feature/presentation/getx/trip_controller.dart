import 'package:get/get.dart';

class TripController extends GetxController {

  RxString currentTripId = 'xxx'.obs;

  void setCurrentTripId(String id){
    currentTripId.value = id;
  }

  String getCurrentTripId(){
    return currentTripId.value;
  }

}