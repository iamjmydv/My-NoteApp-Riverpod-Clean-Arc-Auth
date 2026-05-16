# My-NoteApp-Riverpod-Clean-Arc-Auth
Flutter Notes App built with Clean Architecture and Riverpod for scalable state management. Features Firebase Authentication for login/signup and Cloud Firestore for real-time note syncing. Designed with maintainability, scalability, and clean code practices in mind.

## Firebase Packages

### `firebase_core` — the foundation/bootstrap package
- Initializes the Firebase SDK (`Firebase.initializeApp()`)
- Manages the connection to your Firebase project (using `firebase_options.dart`)
- Required by every other Firebase plugin — but it doesn't include any of their features
- Think of it as the "engine" — it doesn't do auth or database work itself

### `firebase_auth` — authentication only
- Sign in / sign up (email, Google, Apple, anonymous, phone, etc.)
- User session management, password reset, email verification
- `FirebaseAuth.instance`, `User`, `UserCredential` classes

### `cloud_firestore` — the NoSQL database only
- Reading/writing documents and collections
- Real-time listeners (`snapshots()`)
- Queries, transactions, batched writes
- `FirebaseFirestore.instance`, `DocumentSnapshot`, `QuerySnapshot` classes

### Other Firebase packages you might add later (each is separate)
- `firebase_storage` — file/image uploads
- `firebase_messaging` — push notifications
- `cloud_functions` — call backend functions
- `firebase_analytics`, `firebase_crashlytics`, etc.

Each one is its own dependency — that's the modular pattern Firebase uses.
