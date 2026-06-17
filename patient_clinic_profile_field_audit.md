# Patient, Doctor & Clinic Profile Field Audit

> Cross-referencing all fields across: **Registration (Signup)** → **Edit Profile** → **Backend API** → **Display Screens**
>
> **Date:** 2026-06-17 — **UPDATED** after fixes applied (see §Fixes Applied)

---

## Legend

| Icon | Meaning |
|------|---------|
| ✅ | Present and working |
| ⚠️ | Present but has an issue |
| ❌ | Missing / not implemented |
| — | Not applicable |
| 🔧 | Fixed (was broken, now works) |

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
| 9 | `profileImageUrl` | `string?` | ❌ Not captured | 🔧 Uploaded ✅ + save ✅ + display ✅ | ✅ `profileImageUrl?` | ✅ `profileImageUrl?` | ✅ | 🔧 **NetworkImage + icon fallback** |
| 10 | `address` | `string?` | ❌ Not captured | ✅ Editable | ✅ `address?` | ✅ `address?` | ✅ | 🔧 **Emergency Contact section** |
| 11 | `bloodType` | `string?` | ❌ Not captured | ✅ Editable | ✅ `bloodType?` | ✅ `bloodType?` | ✅ | ✅ **Health card** |
| 12 | `allergies` | `string?` | ❌ Not captured | ✅ Editable | ✅ `allergies?` | ✅ `allergies?` | ✅ | ✅ **Health card** |
| 13 | `chronicDiseases` | `string?` | ❌ Not captured | ✅ Editable | ✅ `chronicDiseases?` | ✅ `chronicDiseases?` | ✅ | ✅ **Health card** |
| 14 | `emergencyContactName` | `string?` | ❌ Not captured | ✅ Editable | ✅ `emergencyContactName?` | ✅ `emergencyContactName?` | ✅ | 🔧 **Emergency Contact section** |
| 15 | `emergencyContactPhone` | `string?` | ❌ Not captured | ✅ Editable | ✅ `emergencyContactPhone?` | ✅ `emergencyContactPhone?` | ✅ | 🔧 **Emergency Contact section** |

---

## Patient Data Flow (CURRENT)

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
│     → By design — signup is minimal                    │
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
│  ⚠️ _ageController is a DEAD controller (see below)    │
└──────────────────────┬─────────────────────────────────┘
                       │ All fields sent via PatientProfile.toJson()
                       │ (id, userId removed — clean payload)
                       ▼
┌────────────────────────────────────────────────────────┐
│              DISPLAY SCREEN                             │
│  patient_profile_screen.dart                           │
│                                                        │
│  ✅ fullName            ✅ dateOfBirth                  │
│  ✅ phoneNumber         ✅ age                          │
│  ✅ email               ✅ gender                       │
│  🔧 profileImageUrl     ✅ bloodType                    │
│    (NetworkImage +      ✅ allergies                    │
│     icon fallback)      ✅ chronicDiseases              │
│  🔧 address             🔧 emergencyContactName          │
│  🔧 emergencyContactPhone                               │
└────────────────────────────────────────────────────────┘
```

---

## ⚠️ Known Issue: Dead `_ageController` in edit screen

**File:** `edit_patient_profile_screen.dart`

The controller `_ageController` is declared, created, and disposed — but:
- Never bound to any UI widget
- Never populated from the loaded profile
- Never read in `_saveProfile()`
- Age is instead correctly computed from `_dateOfBirth` via `_computeAge()`

This is a leftover from an earlier version. It's harmless (just unused memory) but should be removed for cleanliness.

---

# Part 2: Doctor Profile

## Field Audit Table

| # | Field | Type | Signup<br>`register_doctor_screen` | Edit Profile<br>`edit_doctor_profile_screen` | Backend<br>`DoctorProfileDto` | Backend<br>`UpdateDoctorProfileDto` | Model<br>`DoctorProfile` | Display<br>`doctor_profile_screen` |
|---|-------|------|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `fullName` | `string` | ✅ Required (`name`) | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 2 | `phoneNumber` | `string` | ✅ Required (`phone`) | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 3 | `email` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 4 | `specialization` | `string` | ✅ Required (dropdown) | ✅ Editable (bottom sheet) | ✅ | ✅ | ✅ | ✅ |
| 5 | `subSpecialty` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 6 | `yearsOfExperience` | `int?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 7 | `consultationFee` | `number?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 8 | `bio` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 9 | `degree` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 10 | `university` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 11 | `graduationYear` | `int?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 12 | `boardCertification` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ |
| 13 | `languages` | `list?` | ❌ Not captured | ✅ Editable (comma-sep) | ✅ | ✅ | ✅ | ✅ |
| 14 | `profileImageUrl` | `string?` | ❌ Not captured | 🔧 Uploaded ✅ + save ✅ | ✅ | ✅ | ✅ | 🔧 **NetworkImage + icon fallback** |
| 15 | `licenseImageUrl` | `string?` | ✅ Captured (`licenseFileUrl`) | ❌ Not editable (read-only) | ✅ | ❌ Not in UpdateDoctorDto | ✅ | ❌ Not shown |
| 16 | `isAvailable` | `bool` | ❌ Not captured | ❌ Not editable | ✅ | ✅ | ✅ | ✅ |

