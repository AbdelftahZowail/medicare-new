# FCM Push Notifications — Implementation Plan

**Stack**: Flutter (frontend) + .NET 8 (backend) + SQL Server  
**Objective**: Add Firebase Cloud Messaging push notifications alongside existing in-app DB notifications.

---

## Phase 0 — Firebase Console (one-time, external)

### Steps
1. Go to [Firebase Console](https://console.firebase.google.com/), create a new project (or reuse existing).
2. **Register Android app** with package name `com.example.medicare` (matches `android/app/build.gradle.kts` line 24).
3. Download `google-services.json` → place at `android/app/google-services.json`.
4. **Register iOS app** with bundle ID (check `ios/Runner.xcodeproj` — likely `com.example.medicare`).
   - Upload APNs authentication key in Cloud Messaging tab (requires Apple Developer account).
   - Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`.
5. **Backend**: Go to Project Settings → Service accounts → "Generate new private key" → download the JSON file.
   - Store securely at `medicare-backend/Firebase/serviceAccountKey.json` (add to `.gitignore`).
   - Set environment variable on VPS: `GOOGLE_APPLICATION_CREDENTIALS=/opt/medicare-backend/Firebase/serviceAccountKey.json`

**For Phase 0, you can use `flutterfire configure` CLI instead of manual file downloads**:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
```
This auto-generates `firebase_options.dart` and configures Gradle plugins.

---

## Phase 1 — Flutter Frontend (files to touch: 8 create + 5 modify)

### 1.1 Add Dependencies

**File**: `pubspec.yaml` (root)

Add:
```yaml
dependencies:
  firebase_core: ^4.10.0
  firebase_messaging: ^16.3.0
```

Run: `flutter pub get`

### 1.2 Android Gradle Configuration

**File**: `android/settings.gradle.kts` (line 20-24)

Add `google-services` plugin:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version "4.4.4" apply false
    // END: FlutterFire Configuration
}
```

**File**: `android/app/build.gradle.kts` (lines 1-6)

Add `google-services` plugin:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("dev.flutter.flutter-gradle-plugin")
}
```

Also set explicit `minSdk = 21` (Firebase messaging requires API 21+):
```kotlin
defaultConfig {
    applicationId = "com.example.medicare"
    minSdk = 21          // was flutter.minSdkVersion — explicitly set to 21
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

### 1.3 Initialize Firebase in main.dart

**File**: `lib/main.dart`

Replace `void main()` with async init:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import fcm_service.dart (will be created)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MedicareApp());
}
```

### 1.4 Create FCM Service (NEW)

**File**: `lib/core/services/fcm_service.dart` — singleton pattern matching existing services:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import '../constants/app_constants.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final ApiService _api = ApiService();

  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  Future<void> registerToken(String token) async {
    await _api.post(
      ApiEndpoints.registerFcmToken,
      data: {'token': token},
      fromJson: (_) => null,
    );
  }

  Future<void> deleteToken() async {
    try {
      await _api.delete(ApiEndpoints.registerFcmToken);
    } catch (_) {}
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permissions (required on iOS 13+)
    await requestPermission();

    // Get initial token
    final token = await getToken();
    if (token != null) {
      await registerToken(token);
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) {
      registerToken(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground push: ${message.notification?.title}');
      // Optionally show a local notification or badge update
    });

    // Handle notification tap from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Handle notification that opened app from terminated state
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    final relatedId = message.data['relatedId'];
    if (type == null || relatedId == null) return;
    // Navigate based on type (same pattern as notifications_screen.dart)
    // type: 'appointment', 'queue', 'community'
    // Use AppRouter.navigatorKey.currentContext for navigation
  }
}
```

### 1.5 Create Background Handler (NEW — top-level function, required by FCM)

**File**: `lib/core/services/fcm_background_handler.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background push: ${message.messageId}');
  // Background handling — no UI, just logging.
  // If you need to update badge/store notification, make an API call here.
}
```

### 1.6 Register Background Handler in main.dart

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize FCM service
  await FcmService().init();

  runApp(const MedicareApp());
}
```

### 1.7 Register FCM Token After Login

**File**: `lib/core/bloc/auth_bloc.dart` — modify `_onAuthLoginRequested` (line 124) and all register handlers:

After `emit(AuthAuthenticated(...))` on line 135, add:
```dart
// Register FCM push notification token
try {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FcmService().registerToken(token);
  }
} catch (_) {
  // Non-blocking — push notifications can fail silently
}
```

Same for register handlers (lines 144-202) after successful registration.

### 1.8 Delete Token on Logout

