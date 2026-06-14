# My NoteApp — Riverpod · Clean Architecture · Firebase Auth

A Flutter notes app built to demonstrate **Clean Architecture** with **Riverpod** state
management. Users sign up and log in with Firebase Authentication, then create, edit, and
delete personal notes that sync in real time through Cloud Firestore. Designed with
maintainability, scalability, and clean-code practices in mind.

> 🎨 **Figma Design:** [Flutter Noteapp Design](https://www.figma.com/design/hbdnZFLMiGs1HV2GU3rnUX/Flutter-Noteapp-Design?node-id=0-1&t=ReyllgnMTb5aRDie-1)

> 📓 **Learning notes:** In-depth explanations of the architectural decisions behind this
> codebase live in [LEARNING_NOTES.md](LEARNING_NOTES.md).

---

## Features

- **Authentication** — email/password sign-up and login via Firebase Authentication, with a
  persisted session flag so the app opens on the right screen.
- **Notes** — create, edit, and delete notes; the list updates live via Firestore real-time
  listeners (`snapshots()`).
- **Profile** — view and edit user profile details stored in Firestore.
- **Clean, reusable UI** — a shared library of common widgets (buttons, text fields,
  dialogs, loaders, empty states) and a centralized theme using the Inter font.

## Tech Stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.11.4`) |
| State management | `flutter_riverpod` ^3.3.1 |
| Navigation | `go_router` ^17.2.3 |
| Auth | `firebase_auth` ^6.5.1 |
| Database | `cloud_firestore` ^6.4.1 |
| Firebase bootstrap | `firebase_core` ^4.9.0 |
| Local storage | `shared_preferences` ^2.5.5 |
| Linting | `flutter_lints` ^6.0.0 |

## Architecture

The app follows **Clean Architecture**: each feature is split into three layers with a
strict dependency direction — `presentation → domain ← data`. The domain layer is pure Dart
and has no knowledge of Flutter or Firebase; only the data layer imports the SDKs.

```
presentation  (Riverpod controllers + immutable state, pages/widgets)
     │  depends on
     ▼
  domain      (entities, repository interfaces, use cases)  ← pure Dart, no SDKs
     ▲  implemented by
     │
   data        (models, datasources, repository implementations)  ← Firebase lives here
```

- **Domain** — `entities`, abstract `repository` contracts, and single-action `usecases`
  (e.g. `LoginUserUseCase`, `CreateNoteUseCase`, `WatchNotesUseCase`). Returns entities and
  the app's own typed `Failure`s — never Firebase exceptions.
- **Data** — `model`s (extend entities, add `toMap`/`fromMap`), `datasources` (the only code
  that touches `FirebaseAuth` / `FirebaseFirestore`), and repository `impl`s that satisfy the
  domain contracts.
- **Presentation** — pages plus Riverpod controllers paired with immutable state classes.
- **Core** — cross-cutting building blocks: reusable widgets, theme, router, string/key
  resources, the `Failure` hierarchy, and the `UseCase` base contracts.

Dependencies are wired with Riverpod providers (`core/providers/`), so datasources and
repositories receive their collaborators via constructor injection and stay testable.

## Project Structure

```
my_noteapp_riverpod_clean_arc_auth/
└── lib/
    ├── main.dart                  # Entry point: init Firebase + prefs, mount ProviderScope
    ├── core/
    │   ├── common/                # Reusable widgets (buttons, fields, dialogs, loaders…)
    │   ├── error/                 # Failure hierarchy
    │   ├── providers/             # Riverpod providers (auth, note, profile)
    │   ├── resources/             # Keys & string constants
    │   ├── router/                # go_router config + route paths
    │   ├── theme/                 # App theme
    │   ├── usecase/               # UseCase base contracts
    │   ├── utils/                 # Helpers (relative time, …)
    │   └── widgets/               # App-level widgets (logo)
    └── feature/
        ├── auth/                  # Login & sign-up
        │   ├── data/              #   models, datasources, repository impl
        │   ├── domain/            #   entities, repository, usecases
        │   └── presentation/      #   pages + controllers/state
        ├── note/                  # Notes CRUD + live list  (same data/domain/presentation split)
        └── profile/               # View & edit profile      (same split)
```

## Routes

Defined in `core/router/app_routes.dart`:

| Path | Screen |
| --- | --- |
| `/login` | Login |
| `/sign-up` | Sign up |
| `/notes` | Notes list (home) |
| `/notes/new` | Create note |
| `/notes/edit` | Edit note |
| `/profile` | User profile |
| `/profile/edit` | Edit profile |

## Getting Started

### Prerequisites
- Flutter SDK (Dart `^3.11.4` or compatible)
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled

### Setup

1. **Clone and install dependencies**
   ```bash
   cd my_noteapp_riverpod_clean_arc_auth
   flutter pub get
   ```

2. **Configure Firebase.** The app boots with `Firebase.initializeApp()` using the
   platform's native config files. The recommended way to generate them is the FlutterFire
   CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This adds `android/app/google-services.json` (and the equivalents for other platforms).
   In Firebase Console, enable the **Email/Password** sign-in provider and create a
   **Firestore** database.

   > ⚠️ Firebase config files contain project keys. Do not commit real credentials to a
   > public repository — add them to `.gitignore` and use your own Firebase project.

3. **Run the app**
   ```bash
   flutter run
   ```

### Supported platforms
Android, iOS, Web, macOS, Windows, and Linux scaffolding are all present.

## Firestore Data Model

- `users/{uid}` — profile document (first name, last name, age, email) written on sign-up.
- Notes are stored per user and streamed live into the notes list.

## Status & Roadmap

This is primarily a **learning / portfolio project**. The core flows (sign-up, login, notes
CRUD, profile view/edit) are all implemented. A few areas are intentionally scaffolded for
extension:

- `UserDetailsModel.fromEntity` exists as a forward-looking hook and has no call sites yet.
- "Forgot password" is surfaced in the login UI but not yet wired up.

See [LEARNING_NOTES.md](LEARNING_NOTES.md) for the full rationale behind these and other
design choices.

## License

No license file is currently included. Add one (e.g. MIT) if you intend to share or reuse
this project.
