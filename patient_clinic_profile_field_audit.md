# Patient & Clinic Profile Field Audit

> Cross-referencing all fields across: **Registration (Signup)** → **Edit Profile** → **Backend API** → **Display Screens**
>
> **Date:** 2026-06-13
https://drive.google.com/file/d/1UL7EqzquFuN8ySrT2-AENmPBOst0pZpR/view?usp=drive_link
---

## Legend

| Icon | Meaning |
|------|---------|
| ✅ | Present and working |
| ⚠️ | Present but has an issue |
| ❌ | Missing / not implemented |
| — | Not applicable |

---

# Part 1: Patient Profile

## Field Audit Table

| # | Field | Type | Signup<br>`register_patient_screen` | Edit Profile<br>`edit_patient_profile_screen` | Backend<br>`PatientProfileDto` | Backend<br>`UpdatePatientProfileDto` | Model<br>`PatientProfile` | Display<br>`patient_profile_screen` |
|---|-------|------|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `id` | `int` | — | — | ✅ | — | ✅ | ❌ Not shown |
| 2 | `userId` | `int` | — | — | ✅ | — | ✅ | ❌ Not shown |
| 3 | `fullName` | `string` | ✅ Required | ✅ Editable | ✅ `fullName` | ✅ `fullName?` | ✅ | ✅ **Header** |
| 4 | `phoneNumber` | `string` | ✅ Required | ✅ Editable | ✅ `phoneNumber` | ✅ `phoneNumber?` | ✅ | ✅ **Below name** |
| 5 | `email` | `string?` | ❌ Not captured | ✅ Editable | ✅ `email?` | ✅ `email?` | ✅ | ✅ **Below name** |
| 6 | `gender` | `int?` | ❌ Not captured | ✅ Editable (Male/Female chips) | ✅ `gender?` | ✅ `gender?` | ✅ | ✅ **Health card** |
| 7 | `age` | `int?` | ✅ Required (text input) | ✅ Computed from DoB | ✅ `age?` | ✅ `age?` | ✅ | ✅ **Health card** |
| 8 | `dateOfBirth` | `string?` | ❌ Not captured | ✅ Editable (date picker) | ✅ `dateOfBirth?` | ✅ `dateOfBirth?` | ✅ | ✅ **Health card** |
| 9 | `profileImageUrl` | `string?` | ❌ Not captured | ⚠️ Uploaded ✅ but display ❌ | ✅ `profileImageUrl?` | ✅ `profileImageUrl?` | ✅ | ❌ **Static asset used instead** |
| 10 | `address` | `string?` | ❌ Not captured | ✅ Editable | ✅ `address?` | ✅ `address?` | ✅ | ❌ **Not shown** |
| 11 | `bloodType` | `string?` | ❌ Not captured | ✅ Editable | ✅ `bloodType?` | ✅ `bloodType?` | ✅ | ✅ **Health card** |
| 12 | `allergies` | `string?` | ❌ Not captured | ✅ Editable | ✅ `allergies?` | ✅ `allergies?` | ✅ | ✅ **Health card** |
| 13 | `chronicDiseases` | `string?` | ❌ Not captured | ✅ Editable | ✅ `chronicDiseases?` | ✅ `chronicDiseases?` | ✅ | ✅ **Health card** |
| 14 | `emergencyContactName` | `string?` | ❌ Not captured | ✅ Editable | ✅ `emergencyContactName?` | ✅ `emergencyContactName?` | ✅ | ❌ **Not shown** |
| 15 | `emergencyContactPhone` | `string?` | ❌ Not captured | ✅ Editable | ✅ `emergencyContactPhone?` | ✅ `emergencyContactPhone?` | ✅ | ❌ **Not shown** |

---

## 🔴 Patient Issues

### Issue 1 — MEDIUM: Profile image not displayed on profile screen

**Files:** `patient_profile_screen.dart` (line 108-109)

The profile image is correctly uploaded and saved to the backend (the edit screen includes `profileImageUrl` in the save payload). However, the display screen uses a **static asset** instead of the dynamic URL:

```dart
// patient_profile_screen.dart line 106-109
const CircleAvatar(
  radius: 50,
  backgroundColor: AppColors.primary100,
  backgroundImage: AssetImage(AssetPaths.patientProfile1),  // 🔴 Static
),
```

The `_profile?.profileImageUrl` field is never referenced in the build method.

**Impact:** Users upload a profile photo but it's never shown to them.

---