**File**: `lib/core/bloc/auth_bloc.dart` — modify `_onAuthLogoutRequested` (line 204):
```dart
Future<void> _onAuthLogoutRequested(
  AuthLogoutRequested event,
  Emitter<AuthState> emit,
) async {
  if (state is AuthUnauthenticated) return;
  emit(AuthLoading());
  await FcmService().deleteToken();  // NEW
  await _authService.logout();
  emit(const AuthUnauthenticated());
}
```

### 1.9 Add API Endpoint Constant

**File**: `lib/core/constants/app_constants.dart` — add to `ApiEndpoints` class:
```dart
// Push Notifications
static const String registerFcmToken = '$apiBase/notification/fcm-token';
```

### 1.10 AndroidManifest.xml — Notification Permission

**File**: `android/app/src/main/AndroidManifest.xml`

Add before `<application>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Phase 2 — Backend .NET API (files to touch: 6 create + 5 modify)

### 2.1 Install NuGet Package

Run from `medicare-backend/`:
```bash
dotnet add package FirebaseAdmin --version 3.5.0
```

### 2.2 Add FcmToken to User Entity (Option A — simplest)

**File**: `medicare-backend/Models/Entities/User.cs` — add field after line 38:
```csharp
[MaxLength(500)]
public string? FcmToken { get; set; }
```

### 2.3 (OR) Create DeviceToken Entity (Option B — multi-device)

**NEW File**: `medicare-backend/Models/Entities/DeviceToken.cs`:
```csharp
namespace MedicalApp.API.Models.Entities
{
    public class DeviceToken : BaseEntity
    {
        public int UserId { get; set; }
        public string Token { get; set; } = string.Empty;
        public User User { get; set; } = null!;
    }
}
```

Add to DbContext:
```csharp
public DbSet<DeviceToken> DeviceTokens { get; set; }
```

Add to IUnitOfWork:
```csharp
IGenericRepository<DeviceToken> DeviceTokens { get; }
```

**Recommended**: Start with Option A (simplest), migrate to Option B if multi-device needed.

### 2.4 Generate EF Core Migration

```bash
cd medicare-backend
dotnet ef migrations add AddFcmToken
dotnet ef migrations add AddDeviceTokenTable  # if Option B
```

Migrations auto-apply at startup (Program.cs line 196).

### 2.5 Create Firebase Push Notification Service

**NEW interface**: `medicare-backend/Services/Interfaces/IFirebaseNotificationService.cs`:
```csharp
namespace MedicalApp.API.Services.Interfaces
{
    public interface IFirebaseNotificationService
    {
        Task SendToUserAsync(int userId, string title, string body, string? type = null, int? relatedId = null);
        Task SendToMultipleUsersAsync(IEnumerable<int> userIds, string title, string body, string? type = null, int? relatedId = null);
    }
}
```

**NEW implementation**: `medicare-backend/Services/Implementations/FirebaseNotificationService.cs`:
```csharp
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using MedicalApp.API.Data.Repositories;
using Microsoft.EntityFrameworkCore;

namespace MedicalApp.API.Services.Implementations
{
    public class FirebaseNotificationService : IFirebaseNotificationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<FirebaseNotificationService> _logger;

        public FirebaseNotificationService(IUnitOfWork unitOfWork, ILogger<FirebaseNotificationService> logger)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task SendToUserAsync(int userId, string title, string body, string? type = null, int? relatedId = null)
        {
            try
            {
                var user = await _unitOfWork.Users.GetByIdAsync(userId);
                if (user?.FcmToken == null) return;

                var message = new Message
                {
                    Token = user.FcmToken,
                    Notification = new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    Data = new Dictionary<string, string>
                    {
                        ["type"] = type ?? "",
                        ["relatedId"] = relatedId?.ToString() ?? ""
                    }
                };

                await FirebaseMessaging.DefaultInstance.SendAsync(message);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to send Firebase push to user {UserId}", userId);
            }
        }

        public async Task SendToMultipleUsersAsync(IEnumerable<int> userIds, string title, string body, string? type = null, int? relatedId = null)
        {
            var tokens = await _unitOfWork.Users.Query()
                .Where(u => userIds.Contains(u.Id) && u.FcmToken != null)
                .Select(u => u.FcmToken!)
                .ToListAsync();

            if (tokens.Count == 0) return;

            // Firebase supports batch via MulticastMessage (max 500 tokens per call)
            foreach (var chunk in tokens.Chunk(500))
            {
                try
                {
                    var message = new MulticastMessage
                    {
                        Tokens = chunk,
                        Notification = new Notification
                        {
                            Title = title,
                            Body = body
                        },
                        Data = new Dictionary<string, string>
                        {
                            ["type"] = type ?? "",
                            ["relatedId"] = relatedId?.ToString() ?? ""
                        }
                    };

                    var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message);
                    _logger.LogInformation("Sent {Success}/{Total} FCM pushes", response.SuccessCount, response.TotalCount);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to send Firebase multicast push");
                }
            }
        }
    }
}
```

### 2.6 Initialize FirebaseApp in Program.cs

**File**: `medicare-backend/Program.cs` — add after line 21 (`AddHttpClient`):
```csharp
// ===== Firebase Admin SDK =====
var firebaseCredPath = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS")
    ?? builder.Configuration.GetSection("Firebase")["CredentialPath"];