**Signup captures 7 fields** (name, phone, email, password, confirmPassword, specialization, licenseFileUrl).  
**Edit captures 14 fields** (all above except license-related, isAvailable, and read-only stats).

---

## Doctor Data Flow

```
┌────────────────────────────────────────────────────────┐
│              REGISTRATION                              │
│  register_doctor_screen.dart                           │
│  POST /api/auth/register/doctor                        │
│                                                        │
│  ✅ name (required)                                    │
│  ✅ phone (required)                                   │
│  ✅ email (optional)                                   │
│  ✅ password + confirmPassword                         │
│  ✅ specialization (required, dropdown)                 │
│  ✅ licenseFileUrl (required upload)                    │
│  ❌ All 13 professional/profile fields                  │
│     → By design — signup is minimal                    │
└──────────────────────┬─────────────────────────────────┘
                       │ Account + Doctor profile created
                       ▼
┌────────────────────────────────────────────────────────┐
│              EDIT PROFILE (Post-Registration)           │
│  edit_doctor_profile_screen.dart                       │
│  PUT /api/doctor/profile                               │
│                                                        │
│  ✅ fullName           ✅ degree                        │
│  ✅ phoneNumber        ✅ university                    │
│  ✅ email              ✅ yearsOfExperience             │
│  ✅ specialization     ✅ graduationYear                │
│  ✅ subSpecialty       ✅ boardCertification            │
│  ✅ profileImageUrl    ✅ languages                     │
│  ✅ consultationFee    ✅ bio                           │
│  → 14 fields total, all wired correctly                │
└──────────────────────┬─────────────────────────────────┘
                       │ Map<String, dynamic> sent via DoctorService
                       ▼
┌────────────────────────────────────────────────────────┐
│              DISPLAY SCREEN                             │
│  doctor_profile_screen.dart (doctor's own view)         │
│                                                        │
│  ✅ fullName, phoneNumber, email, specialization        │
│  ✅ subSpecialty, yearsOfExperience, consultationFee    │
│  ✅ bio, degree, university, graduationYear             │
│  ✅ boardCertification, languages                       │
│  🔧 profileImageUrl (NetworkImage + icon fallback)      │
│  ❌ licenseImageUrl (stored, not displayed)              │
└────────────────────────────────────────────────────────┘
```

---

# Part 3: Clinic Profile

## Field Audit Table

