import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LatLngAdapter extends TypeAdapter<LatLng> {
  @override
  final int typeId = 1;

  @override
  LatLng read(BinaryReader reader) {
    final lat = reader.readDouble();
    final lng = reader.readDouble();
    return LatLng(lat, lng);
  }

  @override
  void write(BinaryWriter writer, LatLng obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
} 