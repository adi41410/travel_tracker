# Travel Tracker

A lightweight mobile app that lets travelers easily record, organize, and view key trip details—ensuring core functionality works smoothly before adding advanced features.

## Features

### MVP Features (Current)
- ✅ **User Account & Onboarding**
  - Simple email/phone signup or optional guest mode
  - Basic profile: name, home city, preferred currency

- ✅ **Trip Creation & Management**
  - Create trips with name, destination, start/end dates, and notes
  - View all trips with status indicators (upcoming, active, completed)
  - Edit and delete trips

- ✅ **Trip Information Capture**
  - Add daily activities with location, notes, and photos
  - Track expenses by category (transportation, accommodation, food, etc.)
  - Manual location entry or GPS pinning

- ✅ **Offline Data Storage**
  - Local SQLite database for offline-first functionality
  - All data accessible without internet connection

- ✅ **Trip Overview**
  - Timeline view of activities and expenses
  - Summary statistics (total activities, expenses)
  - Export functionality (basic implementation)

## Target Users
- Individual travelers who want to log trip details
- Small travel groups or families planning and tracking trips together

## Technical Architecture

### Frontend
- **Flutter**: Cross-platform mobile development (Android & iOS)
- **Provider**: State management for reactive UI updates
- **Material Design 3**: Modern UI components and theming

### Backend & Data
- **SQLite**: Local database for offline-first data storage
- **Firebase**: Cloud sync and authentication (prepared for future implementation)
- **Offline-first Architecture**: App works fully without internet connection

### Key Dependencies
- `sqflite`: Local database operations
- `provider`: State management
- `intl`: Date formatting and internationalization
- `image_picker`: Photo capture and selection
- `geolocator` & `geocoding`: Location services
- `path_provider`: File system access
- `share_plus`: Export and sharing functionality
- `pdf`: PDF generation for trip summaries

## Project Structure
```
lib/
├── main.dart              # App entry point and providers setup
├── models/                # Data models (User, Trip, Activity, Expense)
├── services/              # Business logic and data services
│   ├── auth_service.dart  # User authentication
│   └── database_service.dart # SQLite operations
├── providers/             # State management providers
│   ├── auth_provider.dart # Authentication state
│   └── trip_provider.dart # Trip data state
├── screens/               # UI screens
│   ├── auth_screen.dart   # User onboarding
│   ├── home_screen.dart   # Trip list
│   ├── create_trip_screen.dart # New trip creation
│   └── trip_detail_screen.dart # Trip details with tabs
└── widgets/               # Reusable UI components
```

## Getting Started

### Prerequisites
- Flutter SDK (3.35.4 or later)
- Dart SDK (3.9.2 or later)
- Android Studio / VS Code with Flutter extensions
- Android SDK or Xcode (for device testing)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd travel_tracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production
- **Android**: `flutter build apk --release`
- **iOS**: `flutter build ios --release`

## Database Schema

### Users Table
- `id`: Primary key (UUID)
- `email`: Optional email address
- `phone`: Optional phone number
- `name`: User's full name
- `homeCity`: User's home city
- `preferredCurrency`: Default currency (USD, EUR, etc.)
- `isGuest`: Boolean flag for guest accounts
- `createdAt`: Account creation timestamp
- `lastSyncAt`: Last cloud sync timestamp

### Trips Table
- `id`: Primary key (UUID)
- `userId`: Foreign key to users table
- `name`: Trip name
- `destination`: Trip destination
- `startDate`: Trip start date
- `endDate`: Trip end date
- `description`: Optional trip description
- `createdAt`: Creation timestamp
- `updatedAt`: Last modification timestamp
- `isSynced`: Cloud sync status

### Activities Table
- `id`: Primary key (UUID)
- `tripId`: Foreign key to trips table
- `userId`: Foreign key to users table
- `title`: Activity title
- `description`: Optional activity description
- `date`: Activity date
- `location`: Location name
- `latitude`: GPS latitude
- `longitude`: GPS longitude
- `photos`: Comma-separated photo paths
- `createdAt`: Creation timestamp
- `updatedAt`: Last modification timestamp
- `isSynced`: Cloud sync status

### Expenses Table
- `id`: Primary key (UUID)
- `tripId`: Foreign key to trips table
- `userId`: Foreign key to users table
- `activityId`: Optional foreign key to activities table
- `amount`: Expense amount
- `currency`: Currency code
- `category`: Expense category enum
- `description`: Optional expense description
- `date`: Expense date
- `createdAt`: Creation timestamp
- `updatedAt`: Last modification timestamp
- `isSynced`: Cloud sync status

## Future Enhancements (Post-MVP)
- **Cloud Sync**: Automatic synchronization with Firebase
- **Photo Management**: Enhanced photo storage and organization
- **Location Services**: Automatic location detection and maps integration
- **Export Options**: PDF reports, GPX tracks, social media sharing
- **Collaboration**: Share trips with travel companions
- **Budgeting**: Set and track travel budgets
- **Analytics**: Trip statistics and insights
- **Backup & Restore**: Data backup and restoration features

## Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Success Metrics
- Number of trips created per user
- Average daily active users during trips
- Feedback on ease of data entry and offline performance
- App store ratings and reviews
- User retention rates

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support
For support, email support@traveltracker.com or create an issue on GitHub.