| # | Field | Type | Signup<br>`register_clinic_screen` | Edit Profile<br>`edit_clinic_profile_screen` | Backend<br>`ClinicDto` | Backend<br>`UpdateClinicDto` | Model<br>`ClinicProfile` | Display<br>`clinic_profile_screen` |
|---|-------|------|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `id` | `int` | — | — | ✅ | — | ✅ | ❌ Not shown |
| 2 | `name` | `string` | ✅ Required (`clinicName`) | ✅ Editable (`name`) | ✅ | ✅ `name?` | ✅ | ✅ **Header** |
| 3 | `facilityId` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Info section** |
| 4 | `description` | `string?` | ❌ Not captured | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Info section** |
| 5 | `government` | `string` | ✅ Required (dropdown) | ✅ Editable (text field) | ✅ | ✅ | ✅ | ✅ **Location section** |
| 6 | `area` | `string` | ✅ Required (dropdown) | ✅ Editable (text field) | ✅ | ✅ | ✅ | ✅ **Location section** |
| 7 | `address` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Location section** |
| 8 | `linkMap` | `string?` | ❌ Not captured | 🔧 Editable | ✅ | ✅ | 🔧 ✅ Parsed in model | 🔧 ✅ **Info section** |
| 9 | `phoneNumber` | `string` | ✅ Required (`phone`) | ✅ Editable (`phoneNumber`) | ✅ | ✅ `phoneNumber?` | ✅ | ✅ **Contact section** |
| 10 | `email` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Contact section** |
| 11 | `logoUrl` | `string?` | ❌ Not captured | 🔧 Uploaded ✅ + save ✅ | ✅ `logoUrl?` | 🔧 ✅ Now in DTO | ✅ | ✅ **Header** |
| 12 | `licenseImageUrl` | `string?` | ✅ Captured (`licenseFileUrl`) | ❌ Not editable (read-only) | ✅ | ❌ Not in UpdateDto | ✅ | 🔧 ✅ **License thumbnail** |
| 13 | `latitude` | `number?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Coordinates section** |
| 14 | `longitude` | `number?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Coordinates section** |
| 15 | `openingTime` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Hours section** |
| 16 | `closingTime` | `string?` | ✅ Optional | ✅ Editable | ✅ | ✅ | ✅ | ✅ **Hours section** |
| 17 | `isActive` | `bool` | — (read-only) | ❌ Not editable | ✅ | ❌ Not in UpdateDto | ✅ | ✅ **Header badge** |
| 18 | `doctorsCount` | `int` | — (read-only) | — | ✅ | — | ✅ | ✅ **Info section** |

**Signup captures 14 fields** (clinicName, government, area, address, lat/lng, phone, email, password, confirmPassword, openingTime, closingTime, licenseFileUrl).  
**Edit captures 15 fields** (adds: facilityId, description, linkMap, logoUrl; removes: password, licenseFileUrl — those are registration-only).

Note: Signup uses dropdowns for government/area; Edit uses free-text fields. This is an intentional UX difference.

---

## Clinic Data Flow (CURRENT)

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
│  ❌ logoUrl, facilityId, description, linkMap            │
│     → Added post-registration via Edit Profile          │
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
│  🔧 logoUrl           ✅ openingTime                    │
│    (uploaded AND      ✅ closingTime                    │
│     saved correctly)  ✅ linkMap                        │
│  → 14 fields, all wired correctly                       │
└──────────────────────┬─────────────────────────────────┘
                       │ Update payload sent to API
                       ▼
