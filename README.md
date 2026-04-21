# Beacon Pro: Technical Assessment Submission

Welcome to the **Beacon Pro** project. This application is a production-grade Flutter implementation designed to demonstrate proficiency in Clean Architecture, hardware integration (iBeacons), and robust background processing.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Xcode (for iOS development)
- Android Studio (for Android development)
- A Firebase project with Google and Apple Sign-In enabled.

### Installation
1. Clone the repository.
2. Run `flutter pub get`.
3. Create your `firebase_options.dart` using the FlutterFire CLI.
4. Run `flutter run`.

## 🏗️ Architecture & Decisions

### Clean Architecture
The project follows a strict **Clean Architecture** pattern to ensure separation of concerns and testability:
- **Presentation Layer**: Built with **Bloc** for predictable state management. Custom UI components ensure a high-fidelity user experience.
- **Domain Layer**: Contains pure business logic and entities (e.g., `BeaconReading`, `BeaconAlert`). It defines interfaces for repositories, making the app framework-agnostic.
- **Data Layer**: Implements repository interfaces using **SharedPreferences** for persistence and **Firebase** for Authentication.

### iBeacon Wrapper Strategy
As per the requirement, we developed a dedicated `beacon_sdk` internal package. This wrapper abstracts the underlying scanning implementation, allowing the core business logic to interact with a high-level API. This ensures that the scanning library can be swapped out without touching the domain logic.

### Background Scanning
We utilize a **Foreground Service** (`flutter_foreground_task`) combined with a persistent isolate to ensure reliable beacon monitoring even when the application is minimized or the device is locked.

## 🛰️ Technical Highlights

### Signal Noise Reduction
Bluetooth signals are inherently noisy. We implemented a **Moving Average (Window Size: 10)** algorithm in the `DashboardBloc` to smooth out RSSI fluctuations. This results in stable, accurate distance estimations and prevents "flickering" notifications.

### Distance Estimation
Distance is calculated using the **Curve-Fit Algorithm** specified in the assessment guidelines:
1. If $Ratio < 1.0$: $Distance = Ratio^{10}$
2. Else: $Distance = (0.89976) \cdot Ratio^{7.7095} + 0.111$

### Alert Management & UX
- **Synthetic Latency**: A 2-second delay is added to all data fetching to simulate real-world hardware discovery lag.
- **High-Fidelity Loading**: Implemented **Shimmer** skeleton loaders to provide a premium user experience during loading states.
- **Cross-Isolate Reset**: When the user clears alerts, a signal is sent to the background scanner isolate to reset its internal notification debounce state, allowing for immediate re-notification upon zone re-entry.

## 🛡️ Edge Case Handling
- **Hardware States**: ProximityService monitors Bluetooth and Location states in real-time, triggering system-level alerts if services are disabled mid-scan.
- **Permission Denials**: A dedicated Permission UI handles fallback cases where "Always" location access is denied, providing clear instructions for recovery.
