# Doctor Profile Field Audit

> Cross-referencing all fields across: **Registration (Signup)** → **Edit Profile** → **Backend API** → **Display Screens**
>
> **Date:** 2026-06-13

---

## Legend

| Icon | Meaning |
|------|---------|
| ✅ | Present and working |
| ⚠️ | Present but has an issue |
| ❌ | Missing / not implemented |
| — | Not applicable |

---

## Field Audit Table

| # | Field | Type | Signup<br>(`register_doctor_screen`) | Edit Profile<br>(`edit_doctor_profile_screen`) | Backend<br>`DoctorProfileDto` | Backend<br>`UpdateDoctorProfileDto` | Model<br>`DoctorProfile.fromJson` | Dr's Own View<br>(`doctor_profile_screen`) | Patient View<br>(`patient/...`) | Clinic View<br>(`clinic_doctor_detail_screen`) |
|---|-------|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `fullName` | `string` | ✅ Required | ✅ Editable | ✅ `fullName` | ✅ `fullName?` | ✅ | ✅ **ProfileHeader** | ✅ **Header** | ✅ **Header** |
| 2 | `phoneNumber` | `string` | ✅ Required | ✅ Editable | ✅ `phoneNumber` | ✅ `phoneNumber?` | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 3 | `email` | `string?` | ⚠️ Sent but not in backend's `RegisterDoctorDto` | ✅ Editable | ✅ `email?` | ✅ `email?` | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 4 | `specialization` | `string` | ✅ Required (dropdown) | ✅ Editable (picker) | ✅ `specialization` | ✅ `specialization?` | ✅ | ✅ **ProfileHeader** | ✅ **Header** | ✅ **Header** |
| 5 | `subSpecialty` | `string?` | ❌ Not on signup | ✅ Editable | ✅ `subSpecialty?` | ✅ `subSpecialty?` | ✅ | ✅ **ProfessionalDetails** | ❌ Not shown | ❌ Not shown |
| 6 | `yearsOfExperience` | `int?` | ❌ Not on signup | ✅ Editable | ✅ `yearsOfExperience` | ✅ `yearsOfExperience?` | ✅ | ✅ **StatsRow** | ✅ **StatCard** | ✅ **Header** |
| 7 | `consultationFee` | `number` | ❌ Not on signup | ✅ Editable | ✅ `consultationFee` | ✅ `consultationFee?` | ✅ | ❌ Not shown | ✅ **Fee Card** | ✅ **InfoCard** |
| 8 | `bio` | `string?` | ❌ Not on signup | ✅ Editable | ✅ `bio?` | ✅ `bio?` | ✅ | ✅ **Bio section** | ✅ **About section** | ✅ **InfoCard** |
| 9 | `degree` | `string?` | ❌ Not on signup | ✅ Editable | ✅ `degree?` | ✅ `degree?` | ✅ | ✅ **EducationCard** | ✅ **Education section** | ✅ **InfoCard** |
| 10 | `university` | `string?` | ❌ Not on signup | ✅ Editable | ✅ `university?` | ✅ `university?` | ✅ | ✅ **EducationCard** | ✅ **Education section** | ✅ **InfoCard** |
| 11 | `graduationYear` | `int?` | ❌ Not on signup | ✅ Editable | ✅ `graduationYear?` | ✅ `graduationYear?` | ✅ | ✅ **EducationCard** | ✅ **Education section** | ✅ **InfoCard** |
| 12 | `boardCertification` | `string?` | ❌ Not on signup | ✅ Editable | ✅ `boardCertification?` | ✅ `boardCertification?` | ✅ | ✅ **EducationCard** | ✅ **Education section** | ✅ **InfoCard** |
| 13 | `languages` | `string[]` | ❌ Not on signup | ✅ Editable (comma-separated) | ✅ `languages` | ✅ `languages?` | ✅ | ✅ **ProfessionalDetails** | ✅ **Languages section** | ✅ **InfoCard** |
| 14 | `profileImageUrl` | `string?` | ❌ Not on signup | ⚠️ **Uploaded but NEVER saved to profile** | ✅ `profileImageUrl?` | ✅ `profileImageUrl?` | ✅ | ✅ **ProfileHeader** | ✅ **Avatar** | ✅ **Header** |
| 15 | `licenseImageUrl` | `string?` | ✅ Required (uploaded as `licenseFileUrl`) | ❌ Not editable | ✅ `licenseImageUrl?` | ✅ `licenseImageUrl?` | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 16 | `licenseNumber` | `string?` | ❌ Not captured | ❌ Not editable | ✅ `licenseNumber?` | ❌ Not in Update DTO | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 17 | `isAvailable` | `bool` | ❌ Not on signup | ❌ Not editable | ✅ `isAvailable` | ✅ `isAvailable?` | ✅ | ❌ Not shown | ❌ Not shown | ✅ **InfoCard** (clinic edits it) |
| 18 | `averageRating` | `number` | — (read-only) | — | ✅ `averageRating` | — | ✅ | ✅ **ProfileHeader** | ✅ **Header** | ✅ **Header** |
| 19 | `totalReviews` | `int` | — (read-only) | — | ✅ `totalReviews` | — | ✅ | ✅ **ProfileHeader** | ✅ **Header** | ✅ **Header** |
| 20 | `associatedClinics` | `string[]` | — (read-only) | — | ✅ `associatedClinics` | — | ✅ | ✅ **Associated Clinics** | ✅ **Associated Clinics** | — (already in clinic context) |
| 21 | `clinicId` | `int?` | — (read-only) | — | ✅ `clinicId?` | — | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 22 | `clinicName` | `string?` | — (read-only) | — | ✅ `clinicName?` | — | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 23 | `qrCodeKey` | `string?` | — (read-only) | — | ✅ `qrCodeKey?` | — | ✅ | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 24 | `totalPatients` | `int` | — (read-only) | — | ✅ `totalPatients` | — | ❌ **Not parsed in model** | ⚠️ **Hardcoded `patients: 0`** | ⚠️ Shows `totalReviews` instead of `totalPatients` | ❌ Not shown |
| 25 | `clinicLatitude` | `number?` | — (read-only) | — | ✅ `clinicLatitude?` | — | ❌ Not parsed | ❌ Not shown | ❌ Not shown | ❌ Not shown |
| 26 | `clinicLongitude` | `number?` | — (read-only) | — | ✅ `clinicLongitude?` | — | ❌ Not parsed | ❌ Not shown | ❌ Not shown | ❌ Not shown |

