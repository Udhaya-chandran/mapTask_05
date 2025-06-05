# Location Tracking App

A Flutter-based location tracking application that allows users to track their movement, view tracking history, and visualize paths on a map. The app uses modern architecture patterns and several key technologies to provide a robust location tracking experience.

## Key Technologies Used

### 1. Core Framework and Architecture
- **Flutter**: The main framework used for cross-platform mobile development
- **BLoC Pattern**: Implemented using `flutter_bloc` for state management
- **Hive**: Used for local data persistence and storage
- **Google Maps**: Integrated for map visualization and path tracking

### 2. Main Dependencies
- `flutter_bloc` (^8.1.4): For state management
- `hive` (^2.2.3) & `hive_flutter` (^1.1.0): For local database storage
- `geolocator` (^11.0.0): For location services
- `google_maps_flutter` (^2.5.3): For map integration
- `permission_handler` (^11.3.0): For handling device permissions

### 3. Project Structure
The project follows a clean architecture pattern with the following directory structure:
```
lib/
├── adapters/      # Hive adapters for data models
├── bloc/          # Business Logic Components
├── models/        # Data models
├── repositories/  # Data repositories
├── screens/       # UI screens
├── services/      # Core services
└── main.dart      # Application entry point
```

## Key Features

1. **Location Tracking**
   - Real-time location tracking
   - Path visualization on Google Maps
   - Distance calculation
   - Speed monitoring

2. **History Management**
   - Tracking session history
   - Swipe-to-delete functionality
   - Persistent storage using Hive

3. **Map Integration**
   - Google Maps integration
   - Path visualization
   - Current location tracking
   - Map controls and interactions

4. **Data Persistence**
   - Local storage using Hive
   - Tracking session history
   - User preferences

## Technical Implementation Details

### State Management
- Uses BLoC pattern for managing application state
- Separate blocs for tracking and history management
- Event-driven architecture for handling user interactions

### Data Storage
- Hive database for local storage
- Custom adapters for data serialization
- Efficient data models for tracking information

### Location Services
- Geolocator for accessing device location
- Background location tracking
- Permission handling for location access

### UI Components
- Material Design implementation
- Custom widgets for tracking interface
- Interactive map controls
- History list with swipe actions

## Development Tools
- Flutter SDK (^3.8.0)
- Development dependencies:
  - `build_runner` for code generation
  - `hive_generator` for Hive adapters
  - `flutter_lints` for code quality

## Platform Support
The application is configured to support multiple platforms:
- Android
- iOS
- Web
- Windows
- Linux
- macOS

## Security and Permissions
- Location permission handling
- Secure data storage
- Permission request management

## Future Considerations
1. Background tracking optimization
2. Enhanced data visualization
3. Export/import functionality
4. Cloud synchronization
5. Additional map features

## Getting Started

1. Clone the repository
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Contributing
Feel free to submit issues and enhancement requests!
