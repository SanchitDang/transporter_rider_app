import 'package:get/get.dart';

class TripController extends GetxController {

  RxString currentTripId = 'xxx'.obs;
  RxInt numberOfGoods = 0.obs;

  void setCurrentTripId(String id){
    currentTripId.value = id;
  }

  String getCurrentTripId(){
    return currentTripId.value;
  }

  void setNumberOfGoods(int val){
    numberOfGoods.value = val;
    print(numberOfGoods.value);
  }

  int getNumberOfGoods(){
    return numberOfGoods.value;
  }

}