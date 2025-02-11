import 'package:transporter_rider_app/features/uber_map_feature/data/models/generate_trip_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/rental_charges_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/data/models/vehicle_details_model.dart';
import 'package:transporter_rider_app/features/uber_map_feature/domain/entities/uber_map_direction_entity.dart';
import 'package:transporter_rider_app/features/uber_map_feature/domain/entities/uber_map_get_drivers_entity.dart';
import 'package:transporter_rider_app/features/uber_map_feature/domain/entities/uber_map_prediction_entity.dart';

abstract class UberMapRepository {
  Future<List<UberMapPredictionEntity>> getUberMapPrediction(String placeName);

  Future<List<UberMapDirectionEntity>> getUberMapDirection(double sourceLat,
      double sourceLng, double destinationLat, double destinationLng);

  Stream<List<UberDriverEntity>> getAvailableDrivers();

  Future<RentalChargeModel> getRentalChargeForVehicle(double kms);

  Stream generateTrip(GenerateTripModel generateTripModel);

  Future<VehicleModel> getVehicleDetails(String vehicleType, String driverId);

  Future<void> cancelTrip(String tripId, bool isNewTripGeneration);

  Future<String> tripPayment(String riderId, String driverId, int tripAmount,
      String tripId, String payMode);
}