---

## 🔴 Issues Breakdown

### Issue 1 — CRITICAL: Profile image URL never persisted

**Files:** `edit_doctor_profile_screen.dart`

`_pickAndUploadPhoto()` uploads the image via `POST /api/upload/profile-image` and stores the returned URL in `_profileImageUrl` state. However, `_saveProfile()` builds a data map that does **NOT** include `profileImageUrl`.

```dart
// edit_doctor_profile_screen.dart lines 89-103
final data = {
  'fullName': _nameController.text,
  'phoneNumber': _phoneController.text,
  // ... all other fields
  // ❌ 'profileImageUrl': _profileImageUrl,   <-- MISSING
};
```

**Result:** The image file is stored on the server but never linked to the doctor's profile. On next load, the old image (or none) is shown.

**Fix:** Add `'profileImageUrl': _profileImageUrl` to the data map in `_saveProfile()`.

---

### Issue 2 — MEDIUM: `patients` stat hardcoded to `0`

**Files:** `doctor_profile_screen.dart` (line 94), `doctor_models.dart`

The backend returns `totalPatients` in `DoctorProfileDto`, but:
1. `DoctorProfile.fromJson()` does **NOT** parse `totalPatients`.
2. The doctor's own profile view hardcodes `patients: 0`.

```dart
// doctor_profile_screen.dart line 94
_StatsRow(
  experience: profile?.yearsOfExperience ?? 0,
  patients: 0,  // 🔴 Hardcoded
  rating: profile?.averageRating ?? 0,
),
```

The patient view shows `totalReviews` in the "Patients" stat card instead of actual patient count.

**Fix:** Add `totalPatients` to `DoctorProfile` model + `fromJson`, then use it in both display screens.

---

### Issue 3 — MEDIUM: `email` sent at signup but backend `RegisterDoctorDto` doesn't accept it

**Files:** `auth_models.dart`, `API_DOCUMENTATION.md`

The Flutter `RegisterDoctorRequest.toJson()` includes `email`, but the backend's `RegisterDoctorDto` has no `email` field:

```typescript
// Backend RegisterDoctorDto
interface RegisterDoctorDto {
  name: string;
  phone: string;
  password: string;
  confirmPassword: string;
  specialization: string;
  licenseFileUrl: string;
  // ❌ No email field
}
```

**Impact:** Low — the backend likely ignores the extra field. Email can still be set later via `PUT /api/doctor/profile`. But the signup form lets users enter an email that gets silently discarded.

---

### Issue 4 — LOW: `phoneNumber` and `email` never displayed

These fields are loaded and saved correctly, but none of the three display screens show them. Users can change them in edit profile but have no way to see what value is currently stored.

---

### Issue 5 — LOW: `clinicLatitude` / `clinicLongitude` not parsed in model

Backend returns them, model ignores them. Not used by current UI.

---

### Issue 6 — COSMETIC: Currency display mismatch

| Screen | Display |
|--------|---------|
| `clinic_doctor_detail_screen.dart` (line 382) | `'\$${fee}'` — **USD** |
| `patient/doctor_profile/doctor_profile_screen.dart` (line 206) | `'${fee} EGP'` — correct |

---

### Issue 7 — COSMETIC: Null-safe access inconsistency

