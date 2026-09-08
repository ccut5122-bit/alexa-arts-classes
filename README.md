# 🎓 Alexa Arts Classes - Full Stack Education Platform

A premium **Native Android** study app + **Web Admin Panel** for JAC Class 11 Arts students (History, Political Science, Economics, Geography, Sociology, Psychology).

## 📁 Project Structure

```
alexa-arts-classes/
├── flutter_app/          # Flutter Mobile App (Dart)
│   └── lib/
│       ├── core/         # Theme, Router, Constants
│       ├── models/       # Firestore data models
│       ├── providers/    # State management (Provider)
│       ├── screens/      # All UI screens
│       ├── services/     # Firestore, Storage, Notifications
│       └── widgets/      # Reusable widgets
├── admin_panel/          # React.js Admin Panel
│   └── src/
│       ├── components/   # Layout & shared
│       ├── pages/        # Dashboard, MCQ CRUD, Analytics
│       └── services/     # Firebase config
└── FIRESTORE_SCHEMA.md   # Complete database schema
```

## 🚀 Quick Start

### 1. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable:
   - **Authentication** (Email/Password + Google)
   - **Cloud Firestore** (Production mode)
   - **Storage**
   - **Cloud Messaging** (FCM)
3. Register Android, iOS, and Web apps
4. Save config files:

**Admin Panel** → Update `admin_panel/src/firebase-config.js`
**Flutter App** → Replace `flutter_app/lib/firebase_options.dart` (or run `dart run flutterfire_configure`)

### 2. Flutter App

```bash
cd flutter_app
flutter pub get
flutterfire configure
flutter run
```

Generate APK:
```bash
flutter build apk --release --split-per-abi
```

### 3. Admin Panel

```bash
cd admin_panel
npm install
npm run dev       # http://localhost:3000
npm run build     # production build
```

## 📱 App Features

### Gamification
- 🔥 Daily study streak with badges
- 🪙 Alexa Coins (earn by quizzes & reading notes, unlock special tests)
- 🏆 Live Leaderboard (weekly/monthly/all-time)
- 🎖️ Digital certificates on subject completion

### Utility Tools
- 📅 JAC Exam Date Sheet & countdown timer
- 📖 Hindi-English Arts glossary (with TTS)
- 🔖 Bookmarks & 📢 Audio Notes (Text-to-Speech)
- 💬 Doubts Forum (peer/admin replies)

### Exam Prep
- 📝 JAC PYQs engine (2018-2026 solved papers)
- 🧠 Smart Revision Mode (auto-generates test from WRONG answers)
- 🏅 Monthly Quiz Series (timer, negative marking, rank cards)

### Offline
- 🔒 AES-256 encrypted offline notes & MCQs
- 📥 Download PDFs to secure local storage

## 🛠️ Admin Features

- **MCQ CRUD** — full question editor with images, Hindi, negative marking
- **Bulk Upload** — Excel/CSV parser with validation & template download
- **Dynamic Customization** — change app colors/banners/notices WITHOUT Play Store update
- **Notice Board** — popup banners ("JAC Admit Card Released!")
- **Analytics** — active users graph, weak subjects, district-wise reports (Excel/PDF export)
- **User Moderation** — ban/unban, premium toggle

## 🔐 Firestore Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }
    function isAdmin() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Users - read own, write own (admins all)
    match /users/{userId} {
      allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());
      allow create, update, delete: if isAdmin() || request.auth.uid == userId;

      match /{document=**} {
        allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());
        allow write: if isAdmin() || request.auth.uid == userId;
      }
    }

    // Content (subjects, chapters, notes, questions, quizzes, dictionary)
    match /{content=subjects|chapters|notes|questions|quizzes|dictionary}/{docId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }

    // Dynamic config - public read
    match /dynamicConfig/{configId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }

    // Leaderboard - public read
    match /leaderboard/{period} {
      allow read: if isSignedIn();
      match /entries/{uid} {
        allow read: if isSignedIn();
        allow write: if isAdmin() || request.auth.uid == uid;
      }
    }

    // Forum - any signed-in user participates
    match /forum/{postId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if isAdmin() ||
        (isSignedIn() && resource.data.authorId == request.auth.uid);

      // Replies are writeable by any signed-in non-banned user
      match /replies/{replyId} {
        allow read: if isSignedIn();
        allow create: if isSignedIn() &&
          request.resource.data.authorId == request.auth.uid;
        allow delete: if isAdmin();
      }
    }
  }
}
```

## 🗄️ Database Schema

Full JSON structure for every collection (Users, Subjects, Chapters, Notes, Questions, Quizzes, Leaderboards, Dynamic Configs) → see [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md)

## 🧩 Required Firestore Indexes

Create these in Firebase Console → Firestore → Indexes:

| Collection | Fields | Order |
|---|---|---|
| `users` | `lastActive` | DESC |
| `questions` | `subjectId` ASC, `chapterId` ASC | |
| `questions` | `source` ASC, `subjectId` ASC | |
| `forum` | `isDeleted` ASC, `createdAt` DESC | |
| `leaderboard/entries` | `coins` | DESC |

## 📊 Deliverables Mapping

| Required | Location |
|---|---|
| a) Chapter List & Notes Viewer | `screens/chapters/chapter_list_screen.dart` + `screens/notes/notes_viewer_screen.dart` |
| b) MCQ Quiz Screen (Timer + Explanation) | `screens/quiz/quiz_screen.dart` |
| c) Dynamic Theme/Config Receiver | `providers/config_provider.dart` + `widgets/` |
| d) Admin MCQ CRUD | `admin_panel/src/pages/QuestionsPage.jsx` |