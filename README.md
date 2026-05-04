# 🌿 WasteWatcher

> Watch it. Report it. Clean it.

A community-powered waste reporting and management app built for local governments and barangays in the Philippines.

## ✨ Features

### Mobile App (Flutter)
- 📸 Report waste with photo, GPS location, and waste type
- 🗺️ Live map showing all reported waste in your area
- 📋 Track your report status in real time
- 🏆 Earn points for every report you submit
- 🔔 Get notified when your report is resolved

### Admin Panel (React + Tailwind) _(coming soon)_
- 📊 Dashboard with report statistics and map overview
- ✅ Verify, assign, and resolve reports
- 👥 Manage cleanup teams and barangay areas
- 📁 Export reports

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter |
| Auth & Database | Firebase Auth + Firestore |
| Photo Storage | Cloudinary |
| Push Notifications | Firebase Cloud Messaging |
| Admin Panel | React + Tailwind CSS |
| Admin API | Node.js + Express |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x
- Firebase account
- Cloudinary free account

### Setup

**1. Clone the repo**
```bash
git clone https://github.com/yourusername/waste-watcher.git
cd waste-watcher
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

**4. Configure Cloudinary**

In `lib/services/cloudinary_service.dart`:
```dart
static const _cloudName = 'YOUR_CLOUD_NAME';
static const _uploadPreset = 'YOUR_UPLOAD_PRESET';
```

**5. Run the app**
```bash
flutter run
```

---

## 📁 Project Structure
