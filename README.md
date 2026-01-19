# calo_pulse

## 1. Setup Instructions

### Prerequisites
- Flutter SDK (stable)  
- Firebase project  
- Android Studio / Xcode (for mobile development)

### Steps
git clone <repo-url>
cd calo_pulse
flutter pub get



2. Packages Used & Why
State Management

Provider — Simple and well-suited for the scale of this app.

Storage

firebase_auth — To handle login methods.

cloud_firestore — To store data remotely.

hive / hive_flutter — For local offline storage.

flutter_secure_storage — For storing encryption keys and sensitive user data.

Utility

app_links — For handling deep linking.

uuid — For generating unique IDs.

connectivity_plus — To detect the app's internet connectivity status.

3. Chosen Tradeoffs

Push Notifications Not Implemented — Firebase Cloud Functions require the Blaze (paid) plan, so this was skipped.

Provider instead of Bloc/Riverpod — Provider was chosen for faster implementation given the app’s small scope.

Minimal UX — Focus was placed on functionality, architecture, state handling, and offline safety rather than polish.

4. WebSocket Implementation

Firebase Cloud Firestore’s real-time listeners are used instead of a custom WebSocket server.

The app subscribes to Firestore using snapshot listeners, which provide real-time updates over persistent connections managed internally by Firebase.

This eliminates the need to maintain a separate WebSocket server and simplifies real-time data syncing.
