import 'package:flutter/foundation.dart';
import '../models/location_model.dart';

@immutable
abstract class LocationEvent {}

class StartTracking extends LocationEvent {}

class StopTracking extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final double latitude;
  final double longitude;

  UpdateLocation({required this.latitude, required this.longitude});
}

class ViewTrackingHistory extends LocationEvent {
  final LocationModel tracking;

  ViewTrackingHistory(this.tracking);
}

class ResetToInitial extends LocationEvent {}

class DeleteTrackingSession extends LocationEvent {
  final String sessionId;
  DeleteTrackingSession(this.sessionId);
}

class RestoreTrackingSession extends LocationEvent {
  final LocationModel tracking;
  RestoreTrackingSession(this.tracking);
}
