import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final List<LocationModel> locationHistory;
  final List<LatLng> pathPoints;

  LocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.locationHistory,
    required this.pathPoints,
  });
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}
