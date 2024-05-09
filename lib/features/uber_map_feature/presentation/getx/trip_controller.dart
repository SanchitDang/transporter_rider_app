import 'package:get/get.dart';

class TripController extends GetxController {

  RxString currentTripId = 'xxx'.obs;
  RxInt price = 1.obs;

  void setCurrentTripId(String id){
    currentTripId.value = id;
  }

  String getCurrentTripId(){
    return currentTripId.value;
  }

  void setPrice(int _price){
    price.value = _price;
  }

  int getPrice(){
    return price.value;
  }
}