> 🎨 **Figma Design:** [Flutter Noteapp Design](https://www.figma.com/design/hbdnZFLMiGs1HV2GU3rnUX/Flutter-Noteapp-Design?node-id=0-1&t=ReyllgnMTb5aRDie-1)

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

### Other Firebase packages might add later (each is separate)
- `firebase_storage` — file/image uploads
- `firebase_messaging` — push notifications
- `cloud_functions` — call backend functions
- `firebase_analytics`, `firebase_crashlytics`, etc.

Each one is its own dependency — that's the modular pattern Firebase uses.

## Regular vs Factory constructor

### Regular (generative) constructor — like the one on line 21
```dart
const UserDetailsModel({required super.firstName, ...});
```
- Automatically creates a new instance of the class.
- You can only assign to `this.field` or call `super(...)`.
- No `return` statement allowed. Dart does the "new object" part for you.

### Factory constructor — line 35
```dart
factory UserDetailsModel.fromMap(Map<String, dynamic>? map) => UserDetailsModel(...);
```
- Looks like a constructor from the outside (callers still write `UserDetailsModel.fromMap(json)`), but you control what gets returned.
- It must explicitly return an instance (here via `=> UserDetailsModel(...)`).
- It can run logic, transform data, return a cached instance, or even return a subclass — none of which a regular constructor can do.

### Why `fromMap` is a factory
Look at what happens inside it on lines 36–39:
```dart
firstName: map?[Keys.firstName] ?? '',
age: map?[Keys.age] ?? 0,
```
It's doing work before constructing:
- Null-checking the whole map (`map?[...]`).
- Reading values out by string keys.
- Falling back to defaults (`?? ''`, `?? 0`) when a field is missing.

A regular constructor's initializer list can't easily express that kind of "look up, validate, default, then build" flow. The factory wraps that logic and hands back a fully-constructed `UserDetailsModel`.

### Mental model
Think of it like this:
- `UserDetailsModel(...)` → "build me one from these exact fields."
- `UserDetailsModel.fromMap(json)` → "figure out how to build one from this Firestore document."
- `UserDetailsModel.fromEntity(e)` → "convert this entity into a model."

The `factory` keyword is what lets `fromMap` and `fromEntity` do that conversion/lookup work and still feel like constructors to whoever calls them.

### Why `toMap` isn't a factory

`factory` is a **constructor** keyword. `toMap` isn't a constructor.

Look at what each one returns:

| Member | Returns | Is it a constructor? |
| --- | --- | --- |
| `UserDetailsModel(...)` (line 21) | `UserDetailsModel` | yes — generative |
| `UserDetailsModel.fromMap(map)` (line 35) | `UserDetailsModel` | yes — factory |
| `UserDetailsModel.fromEntity(e)` (line 28) | `UserDetailsModel` | yes — factory |
| `toMap()` (line 42) | `Map<String, dynamic>` | no — instance method |

`factory` is a modifier you can only put on a constructor — i.e. something whose job is to produce an instance of the class it lives in. `fromMap` and `fromEntity` both build a `UserDetailsModel`, so they qualify.

`toMap` does the opposite direction: it takes an existing `UserDetailsModel` (`this`) and produces a `Map`. It's not constructing a `UserDetailsModel` at all — it's reading one. That makes it an ordinary instance method.

#### The naming convention that trips people up

In Dart you'll often see this pairing:

```dart
Foo.fromX(...)   // constructor — builds a Foo from an X
foo.toX()        // method      — converts this Foo into an X
```

The `from*` / `to*` symmetry makes them look like a matched set, but they're structurally different:
- `from*` lives on the **class** (you call it as `UserDetailsModel.fromMap(...)`). It needs a constructor — and since it does lookup/defaulting work, that constructor is a factory.
- `to*` lives on an **instance** (you call it as `model.toMap()`). It's just a method.

#### Quick test you can apply

Ask: "is the thing being returned an instance of the class this member is declared in?"
- **Yes** → it's a constructor → it can be `factory` (if it needs logic) or generative (if it just assigns fields).
- **No** → it's a method → `factory` doesn't apply, and putting it there would be a compile error.

`toMap` returns a `Map`, not a `UserDetailsModel`, so `factory` is not even an option.

## `fromEntity` — converting Entity → Model

`fromEntity` converts a domain `UserDetailsEntity` into a data-layer `UserDetailsModel` — i.e. it "upgrades" a plain entity into the richer model that knows how to talk to Firestore.

### Class hierarchy
- [user_details_entity.dart:14](lib/feature/auth/domain/entity/user_details_entity.dart#L14) — pure Dart, no Firestore awareness.
- [user_details_model.dart:20](lib/feature/auth/data/model/user_details_model.dart#L20) — extends `UserDetailsEntity` and adds `toMap` / `fromMap`.

If some code in the domain or presentation layer only has a `UserDetailsEntity` in hand and needs to write it to Firestore, it can't call `toMap()` on the entity (the entity doesn't have that method). So you'd promote it first:

```dart
final entity = UserDetailsEntity(firstName: 'Jam', lastName: 'D', age: 25, email: 'a@b.com');
final model  = UserDetailsModel.fromEntity(entity); // now has toMap()
await firestore.collection('users').doc(uid).set(model.toMap());
```

That's the intended use case.

### Where it's actually used
Nowhere — currently. The only hits for `fromEntity` in `lib/` are:
- [user_details_model.dart:9](lib/feature/auth/data/model/user_details_model.dart#L9) — the comment describing it.
- [user_details_model.dart:28](lib/feature/auth/data/model/user_details_model.dart#L28) — the definition itself.

No call sites exist. It was written defensively for "in case the data layer ever receives a bare entity," but in the current flow the model is always built directly via `UserDetailsModel(...)` (in `auth_remote_datasource.dart`) or via `fromMap` when reading from Firestore — never via `fromEntity`.

### What to do with it
Two reasonable options:
1. **Delete it.** It's currently dead code. If a future need appears, you can add it back in two lines.
2. **Keep it as a hook.** It's cheap to have, and the moment the domain layer needs to push an entity into Firestore (e.g. an "update profile" flow that starts from an entity), it'll save you writing the conversion inline.

For a learning/portfolio project, keeping it is fine — the comment at the top of the file already documents its purpose. For a strict codebase, it'd get flagged as unused.

## `AuthRemoteDatasource` — the data-layer Firebase gateway

This is the only place in the app that talks directly to `FirebaseAuth` and `FirebaseFirestore`. Everything above it (repository → usecase → presentation) goes through the abstract `AuthRemoteDatasource` interface and never imports the Firebase SDKs.

### Abstract interface vs implementation
- [auth_remote_datasource.dart:8](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L8) — `AuthRemoteDatasource` abstract class: declares `signUp` and `login`, both returning `Future<UserDetailsModel>`.
- [auth_remote_datasource.dart:13](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L13) — `AuthRemoteDatasourceImpl`: holds `FirebaseAuth` and `FirebaseFirestore` (both injected via constructor) and implements the contract.

Why split them? So the repository can depend on the **interface**, and tests can swap in a fake implementation without booting Firebase.

### Constructor injection
```dart
AuthRemoteDatasourceImpl({
  required this.auth,
  required this.firestore,
});
```
- `auth` and `firestore` come from outside (Riverpod providers).
- The class doesn't call `FirebaseAuth.instance` or `FirebaseFirestore.instance` itself — that would hard-wire it to the global singletons and make it untestable.

### `signUp` flow
[auth_remote_datasource.dart:25](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L25) does three things in order:

1. **Create the auth user** — `auth.createUserWithEmailAndPassword(...)` returns a `UserCredential` containing the new `uid`.
2. **Build the profile model** — `UserDetailsModel(...)` (generative constructor) wraps the fields that don't live in Firebase Auth (firstName, lastName, age).
3. **Persist the profile** — `firestore.collection('users').doc(uid).set(profile.toMap())` writes the model as a document keyed by the auth uid.

This is exactly where `toMap()` from the [Regular vs Factory constructor](#regular-vs-factory-constructor) section earns its keep — Firestore's `.set(...)` takes a `Map<String, dynamic>`, not a `UserDetailsModel`.

### Why the collection name is a private field
```dart
final String _collection = 'users';
```
- `_` makes it library-private (no leak to consumers).
- `final` so it can't be reassigned.
- Centralizing the string here means a rename never gets out of sync between `signUp` and a future `login` / `getProfile`.

### Error handling — three layers, narrow → wide
[auth_remote_datasource.dart:45-51](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L45-L51):

| Catch | Source | Wrapped as |
| --- | --- | --- |
| `on FirebaseAuthException` | Auth SDK (bad password, email in use, etc.) | `ServerFailure(_authErrorMessage(e))` |
| `on FirebaseException` | Firestore SDK (permission denied, offline, etc.) | `ServerFailure(e.message ?? 'Firestore error (${e.code})')` |
| `catch (e)` | Anything else (programmer error, plugin bug) | `UnknownFailure(e.toString())` |

Order matters: `FirebaseAuthException` extends `FirebaseException`, so the narrower auth catch **must** come first or every auth error would be swallowed by the generic Firestore branch.

All three branches convert raw SDK exceptions into the project's own `Failure` types (defined in `core/error/failure.dart`). The repository above never sees a `FirebaseAuthException` — it only sees `Failure`s, which keeps Firebase out of the domain layer.

### `_authErrorMessage` — translating codes to UI copy
[auth_remote_datasource.dart:60](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L60) switches on `e.code` and returns a human-friendly string. Two things worth noting:

- **`user-not-found` and `wrong-password` collapse to the same message** ("Incorrect email or password"). That's deliberate — telling the user *which* of the two was wrong leaks account-existence info to attackers.
- **Default branch falls back to `e.message`** rather than a generic string, so unmapped codes still surface something useful while still including the code.

### `login` — currently a stub
[auth_remote_datasource.dart:55](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L55) throws `UnimplementedError()`. The signature is in place so the repository and usecase can already wire it up; the body just needs to be filled in (probably `signInWithEmailAndPassword` + a Firestore read to rehydrate the profile).

### Mental model
- `AuthRemoteDatasource` = "the thin layer that knows Firebase exists."
- Above it: pure Dart, no SDK imports, only `UserDetailsModel` / `UserDetailsEntity` / `Failure`.
- Below it: the Firebase plugins.

If you ever swap Firebase for Supabase, this is the file that gets rewritten — and nothing else has to change.

## `AuthRepository` — the domain ↔ data seam

The repository sits between the **usecases** (domain) and the **datasource** (data). The domain declares the contract; the data layer implements it. Anyone above this line talks to `AuthRepository`; nothing above it knows an `AuthRemoteDatasource` exists.

### The interface — domain side
- [auth_repository.dart:5](lib/feature/auth/domain/repository/auth_repository.dart#L5) — abstract `AuthRepository`. Pure Dart, returns `UserDetailsEntity`, not `UserDetailsModel`. The domain has no awareness that a "model" type exists.

### The implementation — data side
- [auth_repository_impl.dart:7](lib/feature/auth/data/repository/auth_repository_impl.dart#L7) — `AuthRepositoryImpl extends AuthRepository`. Holds an `AuthRemoteDatasource` (injected) and forwards calls one-to-one.

Notice the return types:
```dart
// interface (domain)   Future<UserDetailsEntity>
// impl     (data)      Future<UserDetailsModel>
```
The impl returns the richer `UserDetailsModel`, which silently upcasts to `UserDetailsEntity` at the seam because `UserDetailsModel extends UserDetailsEntity`. Callers see only the entity — `toMap()` / `fromMap()` stay invisible to anything above this line.

### Why a thin pass-through?
Right now `signUp` and `login` just call straight through to the datasource. It looks redundant. The repository earns its keep the moment you need to:
- combine multiple sources (remote + local cache),
- merge or transform failures,
- add retry / throttle / timeout policy,
- gate features behind a remote-config flag.

That logic belongs **here** — not in the datasource (too low) and not in the usecase (too high). Keeping the seam in place even when it does nothing means none of that work needs a refactor when it finally arrives.

## Use cases — one class per action

A usecase is a single executable user intention (sign up, log in, fetch profile, …). Each one is its own class, holding only the repository it needs and exposing a single `call(...)` method.

### The base contracts — [core/usecase/usecase.dart](lib/core/usecase/usecase.dart)
```dart
abstract class UseCaseWithParams<T, P> { Future<T> call(P params); }
abstract class UseCase<T>              { Future<T> call(); }
class NoParams { const NoParams(); }
```
- `UseCase<T>` — for parameter-less actions (e.g. a future `LogoutUseCase`).
- `UseCaseWithParams<T, P>` — everything else; `P` is the params object.
- `NoParams` — sentinel for the rare case you want `UseCaseWithParams` semantics without real params.

The base class is intentionally minimal. It doesn't try to enforce error handling, logging, or transactions — that would force every usecase to opt into a framework. Subclasses do whatever they need inside `call`.

### `SignUpUserUseCase`
- [sign_up_user_usecase.dart:5](lib/feature/auth/domain/usecases/sign_up_user_usecase.dart#L5) — `SignUpUseCaseParams` (firstName, lastName, age, email, password).
- [sign_up_user_usecase.dart:21](lib/feature/auth/domain/usecases/sign_up_user_usecase.dart#L21) — `SignUpUserUseCase implements UseCaseWithParams<UserDetailsEntity, SignUpUseCaseParams>`.
- `call(params)` → `repository.signUp(params)`.

### `LoginUserUseCase`
- [login_user_usecase.dart:5](lib/feature/auth/domain/usecases/login_user_usecase.dart#L5) — `LoginUseCaseParams` (email, password).
- [login_user_usecase.dart:12](lib/feature/auth/domain/usecases/login_user_usecase.dart#L12) — `LoginUserUseCase implements UseCaseWithParams<UserDetailsEntity, LoginUseCaseParams>`.
- `call(params)` → `repository.login(params)`.

### Why one class per action?
A repository can grow to a dozen methods. A presentation widget that only needs `signUp` shouldn't have to depend on the entire repository surface — it depends on `SignUpUserUseCase`, gets only what it needs, and is trivial to fake in a widget test.

It also gives every action a natural home for cross-cutting work: input validation, analytics, throttling — attach it to the usecase and the rest of the stack stays clean.

### Params objects vs positional arguments
`SignUpUseCaseParams` exists instead of `call(firstName, lastName, age, email, password)` for two reasons:
- **Named, type-safe arguments** — at the call site you write `SignUpUseCaseParams(email: ..., password: ...)`, not a five-positional-string call where any two strings could be swapped without the compiler noticing.
- **Stable signature** — adding a new field (e.g. `referralCode`) is a non-breaking change to `call`; only the params constructor grows.

## `Failure` — typed errors at the layer boundary

[core/error/failure.dart](lib/core/error/failure.dart) defines the only error type that crosses layers:

```dart
sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class ServerFailure  extends Failure { ... }
class NetworkFailure extends Failure { ... }
class UnknownFailure extends Failure { ... }
```

### Why `sealed`?
A `sealed` class can only be extended within the same library. The compiler then knows every possible subtype, which means:
- A `switch (failure)` in the presentation layer becomes **exhaustive** — Dart warns if a new `Failure` subtype is added without a matching case.
- No third-party package can sneak in a fourth `Failure` subclass that the UI silently ignores.

### Why it `implements Exception`
So the datasource can `throw` a `Failure` directly instead of needing a separate exception-to-failure translator. The `try/catch` in [auth_remote_datasource.dart:45-51](lib/feature/auth/data/datasources/auth_remote_datasource.dart#L45-L51) already does the work — it converts every raw SDK error into one of the three `Failure` subtypes before re-throwing.

### How it flows through the stack
```
FirebaseAuthException ─┐
FirebaseException     ─┼─→ Failure ─→ Failure ─→ Failure ─→ catch & render
other Exception       ─┘   (data)     (repo)     (usecase)    (presentation)
       ↑
   raw SDK errors die here, in the datasource
```

Everything above the datasource sees `Failure` — never `FirebaseAuthException`. That's what keeps the Firebase SDKs out of the domain layer.

### Why three subtypes (and not more)
- `ServerFailure` — the backend responded with an error (auth rejected the credentials, Firestore returned a permission error).
- `NetworkFailure` — the request never made it (offline, DNS, timeout). Reserved for connectivity-class errors so the UI can offer a retry instead of an "incorrect password"-style message.
- `UnknownFailure` — escape hatch for anything else; the `e.toString()` payload is for the developer, not the user.

Keep the set small. The point of a sealed type is exhaustive handling — every new subtype is a new `case` in every `switch` across the presentation layer.

## `AsyncValue.data` vs `AsyncValue.guard`

They do completely different jobs — they just both produce an `AsyncValue`.

### `AsyncValue.data(value)` — a constructor
A synchronous wrapper. You already have a value in hand and you're boxing it into the `AsyncValue` shape so you can assign it to state.

```dart
state = const AsyncValue.data(LoginLoadingState()); // line 30
```

Siblings: `AsyncValue.loading()`, `AsyncValue.error(e, st)`. None of them run any code — they just construct.

**Use when:** you're manually setting state to a value you already computed (or a sentinel like your `LoginLoadingState`).

### `AsyncValue.guard(() async {...})` — a runner
Executes an async function and catches anything it throws, returning:
- `AsyncValue.data(result)` if it completed, or
- `AsyncValue.error(e, stackTrace)` if it threw.

```dart
final result = await AsyncValue.guard<LoginState>(() async {
  final user = await ref.read(loginUserUseCaseProvider).call(params);
  return LoginSuccessState(user);
});
```

Without `guard`, a thrown `Failure` from the use case would bubble up and crash (or leave state stale). With `guard`, the throw is captured as an `AsyncValue.error`, which is why the next block needs `result.when(... error: ...)` to translate it into your `LoginFailedState`.

**Use when:** you're running async work that might throw and you want the failure modeled as state instead of an uncaught exception.

### Quick mental model

| | `AsyncValue.data` | `AsyncValue.guard` |
| --- | --- | --- |
| Kind | constructor | function runner |
| Sync/async | sync | async (returns `Future<AsyncValue>`) |
| Catches errors? | no | yes |
| Typical use | set known state | wrap a use-case call |

### In your file specifically
- Line 30 uses `.data` because you're flipping into a known loading state — there's nothing to await, nothing to catch.
- Line 32 uses `.guard` because `loginUserUseCase.call(params)` is the risky boundary — it can throw a `Failure`, and you want that failure converted into `LoginFailedState` rather than crashing the controller.

That's why they appear back-to-back: `.data` paints the "we're working" state instantly, then `.guard` does the actual work safely.

## Alternate ways to write `firebaseAuthProvider`

The current form in [auth_providers.dart:5-7](lib/core/providers/auth_providers.dart#L5-L7) is:

```dart
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance
);
```

All of the following are equivalent — pick the one that matches your style.

### 1. Single-line arrow form
Most compact; same semantics.
```dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
```

### 2. Block body form
Useful if you later need to add logic (logging, conditional config, etc.) before returning the instance.
```dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
```

### 3. Without the explicit generic type
Dart infers `Provider<FirebaseAuth>` from the return type of `FirebaseAuth.instance`. Slightly less self-documenting but functionally identical.
```dart
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
```

### 4. Riverpod code-generation style (`@riverpod`)
The modern recommended approach if the project adopts `riverpod_generator`. Requires `riverpod_annotation`, `riverpod_generator`, and `build_runner`, plus running `dart run build_runner build` (or `--watch`).

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;
```

The generator emits a `firebaseAuthProvider` you consume exactly like the manual form. `keepAlive: true` mirrors a regular `Provider` (which is kept alive by default); without it the generated provider behaves like `.autoDispose`.

### Which to use?
- **Option 1 or 3** — smallest, no setup, perfect for a SDK-singleton provider like this one.
- **Option 2** — switch to it the moment the body grows past one expression.
- **Option 4** — only worth adopting if you plan to convert the rest of the providers in the project too; mixing generated and manual providers in one file is fine but adds cognitive overhead.
