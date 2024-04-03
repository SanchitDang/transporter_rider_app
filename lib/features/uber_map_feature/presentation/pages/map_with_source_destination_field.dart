import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transporter_rider_app/features/uber_home_page_feature/presentation/pages/uber_home_page.dart';
import 'package:transporter_rider_app/features/uber_map_feature/presentation/getx/uber_map_controller.dart';
import 'package:transporter_rider_app/features/uber_map_feature/presentation/widgets/map_confirmation_bottomsheet.dart';
import 'package:transporter_rider_app/injection_container.dart' as di;

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../config/maps_api_key.dart';
import '../widgets/WarehouseDialog.dart';

class MapWithSourceDestinationField extends StatefulWidget {
  final CameraPosition defaultCameraPosition;
  final CameraPosition newCameraPosition;

  const MapWithSourceDestinationField(
      {required this.newCameraPosition,
      required this.defaultCameraPosition,
      Key? key})
      : super(key: key);

  @override
  _MapWithSourceDestinationFieldState createState() =>
      _MapWithSourceDestinationFieldState();
}

class _MapWithSourceDestinationFieldState
    extends State<MapWithSourceDestinationField> {
  //final Completer<GoogleMapController> _controller = Completer();

  final sourcePlaceController = TextEditingController();
  final destinationController = TextEditingController();

  final UberMapController _uberMapController =
      Get.put(di.sl<UberMapController>());

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sourcePlaceController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const UberHomePage());
        _uberMapController.subscription.cancel();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Obx(
                () => Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: widget.defaultCameraPosition,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        markers: _uberMapController.markers.value.toSet(),
                        polylines: {
                          Polyline(
                              polylineId: const PolylineId("polyLine"),
                              color: Colors.black,
                              width: 6,
                              jointType: JointType.round,
                              startCap: Cap.roundCap,
                              endCap: Cap.roundCap,
                              geodesic: true,
                              points:
                                  _uberMapController.polylineCoordinates.value),
                          Polyline(
                              polylineId:
                                  const PolylineId("polyLineForAcptDriver"),
                              color: Colors.black,
                              width: 6,
                              jointType: JointType.round,
                              startCap: Cap.roundCap,
                              endCap: Cap.roundCap,
                              geodesic: true,
                              points: _uberMapController
                                  .polylineCoordinatesforacptDriver.value),
                        },
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _uberMapController.controller.complete(controller);
                          controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                  widget.newCameraPosition));
                        },
                      ),
                    ),
                    Visibility(
                      visible:
                          _uberMapController.isReadyToDisplayAvlDriver.value,
                      child: const SizedBox(
                          height: 250, child: MapConfirmationBottomSheet()),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  Obx(
                    () => Visibility(
                      visible: !_uberMapController.isPoliLineDraw.value,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        color: Colors.grey[300],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: GestureDetector(
                                onTap: () {
                                  // _uberMapController.subscription.cancel();
                                  Get.offAll(() => const UberHomePage());
                                  _uberMapController.subscription.cancel();
                                },
                                child: const FaIcon(
                                  FontAwesomeIcons.arrowLeft,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: TextField(
                                onChanged: (val) {
                                  _uberMapController.getPredictions(
                                      val, 'source');
                                },
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter Source Place"),
                                controller: sourcePlaceController
                                  ..text =
                                      _uberMapController.sourcePlaceName.value,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: TextField(
                                onChanged: (val) {
                                  _uberMapController.getPredictions(
                                      val, 'destination');
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter Destination Place",
                                  border: InputBorder.none,
                                ),
                                controller: destinationController
                                  ..text = _uberMapController
                                      .destinationPlaceName.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //if (_uberMapController.uberMapPredictionData.isNotEmpty)
                  Expanded(
                    child: Obx(
                      () => Visibility(
                        visible:
                            _uberMapController.uberMapPredictionData.isNotEmpty,
                        child: Container(
                          color: Colors.white,
                          child: ListView.builder(
                              //shrinkWrap: true,
                              itemCount: _uberMapController
                                  .uberMapPredictionData.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    if (_uberMapController
                                            .predictionListType.value ==
                                        'source') {
                                      _uberMapController
                                          .setPlaceAndGetLocationDeatailsAndDirection(
                                              sourcePlace: _uberMapController
                                                  .uberMapPredictionData[index]
                                                  .mainText
                                                  .toString(),
                                              destinationPlace: "");
                                    } else {
                                      _uberMapController
                                          .setPlaceAndGetLocationDeatailsAndDirection(
                                              sourcePlace: "",
                                              destinationPlace:
                                                  _uberMapController
                                                      .uberMapPredictionData[
                                                          index]
                                                      .mainText
                                                      .toString());
                                    }
                                  },
                                  title: Text(_uberMapController
                                      .uberMapPredictionData[index].mainText
                                      .toString()),
                                  subtitle: Text(_uberMapController
                                      .uberMapPredictionData[index]
                                      .secondaryText
                                      .toString()),
                                  trailing: const Icon(Icons.check),
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.pink),
                            elevation: MaterialStateProperty.all(0.0),
                            padding:
                            MaterialStateProperty.all(const EdgeInsets.all(15))),
                        onPressed: () async {
                          _uberMapController.generateCustomTrip();



                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text("Placed Successful"),
                            ),
                          );

                          // todo :: show dialog to where to drop at where house
                          //todo, add from admin panel
                          List<Map<String, dynamic>> places = [
                            {'name': "XYZ WareHouse", 'latitude': 28.63873688409748, 'longitude': 77.11972520423109},
                            {'name': "PQR WareHouse", 'latitude': 28.64476311801263, 'longitude': 77.1268920666985},
                          ];

                          //find nearest warehouse enar source location so that driver can drop there
                          findNearestPlace(places);

                        },
                        child: const Text(
                          "Drop on your Own",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Visibility(
                visible: _uberMapController.isDriverLoading.value,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Positioned(
                      //bottom: 15,
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: Colors.black,
                      ),
                      Text(
                        "  Loading Rides....",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> findNearestPlace(List<Map<String, dynamic>> places) async {

    double minDistance = double.infinity;
    Map<String, dynamic>? nearestPlace; // Nullable

    // Loop through places and calculate distances
    for (var place in places) {
      double lat = place['latitude']!;
      double lon = place['longitude']!;
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_uberMapController.sourceLatitude.value},${_uberMapController.sourceLongitude.value}&destination=$lat,$lon&key=$apiKey';
      http.Response response = await http.get(Uri.parse(url));
      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        double distance =
            data['routes'][0]['legs'][0]['distance']['value'] / 1000.0; // Distance in kilometers
        if (distance < minDistance) {
          minDistance = distance;
          nearestPlace = {
            'name': place['name'],
            'latitude': lat,
            'longitude': lon,
            'distance': distance,
            'time': data['routes'][0]['legs'][0]['duration']['text']
          };
          print('Nearest Place ---->');
          print(nearestPlace);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WarehouseDialog(
                latitude: lat,
                longitude: lon, // Example longitude
              );
            },
          );

        }
      }
    }

    return nearestPlace ?? {}; // Return an empty map if no nearest place found
  }


}
