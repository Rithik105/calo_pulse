# CaloPulse

## 1. Setup Instructions

### Prerequisites
- Flutter SDK (stable)
- Firebase project
- Android Studio / Xcode (for mobile development)

```markdown
### Installation
```bash
git clone <repo-url>
cd calo_pulse
flutter pub get
```
## 2. Packages Used & Why
State Management

Provider: Simple and well-suited for the scale of this app.

Storage

firebase_auth: To handle authentication methods like magic link and email/password login.

cloud_firestore: For remote data storage and real-time synchronization.

hive / hive_flutter: For fast and encrypted local storage of calorie entries.

flutter_secure_storage: To securely store sensitive data like encryption keys and user info.

Utilities

app_links: For handling deep linking with email magic links.

uuid: For generating unique IDs for calorie entries.

connectivity_plus: To detect internet connectivity and handle offline/online syncing.

## 3. Chosen Tradeoffs

Push Notifications Not Implemented
Firebase Cloud Functions require the Blaze (paid) plan for deployment, so push notifications were not included to keep the project free-tier compatible.

Provider Instead of Bloc or Riverpod
Provider was chosen for its simplicity and faster implementation since the app scope is small.

Minimal UX Focus
Priority was on functionality, clean architecture, state handling, and offline-first safety. UI is functional but minimal.

## 4. WebSocket Implementation

Real-time updates are achieved using Firebase Cloud Firestore’s snapshot listeners.

The app subscribes to Firestore document changes via streams to sync calorie entries immediately.

No custom WebSocket server was needed, leveraging Firebase’s built-in realtime sync.
