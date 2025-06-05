import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bloc/location_bloc.dart';
import 'bloc/location_event.dart';
import 'bloc/location_state.dart';
import 'models/location_model.dart';
import 'repositories/location_repository.dart';
import 'services/location_service.dart';
import 'screens/map_view_screen.dart';
import 'adapters/lat_lng_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(LocationModelAdapter());
  Hive.registerAdapter(LatLngAdapter());
  
  await Hive.openBox<LocationModel>('locations');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => LocationBloc(
          LocationService(),
          LocationRepository(Hive.box<LocationModel>('locations')),
        ),
        child: const LocationTrackerScreen(),
      ),
    );
  }
}

class LocationTrackerScreen extends StatelessWidget {
  const LocationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationInitial) {
            final locationHistory = context.read<LocationBloc>().getLocationHistory();
            if (locationHistory.isEmpty) {
              return const Center(child: Text('Press start to begin tracking'));
            }
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tracking History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: locationHistory.length,
                    itemBuilder: (context, index) {
                      final tracking = locationHistory[index];
                      return Dismissible(
                        key: Key(tracking.sessionId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          // Delete the tracking session
                          context.read<LocationBloc>().add(DeleteTrackingSession(tracking.sessionId));
                          // Show undo snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tracking session deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  context.read<LocationBloc>().add(RestoreTrackingSession(tracking));
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              'Tracking Session ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Date: ${tracking.timestamp.toString().split('.')[0]}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Show tracking details
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return Dialog(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Tracking Details',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text('Start Time: ${tracking.timestamp.toString().split('.')[0]}'),
                                          const SizedBox(height: 8),
                                          Text('Path Points: ${tracking.pathPoints.length}'),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => MapViewScreen(
                                                    tracking: tracking,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('View on Map'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is LocationError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is LocationLoaded) {
            // print('Rendering map with ${state.pathPoints.length} path points'); // Debug print
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(state.latitude, state.longitude),
                zoom: 15,
              ),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(state.latitude, state.longitude),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('tracking_path'),
                  points: state.pathPoints,
                  color: Colors.blue,
                  width: 5,
                  patterns: [PatternItem.dash(10), PatternItem.gap(10)],
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                // print('Map created with ${state.pathPoints.length} path points'); // Debug print
              },
            );
          }
          
          return const SizedBox();
        },
      ),
      floatingActionButton: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () {
              if (state is LocationInitial || state is LocationError) {
                context.read<LocationBloc>().add(StartTracking());
              } else {
                // Show confirmation dialog before stopping
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return Builder(
                      builder: (BuildContext builderContext) {
                        return AlertDialog(
                          title: const Text('Stop Tracking'),
                          content: const Text('Are you sure you want to stop tracking?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Close dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Close dialog
                                context.read<LocationBloc>().add(StopTracking());
                                // Show success message and navigate back
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tracking stopped'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                // Navigate back to list screen
                                context.read<LocationBloc>().add(ResetToInitial());
                              },
                              child: const Text('Stop'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
            child: Icon(
              state is LocationLoaded ? Icons.stop : Icons.play_arrow,
            ),
          );
        },
      ),
    );
  }
}
