# Life Stock Tracking - Project Documentation

## Project Overview

**Project Name:** Life Stock Tracking (Oasis Trace)
**Type:** Mobile Application (Flutter) with Laravel Backend
**Purpose:** Livestock management system for tracking animals, devices, geofences, tasks, and auctions

---

## Project Structure

### Flutter Application
**Location:** `C:\dev\life_stock_tracking`

```
life_stock_tracking/
├── lib/                          # Main Flutter source code
│   ├── main.dart                 # App entry point
│   ├── animals_page.dart         # Animals list, add/edit modals
│   ├── alerts_page.dart          # Alerts management
│   ├── api_service.dart          # API calls to Laravel
│   ├── auth_provider.dart        # Authentication state
│   ├── common_widgets.dart        # Shared widgets
│   ├── dashboard_page.dart        # Main dashboard
│   ├── data_provider.dart        # Data state management
│   ├── login_page.dart           # Login screen
│   ├── map_page.dart             # Map with animals/devices
│   ├── navigation.dart           # Navigation & routing
│   ├── profile_page.dart         # User profile & menu
│   ├── settings_page.dart         # App settings
│   ├── unified_header.dart        # Consistent header component
│   ├── unified_components.dart    # Shared UI components
│   ├── vaccination_page.dart    # Vaccination records
│   ├── medical_records_page.dart # Medical records
│   └── [other pages]             # Various feature pages
├── pubspec.yaml                  # Flutter dependencies
├── android/                      # Android platform files
├── ios/                          # iOS platform files
└── PROGRESS.md                   # Development progress tracker
```

### Laravel Backend
**Location:** `C:\Users\Rami-PC\Downloads\oasis-trace\oasis-trace`

```
oasis-trace/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       ├── AnimalController.php      # Animal CRUD
│   │       ├── DeviceController.php      # Device management
│   │       ├── TaskController.php        # Tasks
│   │       ├── AlertController.php       # Alerts
│   │       └── Api/                      # API Controllers
│   ├── Models/
│   │   ├── Animal.php
│   │   ├── Device.php
│   │   └── [other models]
│   └── Requests/                          # Validation requests
├── routes/
│   └── api.php                           # API routes
├── database/
│   └── database.sqlite                   # SQLite database
└── [Laravel structure]
```

---

## Database

**Database:** SQLite (`oasis-trace-v2`)
**Location:** `C:\Users\Rami-PC\Downloads\oasis-trace\oasis-trace\database\database.sqlite`

### Key Tables:
- **animals** - 35+ animals with fields: id, animal_id, species, breed, gender, color_markings, device_id, identification_photo, etc.
- **devices** - 19 IoT devices for tracking
- **geofences** - 8 geofence zones
- **tasks** - 15 task records
- **users** - 22 user accounts
- **auctions** - 14 auction records
- **alerts** - 30+ alerts

---

## API Endpoints

**Base URL:** `http://localhost:8050/api`

### Animal Endpoints
| Method | Endpoint | Description |
|--------|-----------|--------------|
| GET | `/animals` | List all animals |
| GET | `/animals/{id}` | Get single animal |
| POST | `/animals` | Create new animal |
| PUT | `/animals/{id}` | Update animal |
| DELETE | `/animals/{id}` | Delete animal |

### Device Endpoints
| Method | Endpoint | Description |
|--------|-----------|--------------|
| GET | `/devices` | List all devices |
| POST | `/devices` | Create device |
| PUT | `/devices/{id}` | Update device |

### Other Endpoints
- `/tasks` - Task management
- `/alerts` - Alert management
- `/geofences` - Geofence management
- `/users` - User management
- `/login` - Authentication
- `/map` - Map data

---

## Key Features

### 1. Animals Management
- ✅ View all animals in list/grid
- ✅ Search and filter by species (Camel, Goat, Sheep, Cow, Other)
- ✅ Sort by name, ID, species
- ✅ Add new animal with: name, species, breed, gender, device, color/markings, photo
- ✅ Edit existing animal
- ✅ Delete animal with confirmation
- ✅ View animal details

### 2. Authentication & Roles
- **Login system** with token-based auth
- **Roles:** Admin, Manager, Owner, User
- **Access Control:** Owner/Admin can add/edit animals
- **Session management** via SharedPreferences

### 3. Dashboard
- Quick stats overview
- Quick actions
- Recent activity

### 4. Map View
- Show all animals on map
- Show device locations
- Show geofences

### 5. Other Features
- Alerts management
- Tasks (Pending/Completed/All)
- Auctions
- Team management
- Geofences
- Reports
- Profile with settings

---

## Pages & Navigation

| Page | Route | Description |
|------|-------|--------------|
| Login | `/login` | Authentication |
| Dashboard | `Dashboard` | Main home |
| Map | `Map` | Interactive map |
| Animals | `Animals` | Animal list |
| Alerts | `Alerts` | Alert list |
| Profile | `Profile` | User profile & menu |
| Settings | `Settings` | App settings |
| Tasks | `Tasks` | Task management |
| Auctions | `Auctions` | Auction management |
| Team | `Team` | Team members |
| Devices | `Devices` | Device management |
| Geofences | `Geofences` | Geofence management |
| Reports | `Reports` | Reports & analytics |
| Vaccinations | `Vaccinations` | Vaccination records |
| Medical Records | `MedicalRecords` | Medical history |

---

## Technical Components

### State Management
- **Provider** for state management
- **AuthProvider** - User authentication state
- **DataProvider** - App data (animals, alerts, tasks, etc.)

### API Integration
- **ApiService** - Central API communication class
- Uses `http` package for HTTP requests
- Token-based authentication
- JSON encoding/decoding

### UI Components
- **UnifiedHeader** - Consistent header across pages
- **UnifiedBottomNav** - Bottom navigation bar
- **UnifiedAppBar** - App bar with back button

### Image Handling
- **image_picker** package for camera/gallery
- Base64 encoding for upload
- NetworkImage for display

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0          # State management
  http: ^1.2.0             # HTTP requests
  shared_preferences:      # Local storage
  image_picker: ^1.0.0     # Image selection
  intl: ^0.19.0            # Date formatting
  google_maps_flutter:      # Maps (if used)
  geolocator:              # Location services
```

---

## Running the Application

### Flutter App
```bash
cd C:\dev\life_stock_tracking
flutter pub get
flutter run
```

### Laravel Backend
```bash
cd C:\Users\Rami-PC\Downloads\oasis-trace\oasis-trace
php artisan serve --port=8050
```

### Build APK
```bash
cd C:\dev\life_stock_tracking
flutter build apk --debug
```

---

## Known Issues / Limitations

1. **Edit Image** - Image picker not yet implemented in Edit modal (complex to add)
2. **Pagination** - Basic pagination implemented
3. **Offline Support** - Not implemented

---

## Version History

- **v1.0-working** - Current working state (backup point)
  - All CRUD operations working
  - Back buttons fixed
  - Add animal with image works
  - Edit animal (except image) works

---

## Tester Notes

1. Login with Owner/Admin role to test Add/Edit features
2. Test on physical device or emulator
3. Laravel must be running on port 8050
4. Check database for saved data after create/update
5. Test with various species: Camel, Goat, Sheep, Cow, Other
6. Image upload works in Add Animal modal
7. Back buttons navigate correctly on all pages

---

## Contact & Support

For issues or questions, refer to:
- Flutter code: `C:\dev\life_stock_tracking\lib`
- Laravel code: `C:\Users\Rami-PC\Downloads\oasis-trace\oasis-trace`
- API running on: `http://localhost:8050`