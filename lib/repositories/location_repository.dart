import 'package:hive/hive.dart';
import '../models/location_model.dart';

class LocationRepository {
  final Box<LocationModel> _box;
  String? _currentSessionId;

  LocationRepository(this._box);

  Future<void> saveLocation(LocationModel location) async {
    await _box.add(location);
  }

  List<LocationModel> getLocationHistory() {
    final allLocations = _box.values.toList();
    // Group by session ID and get the first location of each session
    final Map<String, LocationModel> sessions = {};
    for (var location in allLocations) {
      if (!sessions.containsKey(location.sessionId)) {
        sessions[location.sessionId] = location;
      }
    }
    return sessions.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> clearCurrentTracking() async {
    _currentSessionId = null;
  }

  Future<void> deleteTrackingSession(String sessionId) async {
    final locations = _box.values.where((loc) => loc.sessionId == sessionId).toList();
    for (var location in locations) {
      await location.delete();
    }
  }

  Future<void> restoreTrackingSession(LocationModel tracking) async {
    await _box.add(tracking);
  }

  String getCurrentSessionId() {
    _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return _currentSessionId!;
  }
}