```dart
// doctor_profile_screen.dart line 77
final profile = snapshot.data!;  // non-null
// line 85
profile?.fullName  // unnecessary ?. — already non-null
```

---

## Registration vs Edit Profile: What's Covered Where

```
┌─────────────────────────────────────────────────────┐
│                  REGISTRATION                        │
│  register_doctor_screen.dart                        │
│                                                     │
│  ✅ name (required)                                 │
│  ✅ phone (required)                                │
│  ⚠️ email (sent but backend ignores)                │
│  ✅ password + confirmPassword                      │
│  ✅ specialization (dropdown)                       │
│  ✅ licenseFileUrl (upload)                         │
└──────────────────────┬──────────────────────────────┘
                       │ Account created
                       ▼
┌─────────────────────────────────────────────────────┐
│              EDIT PROFILE (Post-Registration)        │
│  edit_doctor_profile_screen.dart                    │
│                                                     │
│  ✅ fullName        ✅ subSpecialty                  │
│  ✅ phoneNumber     ✅ yearsOfExperience             │
│  ✅ email           ✅ consultationFee               │
│  ✅ specialization  ✅ bio                           │
│  ✅ degree          ✅ graduationYear                │
│  ✅ university      ✅ boardCertification            │
│  ✅ languages       ⚠️ profileImageUrl (not saved)  │
└──────────────────────┬──────────────────────────────┘
                       │ All fields sent to
                       │ PUT /api/doctor/profile
                       ▼
┌─────────────────────────────────────────────────────┐
│            BACKEND (DoctorProfileDto)                │
│                                                     │
│  Read-only (returned by API):                       │
│  averageRating, totalReviews, isAvailable,          │
│  associatedClinics, clinicId, clinicName,           │
│  qrCodeKey, totalPatients, clinicLat/Lng,           │
│  licenseNumber, licenseImageUrl                     │
└──────────────────────┬──────────────────────────────┘
                       │ Displayed across:
                       ▼
┌─────────────────────────────────────────────────────┐
│  DISPLAY SCREENS                                     │
│                                                     │
│  Doctor's Own View  │  Patient View  │  Clinic View │
│  ─────────────────  │  ────────────  │  ─────────── │
│  fullName           │  fullName      │  fullName     │
│  specialization     │  specialization│  specialization│
│  profileImageUrl    │  profileImageUrl│ profileImageUrl│
│  averageRating      │  averageRating │  averageRating │
│  totalReviews       │  totalReviews  │  totalReviews  │
│  yearsOfExperience  │  yearsOfExp.   │  yearsOfExp.   │
│  subSpecialty       │  languages     │  languages     │
│  languages          │  bio           │  bio           │
│  degree             │  degree        │  degree        │
│  university         │  university    │  university    │
│  graduationYear     │  graduationYear│  graduationYear│
│  boardCertification │  boardCert.    │  boardCert.    │
│  bio                │  consultationFee│ consultationFee│
│  associatedClinics  │  associatedClin│  isAvailable   │
│  ❌ phoneNumber     │  ❌ phoneNum   │  ❌ phoneNum   │
│  ❌ email           │  ❌ email      │  ❌ email      │
│  ❌ consultationFee │                │                │
└─────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

```
POST /api/auth/register/doctor  ───→  RegisterDoctorDto
  name, phone, password, specialization, licenseFileUrl

PUT /api/doctor/profile  ───→  UpdateDoctorProfileDto
  fullName, phoneNumber, email?, specialization?,
  subSpecialty?, yearsOfExperience?, consultationFee?,
  bio?, degree?, university?, graduationYear?,
  boardCertification?, languages?, profileImageUrl?,
  isAvailable?, licenseImageUrl?

GET /api/doctor/profile  ───→  DoctorProfileDto
  ←── fullName, phoneNumber, email, profileImageUrl,
       specialization, licenseNumber, licenseImageUrl,
       yearsOfExperience, bio, consultationFee,
       averageRating, totalReviews, isAvailable,
       clinicId, clinicName, clinicLatitude, clinicLongitude,
       degree, university, subSpecialty, graduationYear,
       boardCertification, languages, associatedClinics,
       qrCodeKey, totalPatients

GET /api/doctor/{id}  ───→  DoctorProfileDto (same shape, public)
```

---

## Summary

| Category | Count | Details |
|----------|-------|---------|
| ✅ Fully working fields | 13 | fullName, specialization, subSpecialty, yearsOfExperience, consultationFee, bio, degree, university, graduationYear, boardCertification, languages, averageRating, totalReviews |
| ⚠️ Working with issues | 3 | profileImageUrl (not saved), totalPatients (not in model), email (ignored at signup) |
| ❌ Not editable after signup | 2 | licenseImageUrl, licenseNumber (set at registration or backend-managed) |
| ❌ Loaded but never displayed | 5 | phoneNumber, email, clinicId, clinicName, qrCodeKey |
| ❌ Not parsed from API | 3 | totalPatients, clinicLatitude, clinicLongitude |
