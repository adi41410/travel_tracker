# 🗺️ Travel Tracker

**A comprehensive Flutter mobile app for travelers to record, organize, and relive their travel experiences with an interactive snap map, gamified points system, and beautiful UI.**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B.svg?style=flat&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2.svg?style=flat&logo=dart)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-brightgreen.svg)](https://flutter.dev/multi-platform)

## ✨ Features

### 🔍 **Modern Navigation**
- Beautiful bottom navigation with 4 main sections
- Smooth transitions between Trips, Memories, Points, and Profile
- Material Design 3 UI with consistent theming

### 🗺️ **Interactive Snap Map**
- Google Maps integration showing all your travel memories
- Pin memories to specific locations with photos and descriptions
- Multiple map types: Normal, Satellite, Hybrid, Terrain
- Current location tracking with permission handling
- Tap markers to view memory details in beautiful bottom sheets

### ⭐ **Gamified Points System**
- **Comprehensive Rewards:**
  - 🎯 100 points for creating a trip
  - 🏆 500 points for completing a trip
  - 📸 50 points for adding memories
  - 📍 25 points for visiting new places
  - 📱 10 points for uploading photos
  - 🎉 5 points for daily login
  - 👤 200 points for completing your profile

- **Level Progression:**
  - 🌱 **Explorer** (Level 0-4)
  - ⭐ **Adventurer** (Level 5-9)
  - 🎯 **Wanderer** (Level 10-19)
  - 🌍 **Globetrotter** (Level 20-34)
  - 👑 **Travel Master** (Level 35-49)
  - 🏆 **Legendary Traveler** (Level 50+)

- **Statistics & Analytics:**
  - Detailed points history and breakdown
  - Progress bars and achievement tracking
  - Beautiful level indicators with custom colors and icons

### 📸 **Memory Management**
- Create rich travel memories with titles, descriptions, and tags
- Automatic location detection and geocoding
- Photo integration for visual memories
- Search and filter capabilities
- Link memories to specific trips

### 🎒 **Trip Management**
- Create and organize trips with destinations and dates
- Track trip status (Upcoming, Active, Completed)
- Add activities and expenses to trips
- Export trip details to PDF
- Offline functionality with local database

### 👤 **Enhanced Profile**
- User statistics: trips, memories, points, countries visited
- Level display with beautiful gradients
- Settings and preferences
- Account management

## 🛠️ Technical Features

- **Cross-Platform:** Android, iOS, Web, Windows support
- **Offline-First:** SQLite database with cloud sync capabilities
- **Location Services:** GPS tracking and geocoding
- **State Management:** Provider pattern for reactive UI
- **Material Design 3:** Modern, beautiful interface
- **Firebase Integration:** Authentication and cloud storage
- **Performance Optimized:** Efficient database queries and caching

## 📱 Screenshots

*Add your app screenshots here*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.35.4 or later)
- Dart SDK (3.9.2 or later)
- Android Studio / Xcode for mobile development
- A Google Maps API key (for map functionality)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/travel-tracker.git
   cd travel-tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps:**
   - Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add it to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_API_KEY_HERE"/>
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── models/          # Data models (User, Trip, Memory, Points)
├── providers/       # State management (Auth, Trip, Memory, Points)
├── screens/         # UI screens and navigation
├── services/        # Business logic and API calls
└── main.dart       # App entry point
```

## 🎨 Design System

- **Primary Color:** Teal
- **Typography:** Material Design 3
- **Icons:** Material Icons with custom illustrations
- **Navigation:** Bottom navigation with smooth transitions
- **Animations:** Subtle micro-interactions and transitions

## 📊 Database Schema

The app uses SQLite with the following main tables:
- `users` - User profiles and preferences
- `trips` - Trip information and metadata
- `activities` - Trip activities and experiences
- `expenses` - Trip-related expenses
- `memories` - Location-based travel memories
- `points_entries` - Points system transactions

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Maps for location services
- Material Design for the design system
- All contributors and testers

## 📞 Contact

Feel free to reach out if you have any questions or suggestions!

---

**Happy Traveling!** ✈️🌍📸