if (!string.IsNullOrEmpty(firebaseCredPath) && File.Exists(firebaseCredPath))
{
    FirebaseApp.Create(new AppOptions
    {
        Credential = GoogleCredential.FromFile(firebaseCredPath)
    });
}
```

### 2.7 Register FirebaseNotificationService in DI

**File**: `medicare-backend/Program.cs` — add after line 90:
```csharp
builder.Services.AddScoped<IFirebaseNotificationService, FirebaseNotificationService>();
```

### 2.8 Create FCM Token Registration Endpoint

**NEW file or add to existing**: `medicare-backend/Controllers/NotificationController.cs` — add:
```csharp
[HttpPost("fcm-token")]
public async Task<IActionResult> RegisterFcmToken([FromBody] FcmTokenDto dto)
{
    var userId = GetUserId();
    var user = await _unitOfWork.Users.GetByIdAsync(userId);
    if (user == null)
        return Unauthorized();

    user.FcmToken = dto.Token;
    _unitOfWork.Users.Update(user);
    await _unitOfWork.CompleteAsync();

    return Ok(ApiResponse.Success());
}

[HttpDelete("fcm-token")]
public async Task<IActionResult> DeleteFcmToken()
{
    var userId = GetUserId();
    var user = await _unitOfWork.Users.GetByIdAsync(userId);
    if (user != null)
    {
        user.FcmToken = null;
        _unitOfWork.Users.Update(user);
        await _unitOfWork.CompleteAsync();
    }
    return Ok(ApiResponse.Success());
}
```

**NEW DTO**: `medicare-backend/DTOs/Notification/FcmTokenDto.cs`:
```csharp
namespace MedicalApp.API.DTOs.Notification
{
    public class FcmTokenDto
    {
        public string Token { get; set; } = string.Empty;
    }
}
```

### 2.9 Add Firebase Config to appsettings.json

**File**: `medicare-backend/appsettings.json` — add:
```json
{
  "Firebase": {
    "CredentialPath": "Firebase/serviceAccountKey.json"
  }
}
```

### 2.10 Integrate Push Into Existing Notification Senders

**File**: `medicare-backend/Services/Implementations/AppointmentService.cs`

Inject `IFirebaseNotificationService` into constructor (line 17):
```csharp
private readonly IFirebaseNotificationService _firebaseService;

public AppointmentService(
    IUnitOfWork unitOfWork,
    ILogger<AppointmentService> logger,
    IFirebaseNotificationService firebaseService)  // NEW
{
    _unitOfWork = unitOfWork;
    _logger = logger;
    _firebaseService = firebaseService;
}
```

Add push after each existing `_unitOfWork.Notifications.AddAsync(notification)`:
```csharp
// After notifying patient:
await _firebaseService.SendToUserAsync(patient.UserId, "Booking confirmed", $"Your appointment with Dr. {doctor.User.FullName} on ...");

// After notifying doctor:
await _firebaseService.SendToUserAsync(doctor.UserId, "New booking", $"Patient {patient.User.FullName} booked on ...");

// After notifying clinic admins:
await _firebaseService.SendToMultipleUsersAsync(adminUserIds, "New booking", $"Dr. {doctor.User.FullName} - Patient {patient.User.FullName}");
```

**Repeat for**: `CancelAppointmentAsync`, `CreateClinicAppointmentAsync`, `RescheduleAppointmentAsync`.

**File**: `medicare-backend/Services/Implementations/DoctorService.cs`

Same injection pattern. Add push in `SendConsultationCompletedNotificationAsync`:
```csharp
await _firebaseService.SendToUserAsync(patient.UserId, "Consultation completed", $"Your consultation with Dr. ...");
```

**File**: `medicare-backend/Services/Implementations/AppointmentReminderWorker.cs`

Same injection pattern. Add push when sending reminder:
```csharp
await _firebaseService.SendToUserAsync(patient.UserId, "Appointment reminder", "You have an appointment in 1 hour");
```

---

## Phase 3 — Verification & Testing

### 3.1 Local Build
```bash
# Flutter
cd medicare
flutter pub get
flutter run --debug

