# Learning Notes — A Top-to-Bottom Walkthrough

These are study notes for this project, written as a single journey: from the moment the app
boots, through every screen a user touches, all the way down to Firebase and back. The goal
is that by reading top to bottom you understand both **what happens** and **why the code is
shaped this way** (Clean Architecture + Riverpod).

> These notes describe the code as it actually is. Where something is a deliberate
> trade-off or an unfinished hook, it's called out explicitly.

---

## Table of contents

1. [The big picture: layers and the dependency rule](#1-the-big-picture-layers-and-the-dependency-rule)
2. [The repeating layer pattern (every feature looks the same)](#2-the-repeating-layer-pattern-every-feature-looks-the-same)
3. [Dependency injection: the Riverpod provider graph](#3-dependency-injection-the-riverpod-provider-graph)
4. [App startup — `main.dart`](#4-app-startup--maindart)
5. [Routing and the auth guard — `go_router`](#5-routing-and-the-auth-guard--go_router)
6. [User flow, step by step](#6-user-flow-step-by-step)
   - [6.1 Sign up](#61-sign-up)
   - [6.2 Log in](#62-log-in)
   - [6.3 The notes list (home)](#63-the-notes-list-home)
   - [6.4 Create a note](#64-create-a-note)
   - [6.5 Edit / update a note](#65-edit--update-a-note)
   - [6.6 Delete a note](#66-delete-a-note)
   - [6.7 View profile](#67-view-profile)
   - [6.8 Edit profile](#68-edit-profile)
   - [6.9 Log out](#69-log-out)
7. [Cross-cutting concepts](#7-cross-cutting-concepts)
   - [Entity vs Model, and the map payloads](#entity-vs-model-and-the-map-payloads)
   - [Factory vs generative constructors](#factory-vs-generative-constructors)
   - [`Failure` — typed errors at the boundary](#failure--typed-errors-at-the-boundary)
   - [Use cases and params objects](#use-cases-and-params-objects)
   - [Controllers: `AsyncNotifier` + `AsyncValue.guard` + sealed states](#controllers-asyncnotifier--asyncvalueguard--sealed-states)
   - [`ref.watch` vs `ref.read` vs `ref.listen`](#refwatch-vs-refread-vs-reflisten)
8. [The Firestore data model](#8-the-firestore-data-model)
9. [File-by-file map](#9-file-by-file-map)

---

## 1. The big picture: layers and the dependency rule

The app uses **Clean Architecture**. Every feature is sliced into three layers, and
dependencies only ever point **inward**, toward the domain:

```
        presentation                 data
   (pages, controllers,        (models, datasources,
    immutable state)            repository impls)
            │                          │
            │   both depend on         │  implements
            ▼                          ▼
                       domain
        (entities, repository interfaces, use cases)
                 pure Dart — no Flutter, no Firebase
```

The one rule that makes the whole thing work: **the domain layer imports nothing from
Flutter or Firebase.** It only knows about plain Dart objects (`UserDetailsEntity`,
`NoteEntity`), abstract contracts (`AuthRepository`, `NoteRepository`), and the app's own
error type (`Failure`). Firebase lives exclusively in the data layer's *datasource* files.

Why bother? Because it means:
- You can swap Firebase for Supabase (or a REST API) by rewriting only the datasources.
- You can unit-test use cases and controllers with fake repositories — no Firebase boot.
- Each screen depends on the smallest possible surface, so changes stay local.

The three feature slices are **auth**, **note**, and **profile**. A shared **core** folder
holds everything cross-cutting: reusable widgets, theme, router, the `Failure` types, and the
`UseCase` base contracts.

---

## 2. The repeating layer pattern (every feature looks the same)

Once you learn one feature, you've learned them all. Following a single action top to bottom,
the call passes through these stops:

```
Widget (page)
  → Controller (AsyncNotifier, holds UI state)
    → UseCase (one class = one action)
      → Repository interface  (domain contract)
        → Repository impl      (data layer, forwards the call)
          → DataSource         (the ONLY place that touches Firebase)
            → Firebase Auth / Cloud Firestore
```

On the way back, raw data becomes a **Model**, the model upcasts to an **Entity** at the
repository seam, and the controller wraps it in an immutable **state** object the widget
renders. Firebase exceptions are caught in the datasource and converted to **`Failure`s**, so
nothing above the datasource ever sees a `FirebaseException`.

Each stop earns its place:
- **DataSource** — knows Firebase exists; nobody above it does.
- **Repository** — the seam where you'd later add caching, retries, or merge multiple
  sources. Right now it's a thin pass-through, and that's fine — keeping the seam means none
  of that future work needs a refactor.
- **UseCase** — one executable user intention, so a widget depends only on the action it
  needs, not the whole repository.
- **Controller** — turns an action into observable UI state (loading / success / failure).

---

## 3. Dependency injection: the Riverpod provider graph

Nothing in this app calls `FirebaseAuth.instance` or constructs its own repository inline.
Instead, every dependency is created by a **Riverpod provider** and passed down by
constructor. This is the wiring that connects the layers.

The auth graph (`core/providers/auth_providers.dart`) reads bottom-up like this:

```
sharedPreferencesProvider  (overridden in main)
        │
        ├──► authLocalDataSourceProvider ──► AuthLocalDataSourceImpl(prefs)
        │
firebaseAuthProvider  ─┐
firestoreProvider     ─┴──► authRemoteDatasourceProvider ──► AuthRemoteDatasourceImpl(auth, firestore)
                                     │
                                     ▼
                          authRepositoryProvider ──► AuthRepositoryImpl(remote)
                                     │
                 ┌───────────────────┴───────────────────┐
                 ▼                                        ▼
        signUpUseCaseProvider                    loginUserUseCaseProvider
```

Key points:
- `firestoreProvider` and `firebaseAuthProvider` are defined **once** in `auth_providers.dart`
  and **reused** by `note_providers.dart` and `profile_providers.dart`, so all three features
  share the same Firestore singleton.
- `sharedPreferencesProvider` deliberately throws `UnimplementedError` if read directly — it
  *must* be overridden in `main()` with a real instance (see next section). This lets every
  other read of prefs be synchronous.
- The note and profile graphs add two special providers that the UI watches directly:
  - `notesStreamProvider` — a `StreamProvider.family<List<NoteEntity>, String>` keyed by
    `userId`. It streams the live notes list.
  - `userProfileProvider` — a `FutureProvider.family<UserDetailsEntity, String>` keyed by
    `uid`. It fetches the profile once.

The `.family` modifier is what lets these providers take an argument (the user's id) while
still being cached per-argument by Riverpod.

---

## 4. App startup — `main.dart`

This is the literal top of the user flow. `main()` is `async` and does four things in order
before the first frame:

```dart
WidgetsFlutterBinding.ensureInitialized();      // 1
await Firebase.initializeApp();                 // 2
final prefs = await SharedPreferences.getInstance();  // 3
runApp(
  ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],  // 4
    child: const MyApp(),
  ),
);
```

1. **`ensureInitialized()`** — required whenever `main` does async/plugin work before
   `runApp`. It boots the Flutter engine binding.
2. **`Firebase.initializeApp()`** — boots the Firebase SDK using the platform's native config
   (`google-services.json` on Android, etc.).
3. **Load `SharedPreferences` up front** — so the router can read the "is logged in?" flag
   *synchronously* when deciding the first screen. No async gap, no flicker.
4. **`ProviderScope` with an override** — this is how the real `prefs` instance gets injected
   into `sharedPreferencesProvider` (which otherwise throws). Everything below this point can
   read prefs synchronously.

`MyApp` is a `ConsumerWidget`. It watches `goRouterProvider` and hands it to
`MaterialApp.router`. That single `ref.watch` is what connects navigation to the rest of the
app.

---

## 5. Routing and the auth guard — `go_router`

Navigation is centralized in `core/router/app_router.dart` and exposed as
`goRouterProvider`. All path strings live in `app_routes.dart` as constants so a typo can't
slip into a `context.go(...)` call.

Two pieces enforce the session rules:

**`initialLocation`** — picks the launch screen from the persisted flag:
```dart
initialLocation: authLocal.isLoggedIn() ? AppRoutes.notes : AppRoutes.login,
```

**`redirect`** — runs on *every* navigation and acts as a guard:
```dart
redirect: (context, state) {
  final loggedIn = authLocal.isLoggedIn();
  final onAuthPage = location == AppRoutes.login || location == AppRoutes.signUp;
  if (!loggedIn) return onAuthPage ? null : AppRoutes.login;  // signed out → only auth pages
  if (onAuthPage) return AppRoutes.notes;                     // signed in → kicked off auth pages
  return null;                                                // otherwise allow
}
```

So a signed-out user can never reach `/notes`, and a signed-in user can never go back to
`/login`. The flag it reads is the same `SharedPreferences` value the controllers set on
login/sign-up and clear on logout.

The route table also shows how data is passed between screens via `state.extra`:
- `/notes/edit` receives a `NoteEntity?` (`state.extra as NoteEntity?`).
- `/profile/edit` receives a `UserDetailsEntity?`.

`extra` carries a real object (not just a string id), which is how the edit pages get
pre-filled without re-fetching.

---

## 6. User flow, step by step

### 6.1 Sign up

**Screen:** `SignUpPage`. The user fills first name, last name, age, email, password.

**Down the stack:**
1. The page validates the form, builds a `SignUpUseCaseParams`, and calls
   `signUpControllerProvider.notifier.submit(params)`.
2. `SignUpController` (an `AsyncNotifier<SignUpState>`) sets state to `SignUpLoadingState`,
   then runs the work inside `AsyncValue.guard` (which turns any thrown error into an
   `AsyncError` instead of crashing):
   ```dart
   final user = await ref.read(signUpUseCaseProvider).call(params);
   await ref.read(authLocalDataSourceProvider).setLoggedIn(true);  // remember session
   return SignUpSuccessState(user);
   ```
3. `SignUpUserUseCase.call` → `AuthRepository.signUp` → `AuthRepositoryImpl` forwards to
   `AuthRemoteDatasourceImpl.signUp`.
4. The datasource does the real Firebase work, in order:
   - `auth.createUserWithEmailAndPassword(...)` → returns a `UserCredential` with the new `uid`.
   - Builds a `UserDetailsModel` from the form fields (the profile data that *isn't* part of
     Firebase Auth — first name, last name, age).
   - `firestore.collection('users').doc(uid).set(profile.toMap())` — writes the profile
     document keyed by the auth uid. `toMap()` also stamps `createdAt: serverTimestamp()`.

**Back up:** the model returns, upcasts to `UserDetailsEntity` at the repo seam, the
controller wraps it in `SignUpSuccessState`, and the page (listening via `ref.listen`) shows a
success snackbar and navigates to `/notes`.

**Why sign-up sets the logged-in flag:** a successful registration is also a login, so the
guard should let the user straight into the notes.

### 6.2 Log in

**Screen:** `LoginPage`. Email + password, with client-side validation (an email regex and a
6-char minimum) before anything is sent.

**Down the stack** mirrors sign-up, but the datasource's `login` does a *read* after auth:
```dart
final credential = await auth.signInWithEmailAndPassword(email, password);
final snapshot = await firestore.collection('users').doc(credential.user!.uid).get();
if (!snapshot.exists) throw const UnknownFailure('Profile not found for this account!');
return UserDetailsModel.fromMap(snapshot.data()!);   // rehydrate the profile from Firestore
```

So login both authenticates *and* re-reads the stored profile, rebuilding a
`UserDetailsModel` from the Firestore document via `fromMap`. On success the controller calls
`setLoggedIn(true)` and the page navigates to `/notes` with a "Welcome back, …" snackbar.

> Note: `login` is fully implemented (it was a stub in an earlier version of the project).

### 6.3 The notes list (home)

**Screen:** `HomepageListPage` (a `ConsumerStatefulWidget`).

1. It reads the current Firebase user: `ref.watch(firebaseAuthProvider).currentUser`. If
   that's somehow null, it shows a "must be logged in" message.
2. It watches the live notes stream for that user:
   ```dart
   final notesAsync = ref.watch(notesStreamProvider(user.uid));
   ```
   That call walks down: `notesStreamProvider` → `WatchNotesUseCase` → `NoteRepository` →
   `NoteRemoteDataSourceImpl.watchNotes(userId)`, which returns a Firestore stream:
   ```dart
   _notes.where('userId', isEqualTo: userId).snapshots().map(... sort client-side ...)
   ```
3. **`notesAsync.when(loading / error / data)`** renders the three UI states:
   - loading → a page loader,
   - error → "Failed to load notes",
   - data → the list (or an empty-state widget if there are no notes).
4. **Search** is local: a `TextEditingController` updates `_query` via `setState`, and the
   data branch filters the already-streamed list by title/content. No extra Firestore query.
5. The **app drawer** shows the account (derived from the email), links to the profile page,
   and holds the **Logout** action.
6. The **FAB** pushes `/notes/new` to create a note; tapping a card pushes `/notes/edit` with
   the `NoteEntity` as `extra`.

**One deliberate design choice — client-side sorting.** `watchNotes` queries by `userId` and
then sorts by `updatedAt` *in Dart*, newest first. Doing the sort in the query
(`where(userId) + orderBy(updatedAt)`) would force Firestore to require a composite index.
Sorting client-side avoids that index for a small per-user list. Pending `serverTimestamp`
values read as `null` locally, so the sort treats them as "now" (newest) until the server
stamps them.

### 6.4 Create a note

**Screen:** `NoteEditPage` opened with no note (`/notes/new`).

- The page collects title + content and calls `noteEditControllerProvider.notifier.create(...)`
  with a `CreateNoteUseCaseParams(userId, title, content)`.
- `NoteEditController.create` → `CreateNoteUseCase` → repo → `NoteRemoteDataSourceImpl.createNote`:
  ```dart
  final draft = NoteModel(id: '', userId, title, content);
  final ref = await _notes.add(draft.toCreateMap());   // toCreateMap sets created+updated timestamps
  final saved = await ref.get();
  return NoteModel.fromDoc(saved);                      // read back with the real id + server times
  ```
- On success the controller emits `NoteEditSuccessState(note, wasCreated: true)`. The list,
  being a live stream, updates on its own — no manual refresh.

### 6.5 Edit / update a note

**Screen:** `NoteEditPage` opened *with* a `NoteEntity` (`/notes/edit`, passed via `extra`),
so the fields are pre-filled.

- Saving calls `controller.save(UpdateNoteUseCaseParams(id, userId, title, content))` →
  `UpdateNoteUseCase` → repo → `updateNote`:
  ```dart
  await _notes.doc(id).update(draft.toUpdateMap());     // toUpdateMap bumps ONLY updatedAt
  final saved = await _notes.doc(id).get();
  return NoteModel.fromDoc(saved);
  ```
- `toUpdateMap()` writes just `title`, `content`, and a fresh `updatedAt` — it never touches
  `createdAt` or `userId`, so the note's history and ownership stay intact.
- Success → `NoteEditSuccessState(note, wasCreated: false)`.

### 6.6 Delete a note

- From the edit page, delete calls `controller.delete(DeleteNoteUseCaseParams(id))` →
  `DeleteNoteUseCase` → repo → `deleteNote`, which is just `_notes.doc(id).delete()`.
- Success → `NoteEditDeletedState`. Again, the live list reflects the removal automatically.
- Note that `DeleteNoteUseCase` implements `UseCaseWithParams<void, …>` — its result type is
  `void` because there's nothing to return.

### 6.7 View profile

**Screen:** `UserProfilePage`, reached from the drawer.

- It watches `userProfileProvider(uid)` — a `FutureProvider.family` that runs
  `GetUserProfileUseCase` → `ProfileRepository.getProfile` →
  `ProfileRemoteDataSourceImpl.getProfile`:
  ```dart
  final snapshot = await firestore.collection('users').doc(uid).get();
  if (!snapshot.exists) throw const UnknownFailure('Profile not found for this account');
  return UserDetailsModel.fromMap(snapshot.data()!);
  ```
- Because it's a `FutureProvider`, the page again uses `.when(loading/error/data)` to render.

**Reuse across features:** the profile feature does **not** define its own entity — it reuses
`UserDetailsEntity` from the auth feature. It's the same business object, just read on a
different screen. Profile only adds its own *datasource/repository/usecases*.

### 6.8 Edit profile

**Screen:** `EditProfilePage`, pre-filled with the `UserDetailsEntity` passed via `extra`.

- Saving calls `editProfileControllerProvider.notifier.submit(UpdateProfileUseCaseParams(uid,
  firstName, lastName, age))` → `UpdateProfileUseCase` → repo →
  `ProfileRemoteDataSourceImpl.updateProfile`:
  ```dart
  final draft = UserDetailsModel(firstName, lastName, age, email: ''); // email intentionally blank
  await doc.update(draft.toUpdateMap());   // toUpdateMap writes ONLY firstName/lastName/age
  final snapshot = await doc.get();
  return UserDetailsModel.fromMap(snapshot.data()!);
  ```
- The `email: ''` is safe because `UserDetailsModel.toUpdateMap()` only emits the three
  editable fields — it never writes `email` or `createdAt`. So the auth identity and the
  original creation timestamp are left untouched. This is the profile counterpart to the
  note's `toUpdateMap()`: update payloads are deliberately narrow.
- Success → `EditProfileSuccessState(details)`.

### 6.9 Log out

From the drawer's Logout item:
```dart
await ref.read(firebaseAuthProvider).signOut();              // end the Firebase session
await ref.read(authLocalDataSourceProvider).setLoggedIn(false);  // clear the persisted flag
context.go(AppRoutes.login);                                 // back to login
```
Clearing the flag means the router's guard now blocks every non-auth route, completing the
loop back to the start of the flow.

---

## 7. Cross-cutting concepts

These ideas show up at every layer; collecting them here avoids repeating them per feature.

### Entity vs Model, and the map payloads

- An **Entity** (`UserDetailsEntity`, `NoteEntity`) is pure business data — no Firestore
  awareness. It lives in the domain.
- A **Model** (`UserDetailsModel`, `NoteModel`) **extends** its entity and adds the
  (de)serialisation methods. It lives in the data layer.

Because the model *is-a* entity, a method declared to return the entity can return the model
and it silently upcasts at the seam. That's why repository **interfaces** return entities
while the **impls** return models — the richer type collapses to the plain one, and `toMap` /
`fromMap` stay invisible above the data layer.

There are **three deliberately different map payloads**, because create, update, and read are
not the same operation:

| Method | Used for | What it writes / reads |
| --- | --- | --- |
| `UserDetailsModel.toMap()` | sign-up `set()` | all fields + `createdAt: serverTimestamp()` |
| `UserDetailsModel.toUpdateMap()` | profile `update()` | only `firstName`, `lastName`, `age` |
| `NoteModel.toCreateMap()` | note `add()` | all fields + `createdAt` **and** `updatedAt` |
| `NoteModel.toUpdateMap()` | note `update()` | `title`, `content`, fresh `updatedAt` only |
| `*.fromMap(map)` / `NoteModel.fromDoc(doc)` | reads | rebuilds a model from Firestore data, with `?? defaults` |

Splitting "create map" from "update map" is what prevents an edit from clobbering
`createdAt` or `userId`.

> **`UserDetailsModel.fromEntity` is currently dead code.** It exists as a forward-looking
> hook ("if some code ever holds a bare entity and needs to write it to Firestore, promote it
> to a model first"), but nothing calls it today — models are always built directly or via
> `fromMap`. For a learning/portfolio project it's fine to keep as a documented hook; a strict
> linter would flag it as unused.

### Factory vs generative constructors

The models use both kinds of constructor, and the difference is the reason:

- A **generative** constructor (`UserDetailsModel({required ...})`) just assigns fields. Dart
  creates the instance for you; no `return`, no logic.
- A **factory** constructor (`UserDetailsModel.fromMap(...)`, `NoteModel.fromDoc(...)`) looks
  like a constructor to callers but runs logic first — null-checking the map, reading values
  by key, applying `?? ''` / `?? 0` defaults, converting `Timestamp` → `DateTime` — and then
  returns a fully-built instance. A generative constructor's initializer list can't express
  that "look up, validate, default, then build" flow; a factory can.

Quick test for whether something *could* be `factory`: "does it return an instance of the
class it's declared in?" `fromMap` returns a `UserDetailsModel` → yes, it's a constructor and
can be `factory`. `toMap()` returns a `Map` → no, it's an ordinary instance method, and
`factory` wouldn't even compile there. That's also why the Dart naming convention pairs
`Foo.fromX()` (a constructor on the class) with `foo.toX()` (a method on an instance).

### `Failure` — typed errors at the boundary

`core/error/failure.dart` defines the only error type allowed to cross layers:

```dart
sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);
  @override String toString() => message;
}
class ServerFailure  extends Failure { ... }  // backend responded with an error
class NetworkFailure extends Failure { ... }  // request never made it (offline/timeout)
class UnknownFailure extends Failure { ... }  // anything else; payload is for the developer
```

- **`sealed`** means the compiler knows every subtype, so a `switch (failure)` in the UI is
  *exhaustive* — add a fourth subtype and Dart warns at every unhandled `switch`. No package
  can sneak in a subtype the UI silently ignores.
- **`implements Exception`** lets the datasource `throw` a `Failure` directly instead of
  needing a separate translator.

Every datasource follows the same **narrow → wide** catch order:

```dart
on FirebaseAuthException catch (e) { throw ServerFailure(_authErrorMessage(e)); }  // narrowest
on FirebaseException     catch (e) { throw ServerFailure(e.message ?? '...'); }     // wider
on Failure { rethrow; }                  // already ours — don't re-wrap
catch (e) { throw UnknownFailure(e.toString()); }                                   // widest
```

Order matters: `FirebaseAuthException` *extends* `FirebaseException`, so the auth catch must
come first or auth errors would be swallowed by the generic branch. The `on Failure { rethrow; }`
line matters too — when the datasource itself throws a `Failure` (e.g. "Profile not found"),
this prevents the final `catch (e)` from re-wrapping it as `UnknownFailure`.

`_authErrorMessage` maps Firebase auth codes to user copy, and **deliberately collapses
`user-not-found` + `wrong-password` + `invalid-credential` into one message** ("Incorrect
email or password") so the app doesn't leak which accounts exist.

The end result: everything above the datasource sees only `Failure`. Firebase types never
reach the domain or presentation layers.

### Use cases and params objects

`core/usecase/usecase.dart` defines two tiny base contracts:
```dart
abstract class UseCaseWithParams<T, P> { Future<T> call(P params); }
abstract class UseCase<T>              { Future<T> call(); }
class NoParams { const NoParams(); }
```
Most actions are `UseCaseWithParams`. The base is intentionally minimal — it doesn't force
logging or error policy on subclasses.

Two things worth noticing:
- **Params objects** (`SignUpUseCaseParams`, `CreateNoteUseCaseParams`, …) exist instead of
  long positional argument lists. They give named, type-safe call sites (you can't silently
  swap two `String`s) and a stable signature (adding a field doesn't break `call`).
- **`WatchNotesUseCase` does *not* extend `UseCaseWithParams`.** Its `call` returns a
  `Stream`, not a `Future`, because Firestore *pushes* updates continuously. The base contract
  is future-shaped, so the streaming use case is its own plain class with a matching `call`.

### Controllers: `AsyncNotifier` + `AsyncValue.guard` + sealed states

Every screen controller follows the same template (login, sign-up, note-edit, edit-profile):

```dart
class XController extends AsyncNotifier<XState> {
  @override FutureOr<XState> build() => const XInitialState();

  Future<void> action(Params p) async {
    state = const AsyncValue.data(XLoadingState());
    final result = await AsyncValue.guard<XState>(() async {
      final value = await ref.read(someUseCaseProvider).call(p);
      return XSuccessState(value);
    });
    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(XLoadingState()),
      error: (e, _) => AsyncValue.data(XFailedState(e.toString())),
    );
  }
  void reset() => state = const AsyncValue.data(XInitialState());
}

final xControllerProvider =
    AsyncNotifierProvider.autoDispose<XController, XState>(XController.new);
```

- The UI state is a **sealed** class with `Initial / Loading / Success / Failed` variants (the
  note controller adds a `Deleted` variant). Sealed → the page's `switch` over states is
  exhaustive.
- **`AsyncValue.guard`** runs the async work and converts any thrown `Failure` into an
  `AsyncError` instead of an uncaught exception. The controller then maps that error into a
  `…FailedState(message)` the UI can show.
- **`.autoDispose`** means the controller is torn down when no widget is listening, so a
  half-finished login state doesn't linger after you leave the screen.

### `ref.watch` vs `ref.read` vs `ref.listen`

These three appear throughout the presentation layer and mean different things:
- **`ref.watch(provider)`** — subscribe and rebuild when it changes. Used for data the UI
  renders: `ref.watch(notesStreamProvider(uid))`, `ref.watch(goRouterProvider)`.
- **`ref.read(provider)`** — read once, no subscription. Used inside callbacks/handlers where
  you just want to fire an action: `ref.read(loginControllerProvider.notifier).submit(...)`.
- **`ref.listen(provider, (prev, next) {...})`** — run a side effect on change without
  rebuilding. Used for one-off reactions like showing a snackbar and navigating when login
  succeeds or fails.

---

## 8. The Firestore data model

Two top-level collections:

```
users/{uid}                      ← document id IS the Firebase Auth uid
   firstName : string
   lastName  : string
   age       : number
   email     : string
   createdAt : serverTimestamp   (set on sign-up, never overwritten)

notes/{autoId}                   ← document id is Firestore-generated
   userId    : string            (the owner's uid; queried with where('userId', ==))
   title     : string
   content   : string
   createdAt : serverTimestamp   (set on create)
   updatedAt : serverTimestamp   (set on create, bumped on every update)
```

Notes are filtered per user with `where('userId', isEqualTo: uid)` and sorted by `updatedAt`
client-side (see [6.3](#63-the-notes-list-home)).

---

## 9. File-by-file map

```
core/
  error/failure.dart            Sealed Failure + ServerFailure/NetworkFailure/UnknownFailure
  usecase/usecase.dart          UseCase / UseCaseWithParams / NoParams base contracts
  providers/auth_providers.dart Defines the shared firebaseAuth + firestore providers, auth DI
  providers/note_providers.dart Note DI + notesStreamProvider (StreamProvider.family)
  providers/profile_providers.dart Profile DI + userProfileProvider (FutureProvider.family)
  router/app_router.dart        goRouterProvider, initialLocation, redirect guard
  router/app_routes.dart        All path string constants
  common/                       Reusable widgets (buttons, fields, dialogs, loaders, avatar…)
  theme/, widgets/, resources/, utils/   Theme, app logo, strings/keys, helpers

feature/auth/
  domain/entities/user_details_entity.dart   Plain user object (reused by profile)
  domain/repository/auth_repository.dart      signUp / login contract
  domain/usecases/{sign_up,login}_user_usecase.dart  + their params objects
  data/model/user_details_model.dart          toMap / toUpdateMap / fromMap / fromEntity
  data/datasources/auth_local_datasource.dart  SharedPreferences "is logged in" flag
  data/datasources/auth_remote_datasource.dart The only auth file touching Firebase
  data/repository/auth_repository_impl.dart    Forwards to the datasource
  presentation/login/…                         LoginPage + controller + sealed state
  presentation/sign_up/…                       SignUpPage + controller + sealed state

feature/note/
  domain/entities/note_entity.dart             Plain note + copyWith; nullable timestamps
  domain/repository/note_repository.dart        watch/create/update/delete contract
  domain/usecases/{watch,create,update,delete}_note_usecase.dart
  data/model/note_model.dart                    fromDoc / toCreateMap / toUpdateMap
  data/datasources/note_remote_datasource.dart  Firestore queries + client-side sort
  data/repository/note_repository_impl.dart     Forwards to the datasource
  presentation/homepage_list_page.dart          Notes list, search, drawer, logout, FAB
  presentation/note_edit_page.dart              Create/edit/delete screen
  presentation/providers/note_edit_*            Controller + sealed state (adds Deleted)

feature/profile/
  domain/repository/profile_repository.dart     getProfile / updateProfile contract
  domain/usecases/{get_user_profile,update_profile}_usecase.dart
  data/datasources/profile_remote_datasource.dart  Reads/updates users/{uid}
  data/repository/profile_repository_impl.dart     Forwards to the datasource
  presentation/user_profile_page.dart           Read-only profile view
  presentation/edit_profile_page.dart           Edit screen
  presentation/providers/edit_profile_*         Controller + sealed state

main.dart                                       Boot: binding → Firebase → prefs → ProviderScope
```

---

### One-line summary of the whole flow

> **`main` boots Firebase + prefs → the router reads the persisted flag to pick login or
> notes → a page calls a controller → the controller runs a use case → the use case calls a
> repository → the repository forwards to a datasource → the datasource talks to Firebase and
> converts any error to a `Failure` → data comes back as a Model, upcasts to an Entity, and
> the controller wraps it in a sealed state the page renders.**