### Issue 2 — MEDIUM: `address`, `emergencyContactName`, `emergencyContactPhone` editable but never displayed

These 3 fields are correctly loaded from the API, populated in the edit form, and saved back. But the profile screen (`patient_profile_screen.dart`) only shows: name, email, phone, dateOfBirth, age, gender, bloodType, allergies, chronicDiseases.

**Impact:** Users can enter emergency contact info but never verify what's stored.

---

### Issue 3 — LOW: Gender enum type mismatch (string vs integer)

**Files:** `user_models.dart` lines 104-114, `API_DOCUMENTATION.md` line 546

The backend `UpdatePatientProfileDto` expects `gender` as a **number** (Gender enum: `0`=Male, `1`=Female):

```typescript
interface UpdatePatientProfileDto {
  gender?: number; // Gender enum
}
```

But `PatientProfile.toJson()` converts it to a **string**:

```dart
// user_models.dart line 122
'gender': _genderToString(gender),  // Returns "Male" or "Female" ⚠️
```

The `_parseGender()` in `fromJson` handles both int and string inputs, so reading works. But saving may fail silently or be ignored by the backend.

---

### Issue 4 — LOW: Extra fields (`id`, `userId`) sent in update payload

`PatientProfile.toJson()` includes `id` and `userId` which are not part of `UpdatePatientProfileDto`. The backend likely ignores them, but it's unnecessary.

```dart
// user_models.dart lines 116-132
Map<String, dynamic> toJson() {
  return {
    'id': id,                    // ❌ Not needed for update
    'userId': userId,            // ❌ Not needed for update
    'fullName': fullName,
    // ...
  };
}
```

---

## Patient Data Flow

```
┌────────────────────────────────────────────────────────┐
│              REGISTRATION                              │
│  register_patient_screen.dart                          │
│  POST /api/auth/register/patient                       │
│                                                        │
│  ✅ name (required)                                    │
│  ✅ phone (required)                                   │
│  ✅ age (required in form)                             │
│  ✅ password + confirmPassword                         │
│  ❌ email, gender, dateOfBirth, profileImage,          │
│     address, bloodType, allergies, chronicDiseases,    │
│     emergencyContactName, emergencyContactPhone        │
└──────────────────────┬─────────────────────────────────┘
                       │ Account created with minimal info
                       ▼
┌────────────────────────────────────────────────────────┐
│              EDIT PROFILE (Post-Registration)           │
│  edit_patient_profile_screen.dart                      │
│  PUT /api/patient/profile                              │
│                                                        │
│  ✅ fullName           ✅ dateOfBirth                   │
│  ✅ phoneNumber        ✅ address                       │
│  ✅ email              ✅ bloodType                     │
│  ✅ gender             ✅ allergies                     │
│  ✅ profileImageUrl    ✅ chronicDiseases               │
│                        ✅ emergencyContactName          │
│                        ✅ emergencyContactPhone         │
└──────────────────────┬─────────────────────────────────┘
                       │ All fields sent via PatientProfile.toJson()
                       ▼
┌────────────────────────────────────────────────────────┐
│              DISPLAY SCREEN                             │
│  patient_profile_screen.dart                           │
│                                                        │
│  ✅ fullName            ✅ dateOfBirth                  │
│  ✅ phoneNumber         ✅ age                          │
│  ✅ email               ✅ gender                       │
│  ⚠️ profileImageUrl     ✅ bloodType                    │
│    (static asset used)  ✅ allergies                    │
│                         ✅ chronicDiseases              │
│  ❌ address                                              │
│  ❌ emergencyContactName                                 │
│  ❌ emergencyContactPhone                                │
└────────────────────────────────────────────────────────┘
```

---

# Part 2: Clinic Profile

## Field Audit Table

