import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';

class MapViewScreen extends StatelessWidget {
  final LocationModel tracking;

  const MapViewScreen({
    super.key,
    required this.tracking,
  });

  @override
  Widget build(BuildContext context) {
    if (tracking.pathPoints.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tracking Path'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('No path points available for this tracking session'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Path'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(tracking.latitude, tracking.longitude),
          zoom: 15,
        ),
        zoomControlsEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {
          if (tracking.pathPoints.isNotEmpty) ...[
            Marker(
              markerId: const MarkerId('start_point'),
              position: tracking.pathPoints.first,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(title: 'Start Point'),
            ),
            Marker(
              markerId: const MarkerId('end_point'),
              position: tracking.pathPoints.last,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'End Point'),
            ),
          ],
        },
        polylines: {
          if (tracking.pathPoints.isNotEmpty)
            Polyline(
              polylineId: const PolylineId('tracking_path'),
              points: tracking.pathPoints,
              color: Colors.blue,
              width: 5,
              patterns: [PatternItem.dash(10), PatternItem.gap(10)],
            ),
        },
      ),
    );
  }
} 