# Backend
cd medicare-backend
dotnet build
dotnet run
```

### 3.2 Test Flow
1. Login as patient → FCM token registered
2. Book appointment → push received on doctor's device
3. Doctor completes consultation → push received on patient's device
4. Cancel appointment → push received on clinic admin's device
5. Logout → FCM token deleted

### 3.3 Diagnostic Commands (VPS)
```bash
# Check backend logs for FCM sends
ssh -i C:\Users\Zowail\.ssh\openclaw_proxy ubuntu@140.238.97.203
sudo journalctl -u medicare-backend -n 50 --no-pager
# Look for: "Sent X/Y FCM pushes" or "Failed to send Firebase push"
```

---

## Files Summary

### Flutter — NEW files (3)
| # | File | Purpose |
|---|---|---|
| 1 | `lib/core/services/fcm_service.dart` | Token registration, permission request, init |
| 2 | `lib/core/services/fcm_background_handler.dart` | Top-level background message handler |
| 3 | `android/app/google-services.json` | Firebase Android config (download) |

### Flutter — MODIFIED files (7)
| # | File | Change |
|---|---|---|
| 1 | `pubspec.yaml` | Add `firebase_core`, `firebase_messaging` |
| 2 | `android/settings.gradle.kts` | Add google-services plugin |
| 3 | `android/app/build.gradle.kts` | Add google-services plugin, minSdk=21 |
| 4 | `android/app/src/main/AndroidManifest.xml` | Add POST_NOTIFICATIONS permission |
| 5 | `lib/main.dart` | Firebase init, background handler, FcmService init |
| 6 | `lib/core/bloc/auth_bloc.dart` | Register token on login, delete on logout |
| 7 | `lib/core/constants/app_constants.dart` | Add `registerFcmToken` endpoint |

### iOS (optional) — MODIFIED files (2)
| # | File | Change |
|---|---|---|
| 1 | `ios/Runner/AppDelegate.swift` | Add UNUserNotificationCenter delegate |
| 2 | `ios/Runner/GoogleService-Info.plist` | Firebase iOS config (download) |

### Backend — NEW files (3)
| # | File | Purpose |
|---|---|---|
| 1 | `Services/Interfaces/IFirebaseNotificationService.cs` | Interface |
| 2 | `Services/Implementations/FirebaseNotificationService.cs` | Send push via FirebaseAdmin SDK |
| 3 | `DTOs/Notification/FcmTokenDto.cs` | DTO for token registration |

### Backend — MODIFIED files (6)
| # | File | Change |
|---|---|---|
| 1 | `Models/Entities/User.cs` | Add `FcmToken` property |
| 2 | `Program.cs` | Init FirebaseApp, register service in DI |
| 3 | `Controllers/NotificationController.cs` | Add `POST/DELETE fcm-token` endpoints |
| 4 | `Services/Implementations/AppointmentService.cs` | Inject + send push after each notification |
| 5 | `Services/Implementations/DoctorService.cs` | Inject + send push after notification |
| 6 | `Services/Implementations/AppointmentReminderWorker.cs` | Inject + send push for reminders |
| 7 | `MedicalApp.API.csproj` | Add FirebaseAdmin NuGet reference |
| 8 | `appsettings.json` | Add Firebase config section |

---

## Architecture Flow

```
Flutter App
  │
  ├─ Login → AuthBloc emits AuthAuthenticated
  │           └─ FcmService.registerToken(token) → POST /api/notification/fcm-token
  │
  ├─ FCM token refresh → FcmService.onTokenRefresh → POST /api/notification/fcm-token
  │
  ├─ Foreground push → FirebaseMessaging.onMessage → show snackbar / update badge
  │
  ├─ Background push → firebaseMessagingBackgroundHandler → logged
  │
  └─ Notification tap → onMessageOpenedApp / getInitialMessage → navigate by type

Backend API
  │
  ├─ POST /api/notification/fcm-token → save FcmToken on User
  │
  ├─ AppointmentService.CreateAppointmentAsync()
  │   ├─ _unitOfWork.Notifications.AddAsync(...)  // existing DB notification
  │   └─ _firebaseService.SendToUserAsync(...)      // NEW: FCM push
  │
  ├─ DoctorService.SendConsultationCompletedNotificationAsync()
  │   ├─ _unitOfWork.Notifications.AddAsync(...)    // existing DB notification
  │   └─ _firebaseService.SendToUserAsync(...)      // NEW: FCM push
  │
  └─ AppointmentReminderWorker
      ├─ _unitOfWork.Notifications.AddAsync(...)    // existing DB notification
      └─ _firebaseService.SendToUserAsync(...)      // NEW: FCM push
```

---

## Rollback Plan

If push notifications cause issues:

**Backend**: Remove `IFirebaseNotificationService` injection from constructors and Program.cs. The DB notifications continue working independently.

**Flutter**: Comment out `FcmService().init()` in main.dart and remove FCM token calls from auth_bloc.dart. App works with in-app notifications only.