| # | Field | Type | Signup<br>`register_clinic_screen` | Edit Profile<br>`edit_clinic_profile_screen` | Backend<br>`ClinicDto` | Backend<br>`UpdateClinicDto` | Model<br>`ClinicProfile` | Display<br>`clinic_profile_screen` |
|---|-------|------|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `id` | `int` | — | — | ✅ | — | ✅ | ❌ Not shown |
| 2 | `name` | `string` | ✅ Required (`clinicName`) | ✅ Editable (`name`) | ✅ | ✅ `name?` | ✅ | ✅ **Header** |
| 3 | `facilityId` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Info section** |
| 4 | `description` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Info section** |
| 5 | `government` | `string` | ✅ Required (dropdown) | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Location section** |
| 6 | `area` | `string` | ✅ Required (dropdown) | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Location section** |
| 7 | `address` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Location section** |
| 8 | `linkMap` | `string?` | ❌ Not captured in Flutter (but in RegisterClinicDto) | ❌ Not editable | ✅ | ✅ | ❌ **Not in model** | ❌ Not shown |
| 9 | `phoneNumber` | `string` | ✅ Required (`phone`) | ✅ Editable (`phoneNumber`) | ✅ | ✅ `phoneNumber?` | ✅ | ✅ **Contact section** |
| 10 | `email` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Contact section** |
| 11 | `logoUrl` | `string?` | ❌ Not captured | ⚠️ **Uploaded but NEVER saved** | ✅ `logoUrl?` | ❌ Not in UpdateClinicDto | ✅ | ✅ **Header** |
| 12 | `licenseImageUrl` | `string?` | ✅ Captured (`licenseFileUrl`) | ❌ Not editable | ✅ | ❌ Not in UpdateClinicDto | ✅ | ❌ Not shown |
| 13 | `latitude` | `number?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Coordinates section** |
| 14 | `longitude` | `number?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Coordinates section** |
| 15 | `openingTime` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Hours section** |
| 16 | `closingTime` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Hours section** |
| 17 | `isActive` | `bool` | — (read-only) | ❌ Not editable | ✅ | ❌ Not in UpdateClinicDto | ✅ | ✅ **Header badge** |
| 18 | `doctorsCount` | `int` | — (read-only) | — | ✅ | — | ✅ | ✅ **Info section** |

---

## 🔴 Clinic Issues

### Issue 1 — CRITICAL: Logo URL never persisted (same pattern as Doctor)

**Files:** `edit_clinic_profile_screen.dart`

`_pickAndUploadLogo()` uploads the logo via `POST /api/upload/profile-image` and stores the returned URL in `_logoUrl` state. But `_saveProfile()` builds a data map that does **NOT** include `logoUrl`:

```dart
// edit_clinic_profile_screen.dart lines 117-130
final data = {
  'name': _nameController.text.trim(),
  'facilityId': ...,
  'description': ...,
  'government': ...,
  'area': ...,
  'address': ...,
  'phoneNumber': ...,
  'email': ...,
  'latitude': ...,
  'longitude': ...,
  'openingTime': ...,
  'closingTime': ...,
  // ❌ 'logoUrl': _logoUrl,   <-- MISSING
};
```

Additionally, even if it were included, `logoUrl` is **not** in the backend's `UpdateClinicDto`:

```typescript
interface UpdateClinicDto {
  name?: string;
  // ... all other fields
  // ❌ No logoUrl field
}
```

This means the logo upload is functional (file stored on server) but there is **no way** to link it to the clinic profile through the update endpoint. The backend would need a separate field or endpoint for the logo.

**Note:** The `RegisterClinicDto` also doesn't include `logoUrl`, so the logo can never be set through any API path.

---

### Issue 2 — LOW: `linkMap` dropped at every level

| Stage | Status |
|-------|--------|
| Backend `ClinicDto` | ✅ Returns `linkMap?` |
| Backend `UpdateClinicDto` | ✅ Accepts `linkMap?` |
| `RegisterClinicDto` | Has `linkMap?` but Flutter doesn't send it |
| Dart `ClinicProfile` model | ❌ `linkMap` not parsed |
| Edit profile | ❌ No field for linkMap |
| Display screen | ❌ Not shown |

The `linkMap` field exists in the backend schema and is accepted by update, but is invisible to the Flutter app entirely.

---

### Issue 3 — LOW: `licenseImageUrl` never displayed

The license image URL is set at registration and returned by the API, but no screen shows it. The clinic admin has no way to view the license they uploaded.

---

## Clinic Data Flow

