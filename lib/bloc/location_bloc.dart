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
  String? _currentSessionId;
  List<LatLng> _currentPathPoints = [];

  LocationBloc(this._locationService, this._locationRepository)
      : super(LocationInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<UpdateLocation>(_onUpdateLocation);
    on<ViewTrackingHistory>(_onViewTrackingHistory);
    on<ResetToInitial>(_onResetToInitial);
    on<DeleteTrackingSession>(_onDeleteTrackingSession);
    on<RestoreTrackingSession>(_onRestoreTrackingSession);
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

      // Initialize new tracking session
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentPathPoints = [];

      // Get initial position
      final initialPosition = await _locationService.getCurrentLocation();
      _currentPathPoints.add(LatLng(initialPosition.latitude, initialPosition.longitude));

      // Save initial location
      final initialLocation = LocationModel(
        latitude: initialPosition.latitude,
        longitude: initialPosition.longitude,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId!,
        pathPoints: _currentPathPoints,
      );
      await _locationRepository.saveLocation(initialLocation);

      _locationSubscription = _locationService
          .getLocationStream()
          .listen((Position position) {
        add(UpdateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ));
      });

      emit(LocationLoaded(
        latitude: initialPosition.latitude,
        longitude: initialPosition.longitude,
        locationHistory: _locationRepository.getLocationHistory(),
        pathPoints: _currentPathPoints,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      
      // Save final location with complete path
      if (_currentSessionId != null) {
        final currentLocation = await _locationService.getCurrentLocation();
        final finalLocation = LocationModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          timestamp: DateTime.now(),
          sessionId: _currentSessionId!,
          pathPoints: _currentPathPoints,
        );
        await _locationRepository.saveLocation(finalLocation);
      }

      _currentSessionId = null;
      _currentPathPoints = [];
      
      emit(LocationInitial());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (_currentSessionId == null) return;

      // Add new point to current path
      _currentPathPoints.add(LatLng(event.latitude, event.longitude));

      // Save location with updated path
      final location = LocationModel(
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId!,
        pathPoints: _currentPathPoints,
      );

      await _locationRepository.saveLocation(location);

      emit(LocationLoaded(
        latitude: event.latitude,
        longitude: event.longitude,
        locationHistory: _locationRepository.getLocationHistory(),
        pathPoints: _currentPathPoints,
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

  void _onResetToInitial(ResetToInitial event, Emitter<LocationState> emit) {
    emit(LocationInitial());
  }

  Future<void> _onDeleteTrackingSession(
    DeleteTrackingSession event,
    Emitter<LocationState> emit,
  ) async {
    await _locationRepository.deleteTrackingSession(event.sessionId);
    emit(LocationInitial());
  }

  Future<void> _onRestoreTrackingSession(
    RestoreTrackingSession event,
    Emitter<LocationState> emit,
  ) async {
    await _locationRepository.restoreTrackingSession(event.tracking);
    emit(LocationInitial());
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
