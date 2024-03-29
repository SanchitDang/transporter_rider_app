import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;
import 'package:transporter_rider_app/config/maps_api_key.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/data_sources/uber_map_data_source.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/generate_trip_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/rental_charges_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/uber_map_direction_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/uber_map_drivers_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/uber_map_prediction_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/vehicle_details_model.dart';

class UberMapDataSourceImpl extends UberMapDataSource {
  final http.Client client;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  static const baseUrl = 'maps.googleapis.com';

  UberMapDataSourceImpl(
      {required this.auth, required this.firestore, required this.client});

  //todo, add from admin panel
  List<Map<String, double>> places = [
    {'name': 101, 'latitude': 28.63873688409748, 'longitude': 77.11972520423109},
    {'name': 102, 'latitude': 28.64476311801263, 'longitude': 77.1268920666985},
  ];

  @override
  Future<PredictionsList> getUberMapPrediction(String placeName) async {
    final autoCompleteUrl = Uri.https(
        baseUrl,
        '/maps/api/place/autocomplete/json',
        {'input': placeName, 'types': 'geocode', 'key': apiKey});
    final response = await client.get(
      autoCompleteUrl,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return PredictionsList.fromJson(json.decode(response.body));
    } else {
      throw Exception();
    }
  }

  @override
  Future<Direction> getUberMapDirection(double sourceLat, double sourceLng,
      double destinationLat, double destinationLng) async {
    final directionUrl = Uri.https(baseUrl, '/maps/api/directions/json', {
      'origin': "$sourceLat,$sourceLng",
      'destination': "$destinationLat, $destinationLng",
      'key': apiKey
    });
    final response = await client.get(
      directionUrl,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Direction.fromJson(json.decode(response.body));
    } else {
      throw Exception();
    }
  }

  @override
  Stream<List<DriverModel>> getAvailableDrivers() {
    final driverCollectionRef =
        firestore.collection("drivers").where('is_online', isEqualTo: true);
    //.where('city', isEqualTo: sourcePlaceName);

    return driverCollectionRef.snapshots().map((querySnap) {
      return querySnap.docs
          .map((docSnap) => DriverModel.fromSnapshot(docSnap))
          .toList();
    });
  }

  @override
  Future<RentalChargeModel> getRentalChargeForVehicle(double kms) async {
    final pricesCollection = firestore.collection("prices");
    DocumentSnapshot charges = await pricesCollection.doc("vehicles").get();
    //fetch per km charge from prices collection and multiply by kms
    final double rickShawRent = kms * charges.get("auto_rickshaw");
    final double carRent = kms * charges.get("car");
    final double bikeRent = kms * charges.get("bike");

    final vehicleRent = RentalChargeModel(
        auto_rickshaw: rickShawRent, car: carRent, bike: bikeRent);
    // print(vehicleRent.car);
    return vehicleRent;
  }

  @override
  Stream generateTrip(GenerateTripModel generateTripModel) {

    final genarateTripCollection = firestore.collection("trips");
    genarateTripCollection.doc(generateTripModel.tripId).set({
      //isArrived
      'trip_id': generateTripModel.tripId,
      'destination': generateTripModel.destination,
      'destination_location': generateTripModel.destinationLocation,
      'distance': generateTripModel.distance,
      'driver_id': generateTripModel.driverId,
      'is_completed': generateTripModel.isCompleted,
      'trip_date': generateTripModel.tripDate,
      'rating': generateTripModel.rating,
      'rider_id': generateTripModel.riderId,
      'source': generateTripModel.source,
      'source_location': generateTripModel.sourceLocation,
      'travelling_time': generateTripModel.travellingTime,
      'ready_for_trip': generateTripModel.readyForTrip,
      'trip_amount': generateTripModel.tripAmount,
      'is_arrived': generateTripModel.isArrived,
      'is_payment_done': generateTripModel.isPaymentDone,
      //for our flow
      'warehouse_source_location': GeoPoint(0.0, 0.0),
      'sending_warehouse_source': false,
      'reached_warehouse_source': false,
      'sending_warehouse_destination': false,
      'reached_warehouse_destination': false,
      'out_for_delivery': false,
      'delivered': false,
      'is_from_admin': false,
    });

    //find nearest warehouse enar source location so that driver can drop there
    findNearestPlace(generateTripModel, places).then((nearestPlace) {

      GeoPoint nearestPlaceGeoPoint = const GeoPoint(0.0, 0.0);
      nearestPlaceGeoPoint = GeoPoint(nearestPlace['latitude'], nearestPlace['longitude']);

      final genarateTripCollection = firestore.collection("trips");
      genarateTripCollection.doc(generateTripModel.tripId).set({
        'warehouse_source_location': nearestPlaceGeoPoint,
      },
          SetOptions(merge: true)
      );

    });

    // todo when driver is accept payment button on driver app is clicked
    // then show dialog box
    // if out_for_delivery == true
    //      destination_location GMAPS
    // else
    //      warehouse_source_location GMAPS

    return genarateTripCollection.doc(generateTripModel.tripId).snapshots();
  }