┌────────────────────────────────────────────────────────┐
│              DISPLAY SCREEN                             │
│  clinic_profile_screen.dart                            │
│                                                        │
│  ✅ name              ✅ area                           │
│  🔧 logoUrl (Network + ✅ address                       │
│     icon fallback)    ✅ phoneNumber                    │
│  ✅ isActive           ✅ email                          │
│  ✅ facilityId        ✅ latitude                       │
│  ✅ description       ✅ longitude                      │
│  ✅ doctorsCount      ✅ openingTime                    │
│  ✅ government        ✅ closingTime                    │
│  🔧 linkMap           🔧 licenseImageUrl (thumbnail)     │
│  → ALL 18 fields displayed                               │
└────────────────────────────────────────────────────────┘
```

---

# Summary: All Issues & Resolution

| # | Profile | Original Severity | Field | Original Problem | Resolution |
|---|---------|-------------------|-------|-----------------|------------|
| **P1** | Patient | MEDIUM | `profileImageUrl` | Saved to API but display used static asset | ✅ **FIXED** — display now uses `NetworkImage(url)` with `Icon(Icons.person)` fallback |
| **P2** | Patient | MEDIUM | `address`, `emergencyContact` | Editable but never displayed | ✅ **FIXED** — "Emergency Contact" section added to profile screen |
| **P3** | Patient | LOW | `gender` | API expects int but Flutter sent string | ✅ **FIXED** — `PatientProfile.toJson()` sends raw int (0/1). `FamilyMember.toJson()` also fixed (was sending "Male"/"Female"). Backend enum is `Male=0, Female=1` |
| **P4** | Patient | LOW | `id`, `userId` | Sent in update payload but not in DTO | ✅ **FIXED** — Removed `id` and `userId` from `PatientProfile.toJson()` |
| **C1** | Clinic | CRITICAL | `logoUrl` | Uploaded but never saved + missing from backend DTO | ✅ **FIXED** — `logoUrl` was already in edit save payload and `UpdateClinicDto`. Display uses `NetworkImage` with icon fallback |
| **C2** | Clinic | LOW | `linkMap` | Ignored at every Flutter level | ✅ **FIXED** — Parsed in `ClinicProfile.fromJson()`, editable in edit screen, displayed in profile screen |
| **C3** | Clinic | LOW | `licenseImageUrl` | Stored but never displayed | ✅ **FIXED** — License thumbnail with expand preview added to clinic profile screen |
| **D1** | Doctor | — | `profileImageUrl` | Same image-not-saved pattern | ✅ **FIXED** — Doctor edit screen already included `profileImageUrl` in save payload. Display uses `NetworkImage` with icon fallback |

---

## Additional Changes Made

| Change | Files |
|--------|-------|
| Removed 12 Unsplash placeholder URLs | `doctor_service.dart`, `patient_service.dart`, `nearby_service.dart` → set to `null` |
| Replaced 10 `AssetImage(AssetPaths.xxx)` fallbacks with icons | All profile/patient-list screens across doctor, clinic, patient features |
| Deleted 19 placeholder PNG files | `assets/images/` — all doctor/family/clinic/patient photo PNGs |
| Removed 17 placeholder `AssetPaths` constants | `app_constants.dart` |
| Added `PatientProfileImageUrl` to `AppointmentDto` | Backend DTO + service — clinic dashboard now shows real patient photos |
| Wired up `profileImageUrl` in 2 screens that had backend data but ignored it | `doctor_patient_history_screen.dart`, `clinic_patient_search_screen.dart` |
| Fixed `FamilyMember.toJson()` gender/relation from string to int | `shared_models.dart` — matches backend enum |
| Cleaned `ClinicProfile.toJson()` — removed read-only fields, added `toFullJson()` for display | `clinic_models.dart` |

---

## ⚠️ Remaining Known Issue

| Item | File | Detail |
|------|------|--------|
| Dead `_ageController` | `edit_patient_profile_screen.dart` | Controller declared, created, disposed — but never used. Age is correctly derived from Date of Birth. Harmless but should be cleaned up. |

---

## Registration Completeness Comparison (CURRENT)

| Profile | Signup Captures | Post-Registration Edit Adds | Gap |
|---------|----------------|------------------------------|-----|
| **Patient** | name, phone, age, password | email, gender, dateOfBirth, profileImageUrl, address, bloodType, allergies, chronicDiseases, emergencyContactName, emergencyContactPhone | By design — signup is minimal |
| **Doctor** | name, phone, email, password, specialization, licenseFileUrl | subSpecialty, yearsOfExperience, consultationFee, bio, degree, university, graduationYear, boardCertification, languages, profileImageUrl | By design — signup is minimal |
| **Clinic** | clinicName, government, area, address, phone, email, lat/lng, opening/closing time, password, licenseFileUrl | facilityId, description, linkMap, logoUrl | By design — signup captures operational basics, edit adds detail |
