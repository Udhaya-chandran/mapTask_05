import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'location_model.g.dart';

@HiveType(typeId: 0)
class LocationModel extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final List<LatLng> pathPoints;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.pathPoints = const [],
  });
}
