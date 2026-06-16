# Medicare Flutter Architecture

## Folder Structure

```
lib/
├── core/              # Shared infrastructure
│   ├── bloc/          # BLoC (business logic — centralized)
│   ├── constants/     # API endpoints, routes, storage keys, assets
│   ├── models/        # Data classes with fromJson/toJson
│   ├── navigation/    # go_router + shell screens
│   ├── services/      # Dio client, auth, API calls
│   ├── theme/         # Colors, text styles, theme data
│   ├── utils/         # Error helpers
│   └── widgets/       # Reusable UI widgets
├── features/          # Feature modules
│   ├── auth/          # Login, register, onboarding screens
│   ├── patient/       # Patient sub-features (home, browse, appointments, community, profile)
│   ├── doctor/        # Doctor screens (dashboard, queue, consultations, profile)
│   ├── clinic/        # Clinic screens (dashboard, doctors, payments, bookings)
│   └── shared/        # Cross-feature shared feature code
└── main.dart          # App entry point
```

> **Note vs diagram**: The actual project uses `core/` as a single umbrella for everything shared, instead of separate `core/`, `shared/`, `router/`, and `models/` top-level folders. Dio, JWT, and interceptors live inside a single `api_service.dart` file rather than separate folders. If you prefer the diagram structure, you could extract: (a) `lib/router/` from `core/navigation/`, (b) `lib/models/` from `core/models/`, and (c) split Dio setup out of `api_service.dart` into `core/dio/`.

---

## State Management — BLoC

**Pattern used:** `flutter_bloc` + `equatable`

```
User Action (UI)
     │
     ▼
  Event          (e.g., AuthLoginRequested)
     │
     ▼
  BLoC           (listens to events, calls service, emits state)
     │
     ▼
  State          (e.g., AuthAuthenticated, AuthFailure)
     │
     ▼
  UI / BlocBuilder  (rebuilds widgets when state changes)
```

**In code:** One centralized `AuthBloc` in `core/bloc/auth_bloc.dart` handles all auth flows (login, register as patient/doctor/clinic, logout, auto-login check). Each event carries a typed request object, the BLoC calls the service layer, and emits a state — either loading, authenticated, unauthenticated, or failure.

> **Note vs diagram**: BLoC is centralized in `core/bloc/` rather than distributed per feature. Feature-specific BLoCs can be added per-feature if needed later.

---

## Backend Communication

```
flutter_secure_storage
  (JWT tokens persisted: access_token, refresh_token, role, user_id, profile_id)
     │
     ▼
Dio + Interceptor (in ApiService)
  • Auto-attaches Authorization: Bearer <token> on every request
  • On 401 → attempts silent refresh via refresh-token endpoint
  • If refresh fails → clears tokens and notifies AuthBloc to logout
     │
     ▼
REST API call  →  JSON response  →  ApiResponse<T> wrapper
                                      └─ fromJson() converts to typed model
     │
     ▼
Response flows back to BLoC → emits new state → UI rebuilds
```

**In code:** `ApiService` (singleton) wraps Dio. It stores tokens in memory, auto-attaches the Bearer header in `onRequest`, and handles 401 retry logic in `onError` — including refresh-token rotation. `AuthService` persists tokens to `FlutterSecureStorage` on login/register and clears them on logout. The callback `onTokensInvalidated` bridges the service layer back to the BLoC.

---

## shared_preferences

Used minimally — currently only to store a `is_first_time` flag (whether onboarding has been shown). Suitable for non-sensitive settings like language preference or UI toggles.

---

## Routing — go_router

- All routes defined in `core/navigation/app_router.dart` as `AppRoutes` string constants.
- Three `StatefulShellRoute.indexedStack` shells (patient, doctor, clinic) provide bottom navigation.
- `refreshListenable: GoRouterRefreshStream(authBloc.stream)` tracks auth state.
- Redirect logic: unauthenticated users → login; authenticated users on auth routes → their role-specific home.

---

## Models

- Plain Dart classes with `fromJson()` / `toJson()` for JSON parsing from the REST API.
- BLoC events and states use `Equatable` for value equality (prevents unnecessary rebuilds).
- `ApiResponse<T>` generic wrapper normalizes all API responses (`isSuccess`, `message`, `data`, `errors`, `statusCode`).

---

## Summary — Data Flow

```
UI (BlocBuilder) ──dispatches──► Event
                                    │
                              BLoC ─┤
                                    │
                              Service (AuthService / PatientService / ...)
                                    │
                              ApiService (Dio + Interceptor)
                                    │
                              Secure Storage ◄──── REST API
```

Shared widgets, theme, and utils live in `core/` and are imported by all features.
