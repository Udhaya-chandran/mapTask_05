import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';
import '../repositories/location_repository.dart';
import '../services/location_service.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final LocationRepository _locationRepository;
  StreamSubscription<Position>? _locationSubscription;

  LocationBloc(this._locationService, this._locationRepository)
      : super(LocationInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<UpdateLocation>(_onUpdateLocation);
    on<ViewTrackingHistory>(_onViewTrackingHistory);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        emit(LocationError('Location permission denied'));
        return;
      }

      _locationSubscription = _locationService
          .getLocationStream()
          .listen((Position position) {
        add(UpdateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ));
      });

      emit(LocationLoading());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LocationState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final location = LocationModel(
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: DateTime.now(),
      );

      await _locationRepository.saveLocation(location);
      final history = _locationRepository.getLocationHistory();
      
      // Convert location history to path points
      final pathPoints = history.map((loc) => 
        LatLng(loc.latitude, loc.longitude)
      ).toList();

      emit(LocationLoaded(
        latitude: event.latitude,
        longitude: event.longitude,
        locationHistory: history,
        pathPoints: pathPoints,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  List<LocationModel> getLocationHistory() {
    return _locationRepository.getLocationHistory();
  }

  Future<void> _onViewTrackingHistory(
    ViewTrackingHistory event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final pathPoints = event.tracking.pathPoints;
      if (pathPoints.isNotEmpty) {
        emit(LocationLoaded(
          latitude: pathPoints.first.latitude,
          longitude: pathPoints.first.longitude,
          locationHistory: getLocationHistory(),
          pathPoints: pathPoints,
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