  @override
  Future<VehicleModel> getVehicleDetails(
      String vehicleType, String driverId) async {
    final vehicleCollectionRef = firestore.collection(vehicleType);

    return vehicleCollectionRef
        .doc(driverId)
        .get()
        .then((value) => VehicleModel.fromMap(value.data()));
  }

  @override
  Future<void> cancelTrip(String tripId, bool isNewTripGeneration) async {
    try {
      final genarateTripCollection = firestore.collection("trips");
      if (!isNewTripGeneration) {
        await genarateTripCollection.doc(tripId).update({'driver_id': null});
      } else {
        await genarateTripCollection.doc(tripId).get().then((value) async {
          if (value.data()!['ready_for_trip'] == false) {
            await genarateTripCollection.doc(tripId).delete();
          }
        });
      }
    } on FirebaseException catch (e) {
      Get.snackbar("Error", e.code.toString());
    }
  }

  @override
  Future<String> tripPayment(String riderId, String driverId, int tripAmount,
      String tripId, String payMode) async {
    var res = "".obs;
    var riderAmt = 0.obs;
    var driverAmt = 0.obs;
    if (payMode == "wallet") {
      await firestore.collection("riders").doc(riderId).get().then((value) {
        riderAmt.value = value.get('wallet');
      }).whenComplete(() async {
        await firestore.collection("drivers").doc(driverId).get().then((value) {
          driverAmt.value = value.get('wallet').round();
        });
      }).whenComplete(() async {
        if (riderAmt.value < tripAmount) {
          res.value = "low_balance";
        } else {
          await firestore.collection("riders").doc(riderId).update(
              {'wallet': riderAmt.value - tripAmount}).whenComplete(() async {
            await firestore
                .collection("drivers")
                .doc(driverId)
                .update({'wallet': driverAmt.value + tripAmount}).whenComplete(
                    () async {
              await firestore
                  .collection("trips")
                  .doc(tripId)
                  .update({'is_payment_done': true}).whenComplete(() {
                res.value = "done";
              });
            });
          });
        }
      });
    } else {
      await firestore
          .collection("trips")
          .doc(tripId)
          .update({'is_payment_done': true}).whenComplete(() {
        res.value = "done";
      });
    }
    return Future.value(res.value);
  }

  Future<Map<String, dynamic>> findNearestPlace(GenerateTripModel generateTripModel, List<Map<String, double>> places) async {

    double minDistance = double.infinity;
    Map<String, dynamic>? nearestPlace; // Nullable

    // Loop through places and calculate distances
    for (var place in places) {
      double lat = place['latitude']!;
      double lon = place['longitude']!;
      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${generateTripModel.sourceLocation?.latitude},${generateTripModel.sourceLocation?.longitude}&destination=$lat,$lon&key=$apiKey';
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
        }
      }
    }

    return nearestPlace ?? {}; // Return an empty map if no nearest place found
  }

}


