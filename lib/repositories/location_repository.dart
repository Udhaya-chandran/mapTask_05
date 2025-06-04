import 'package:hive/hive.dart';
import '../models/location_model.dart';

class LocationRepository {
  final Box<LocationModel> locationBox;

  LocationRepository(this.locationBox);

  Future<void> saveLocation(LocationModel location) async {
    await locationBox.add(location);
  }

  List<LocationModel> getLocationHistory() {
    return locationBox.values.toList();
  }
}