```
┌────────────────────────────────────────────────────────┐
│              REGISTRATION                              │
│  register_clinic_screen.dart                           │
│  POST /api/auth/register/clinic                       │
│                                                        │
│  ✅ clinicName (required)                               │
│  ✅ government (required)                               │
│  ✅ area (required)                                     │
│  ✅ phone (required)                                    │
│  ✅ password + confirmPassword                          │
│  ✅ licenseFileUrl (required upload)                    │
│  ✅ address (optional)                                  │
│  ✅ email (optional)                                    │
│  ✅ latitude (optional)                                 │
│  ✅ longitude (optional)                                │
│  ✅ openingTime (optional)                              │
│  ✅ closingTime (optional)                              │
│  ❌ logoUrl                                              │
│  ❌ facilityId                                           │
│  ❌ description                                          │
└──────────────────────┬─────────────────────────────────┘
                       │ Account + Clinic created together
                       ▼
┌────────────────────────────────────────────────────────┐
│              EDIT PROFILE (Post-Registration)           │
│  edit_clinic_profile_screen.dart                       │
│  PUT /api/clinic/profile                               │
│                                                        │
│  ✅ name              ✅ address                        │
│  ✅ facilityId        ✅ phoneNumber                    │
│  ✅ description       ✅ email                          │
│  ✅ government        ✅ latitude                       │
│  ✅ area              ✅ longitude                      │
│  ⚠️ logoUrl           ✅ openingTime                    │
│    (uploaded but      ✅ closingTime                    │
│     NOT in save payload)                               │
│                                                        │
│  ❌ linkMap (not captured anywhere after registration)  │
└──────────────────────┬─────────────────────────────────┘
                       │ Update payload sent raw to API
                       ▼
┌────────────────────────────────────────────────────────┐
│              DISPLAY SCREEN                             │
│  clinic_profile_screen.dart                            │
│                                                        │
│  ✅ name              ✅ area                           │
│  ✅ logoUrl           ✅ address                        │
│  ✅ isActive           ✅ phoneNumber                    │
│  ✅ facilityId        ✅ email                          │
│  ✅ description       ✅ latitude                       │
│  ✅ doctorsCount      ✅ longitude                      │
│  ✅ government        ✅ openingTime                    │
│                       ✅ closingTime                    │
│  ❌ linkMap                                              │
│  ❌ licenseImageUrl                                      │
└────────────────────────────────────────────────────────┘
```

---

# Summary of All Issues

| # | Profile | Severity | Field | Problem |
|---|---------|----------|-------|---------|
| **P1** | Patient | **MEDIUM** | `profileImageUrl` | Correctly saved to API but display uses static asset — users never see their photo |
| **P2** | Patient | **MEDIUM** | `address`, `emergencyContactName`, `emergencyContactPhone` | Loaded & saved but never displayed anywhere |
| **P3** | Patient | **LOW** | `gender` | API expects int (0/1) but Flutter sends string ("Male"/"Female") |
| **P4** | Patient | **LOW** | `id`, `userId` | Sent in update payload but not part of `UpdatePatientProfileDto` |
| **C1** | Clinic | **CRITICAL** | `logoUrl` | Uploaded but **never included in save data** — same bug pattern as Doctor's profileImageUrl. Also `logoUrl` is not in `UpdateClinicDto` at all |
| **C2** | Clinic | **LOW** | `linkMap` | Returned by API, accepted in update, but ignored at every Flutter level (model, edit, display) |
| **C3** | Clinic | **LOW** | `licenseImageUrl` | Stored from registration but never displayed |

---

## Cross-Profile Bug Pattern: Image Upload Not Saved

Three profiles share the **exact same bug pattern**:

| Profile | Field | Upload Method | Saved? | Reason |
|---------|-------|--------------|:------:|--------|
| **Doctor** | `profileImageUrl` | `_pickAndUploadPhoto()` → stored in `_profileImageUrl` | ❌ | `_saveProfile()` data map omits it |
| **Patient** | `profileImageUrl` | `_pickAndUploadPhoto()` → stored in `_profileImageUrl` | ✅ | Included in `PatientProfile` constructor |
| **Clinic** | `logoUrl` | `_pickAndUploadLogo()` → stored in `_logoUrl` | ❌ | `_saveProfile()` data map omits it + `UpdateClinicDto` has no `logoUrl` field |

**Doctor and Clinic** need the same fix: include the image URL in the save payload.  
**Clinic** additionally requires either a backend change to accept `logoUrl` in `UpdateClinicDto`, or a separate upload endpoint for logos.

---

## Registration Completeness Comparison

| Profile | Signup Captures | Post-Registration Edit Covers | Gap |
|---------|----------------|------------------------------|-----|
| **Doctor** | name, phone, email*, password, specialization, licenseFileUrl | Everything else (13 fields) | Email sent at signup but backend `RegisterDoctorDto` ignores it |
| **Patient** | name, phone, age, password | Everything else (10 fields) | No email at signup — must be added later |
| **Clinic** | clinicName, government, area, address, phone, email, lat/lng, opening/closing time, licenseFileUrl | Adds: facilityId, description | `logoUrl`, `linkMap` never captured after registration |

*\*email sent by Flutter but not in backend RegisterDoctorDto*
