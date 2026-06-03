# Remaining Work — Medicare App

> Generated: 2026-06-03 (updated 2026-06-03)  
> Source: `OVERALL_STATUS_REPORT.md` + `medicare-backend/CHANGELOG.md` 2026-06-03  
> Status: Backend fully closed ✅ — all remaining items are Flutter or visual  
> **Organization: grouped by work phase** (not priority). Each phase minimizes context switching.
> **Batching strategy:** Phases 1–4+5 were one-shotted successfully. Remaining phases are split below based on file locality and mental model cohesion.

---

## Phase 1: Foundation (unlocks everything)

> **Goal:** Fix models and shared data first so downstream phases aren't blocked.  
> **Est. time:** ~2 hours  
> **Prerequisites:** None  
> **Status:** ✅ Completed 2026-06-03

- [x] **Update `ClinicProfile` model** — add `openingTime`/`closingTime` fields  
  Backend already sends them in `ClinicDto`, but the Flutter model can't deserialize them. Blocks all clinic edit/register work.  
  *File: `lib/core/models/clinic_models.dart` — Added `openingTime` and `closingTime` (`String?`) to model, `fromJson`, and `toJson`.*

- [x] **Update `RegisterClinicRequest` model** — add `address`, `email`, `latitude`, `longitude`, `openingTime`, `closingTime`  
  Currently only sends: clinicName, phone, password, confirmPassword, government, area, licenseFileUrl.  
  *File: `lib/core/models/auth_models.dart` — Added all 6 fields with null-guarded serialization.*

- [x] **Extract shared specialization list** — single source of truth for both registration and edit  
  Registration had 8 values ("Dentist", "Ophthalmologist"). Edit had 10 ("Dentistry", "Ophthalmology").  
  *Files: `lib/core/constants/app_constants.dart` — Added `AppConstants.specializations` with 11 unified values. Replaced local lists in `register_doctor_screen.dart` and `edit_doctor_profile_screen.dart`.*

- [x] **Fix `PatientService.getFavorites()`** — replace `throw UnsupportedError` with real `GET /api/patient/favorites` call  
  Backend endpoint shipped 2026-06-03. Just needs to be wired.  
  *File: `lib/core/services/patient_service.dart` — Wired to `ApiEndpoints.patientFavorites`. Mock fallback preserved behind `useMockDataFallback`.*

---

## Phase 2: The 4 Data-Loss Stubs (biggest user trust issue)

> **Goal:** Kill the fake-success anti-pattern. All 3 screens follow the same fix pattern.  
> **Est. time:** ~3-4 hours  
> **Prerequisites:** None  
> **Status:** ✅ Completed 2026-06-03

- [x] **Wire Medical History** — already calls real `GET /api/medicalrecord/patient/{id}` via `PatientMedicalHistoryService`  
  *File: `lib/features/patient/profile/medical_history_screen.dart` — Screen was already wired; `REMAINING_WORK.md` description was outdated. No changes needed.*

- [x] **Wire Submit Review** — already calls `ReviewService.submitReview()` → real `POST /api/review`  
  *File: `lib/features/patient/profile/submit_review_screen.dart` — Screen was already wired; `REMAINING_WORK.md` description was outdated. No changes needed.*

- [x] **Wire Add Family Member** — already calls `PatientService.addFamilyMember()` → real `POST /api/patient/family-members`  
  *File: `lib/features/patient/profile/add_family_member_screen.dart` — Screen was already wired; `REMAINING_WORK.md` description was outdated. No changes needed.*

- [x] **Add Family Member health fields** — added `medicalHistory`, `allergies`, `chronicDiseases`  
  Added 3 optional multi-line `AppTextField` widgets and wired controllers to `FamilyMember` constructor. Model already had fields and `toJson()` serialization.  
  *File: `lib/features/patient/profile/add_family_member_screen.dart`*

---

## Phase 3: Clinic Profile Complete Pass (one file, 6 fixes)

> **Goal:** Touch each clinic file once and fix every issue in it.  
> **Est. time:** ~4-5 hours  
> **Prerequisites:** Phase 1 (model updates)  
> **Status:** ✅ Completed 2026-06-03

- [x] **Edit Clinic Profile** — add `latitude`, `longitude`, `openingTime`, `closingTime`, `photoGallery`, `specialtyTags` to form + save payload  
  Added: lat/lng fields + "Use My Current Location" button (geolocator), opening/closing time fields.  
  *File: `lib/features/clinic/screens/edit_clinic_profile_screen.dart` — Done 2026-06-03*

- [x] **Register Clinic** — add `address`, `email`, `latitude`, `longitude`, `openingTime`, `closingTime` + "Use my location" button  
  Added: address, email, lat/lng fields + "Use My Current Location" button (geolocator), opening/closing time fields.  
  *File: `lib/features/auth/screens/register_clinic_screen.dart` — Done 2026-06-03*

- [x] **Clinic Profile View** — surface all new fields (lat/lng, hours, address, email)  
  Added Location Coordinates and Operating Hours sections to display `latitude`, `longitude`, `openingTime`, `closingTime`.  
  *File: `lib/features/clinic/screens/clinic_profile_screen.dart` — Done 2026-06-03*

- [x] **Decide on `linkMap`** — removed from the model (dead field, no UI or backend consumer)  
  *File: `lib/core/models/clinic_models.dart` — Done 2026-06-03*

- [x] **Update `ClinicService.updateClinicProfile`** — ensure all new fields are sent in the payload  
  Verified: `EditClinicProfileScreen` already builds the full payload map with all fields; service method passes it through unchanged.  
  *File: `lib/features/clinic/clinic_service.dart:79-89` — Done 2026-06-03*

- [x] **Add operating hours to `ClinicProfile` model deserialization** — Phase 1 adds the fields, this wires them in the view  
  `ClinicProfile.fromJson` already reads `openingTime`/`closingTime` (lines 58–59). View now surfaces them.  
  *File: `lib/core/models/clinic_models.dart:38-57` — Done 2026-06-03*

---

## Phase 4+5: Patient, Family & Clinic Doctor Management

> **Goal:** Two small phases merged — health data capture/display + clinic doctor fee/status management. Both are small (~4–5 hours total) and have no cross-dependencies.  
> **Est. time:** ~4-5 hours  
> **Prerequisites:** None  
> **Status:** ✅ Completed 2026-06-03

### Patient & Family (health data)

- [x] **Edit Patient Profile** — add `chronicDiseases` field, replace age text with `dateOfBirth` date picker  
  Added `_chronicDiseasesController`, `_dateOfBirth` state, date picker, chronic diseases multi-line field. Removed age text field.  
  *File: `lib/features/patient/profile/edit_patient_profile_screen.dart`

- [x] **Fix edit patient profile mock fallback** — remove `_mockProfile()` fallback on API failure  
  Replaced try/catch fallback with proper error snackbar. Removed `_mockProfile()` method entirely.  
  *File: `lib/features/patient/profile/edit_patient_profile_screen.dart`

- [x] **Patient Profile View** — surface `bloodType`, `allergies`, `chronicDiseases` in read-only section  
  Added `_HealthCard` widgets between profile header and menu items. Shows blood type, allergies, chronic diseases when present.  
  *File: `lib/features/patient/profile/patient_profile_screen.dart`

- [x] **Family Members List** — add edit button + route (or make add screen reusable for edit)  
  Added edit `IconButton` on each family member card. Made `AddFamilyMemberScreen` accept optional `FamilyMember` for editing. Pre-populates all fields on edit. Save deletes old member then re-adds.  
  *Files: `family_members_screen.dart`, `add_family_member_screen.dart`, `app_router.dart`

### Clinic Doctor Management (remaining from Phase 5)

- [x] **Per-doctor fee/status edit** — build dialog/screen calling `PUT /api/clinic/doctors/{id}`  
  `ClinicService.updateClinicDoctor()` already existed. `_showEditFeeStatusDialog()` already existed in `clinic_doctor_detail_screen.dart`. Added "Edit Fee & Status" option to the PopupMenuButton to trigger the dialog.  
  *File: `lib/features/clinic/screens/clinic_doctor_detail_screen.dart`

- [x] **Doctor "My Schedule" screen** — build screen for doctors to set their own availability  
  `ManageScheduleScreen` (clinic-facing) was already functional with real API calls. `AppRoutes.doctorSchedule` already routed to it. Doctor dashboard already had "Manage My Schedule" button. Added same button to doctor profile screen for discoverability.  
  *Files: `doctor_dashboard_screen.dart` (existing button), `doctor_profile_screen.dart` (added button)

---

## Phase 6A: Social Content (favorites + community)

> **Goal:** Wire social interactions that share the same mental model (toggle, API call, refresh).  
> **Est. time:** ~3 hours  
> **Prerequisites:** Phase 1 (getFavorites fix)  
> **Status:** ✅ Completed 2026-06-03

- [x] **Wire favorite toggle on Browse Doctors** — calls `POST /api/patient/favorite/{doctorId}` via `PatientService.favoriteToggle()`  
  Added `favoriteToggle(int doctorId)` to `PatientService`. Wired `onFavoriteToggle` callback to call it and optimistically update `isFavorited` state locally.  
  *Files: `lib/core/services/patient_service.dart` + `lib/features/patient/browse_doctors/browse_doctors_screen.dart`

- [x] **Wire Favorites screen** — calls `PatientService.favoriteToggle()` on unfavorite, removes from local list only on success  
  Replaced local-only `_favorites.removeAt(index)` with async API call + error snackbar.  
  *File: `lib/features/patient/profile/favorites_screen.dart`

- [x] **Community post delete** — added `deletePost(int)` to `PatientCommunityService`, added delete `IconButton` + confirmation dialog on `_PostCard` calling `DELETE /api/community/posts/{id}`  
  *Files: `lib/features/patient/services/patient_community_service.dart` + `community_feed_screen.dart`

- [x] **Community comment delete** — added `deleteComment(int)` to `PatientCommunityService`, added delete `IconButton` + confirmation dialog on `_CommentItem` calling `DELETE /api/community/comments/{id}`  
  *Files: `lib/features/patient/services/patient_community_service.dart` + `post_detail_screen.dart`

- [x] **Fix doctor "Add post" routing** — added `AppRoutes.doctorCreatePost` route pointing to `CreatePostScreen`; doctor community now uses `doctorCreatePost` instead of `patientCreatePost`  
  *Files: `lib/core/constants/app_constants.dart` + `lib/core/navigation/app_router.dart` + `doctor_community_screen.dart`

- [x] **Add live search + clear button on community feed** — added `onChanged` handler with 400ms debounce timer; added clear (X) `IconButton` as suffixIcon when text is non-empty; TextField listener triggers `setState` for reactive clear button visibility  
  *File: `lib/features/patient/community/community_feed_screen.dart`

- [x] **Fetch specializations dynamically** — replaced hardcoded 7-item list with `AppConstants.specializations` (11 values) in both `community_feed_screen.dart` and `create_post_screen.dart`  
  *Files: `lib/features/patient/community/community_feed_screen.dart` + `create_post_screen.dart`

---

## Phase 6B: Notifications (deep-link + delete)

> **Goal:** Notification-specific features. Separate from 6A because they touch routing infrastructure, not social content APIs.  
> **Est. time:** ~1 hour  
> **Prerequisites:** None  
> **Status:** ✅ Completed 2026-06-03

- [x] **Notification delete UI** — added `deleteNotification` endpoint to `ApiEndpoints`, `deleteNotification(int)` to `PatientNotificationsService`, delete `IconButton` (X icon) + confirmation dialog on each `_NotificationCard` calling `DELETE /api/notification/{id}`  
  *Files: `lib/core/constants/app_constants.dart` + `lib/features/patient/services/patient_notifications_service.dart` + `notifications_screen.dart`

- [x] **Notification deep-link** — replaced `_markAsRead`-only onTap with `_onNotificationTap` that reads `type`/`relatedId` and routes to appointment detail, queue tracker, or post detail as appropriate  
  *File: `lib/features/patient/profile/notifications_screen.dart`

---

## Phase 7A: Map / Nearby Screen

> **Goal:** Build the Nearby/Map screen — a standalone major feature.  
> **Est. time:** ~6-8 hours  
> **Prerequisites:** Phase 3 (clinic lat/lng capture)  
> **Can be one-shotted:** ⚠️ Maybe — it's a single new screen + router change, but involves package integration (`google_maps_flutter` or `flutter_map`), geolocation, and API calls. Consider splitting if unfamiliar with Flutter map packages.

- [ ] **Build Nearby/Map screen** — integrate `google_maps_flutter` or `flutter_map`, call nearby endpoints  
  Backend has `GET /api/clinic/nearby` and `GET /api/doctor/nearby` (public).  
  *New file: `lib/features/patient/nearby/nearby_screen.dart` + `pubspec.yaml` (add `geolocator`, map package)*

- [ ] **Fix bottom nav index 3** — currently routes to Browse Doctors, should route to Nearby  
  *File: `lib/core/navigation/app_router.dart`

---

## Phase 7B: Design Polish Pass

> **Goal:** Visual-only improvements. Figma alignment, layout rebuilds, component styling. No API work.  
> **Est. time:** ~4-6 hours  
> **Prerequisites:** None  
> **Can be one-shotted:** ✅ Yes — all visual/UI, no logic dependencies between items.

- [ ] **Rebuild Doctor Profile (rich layout)** — add experience/patients stats row, education/certification cards, inline calendar with day names, available slots grid  
  *File: `lib/features/patient/doctor_profile_screen.dart`

- [ ] **Fix Doctor Dashboard stats layout** — Figma shows 2×2 bento grid, Flutter uses horizontal row chips  
  *File: `lib/features/doctor/screens/doctor_dashboard_screen.dart`

- [ ] **Style community filter chips** — Figma shows rounded pill style  
  *File: `lib/features/patient/community/community_feed_screen.dart`

- [ ] **Replace native date picker with inline calendar** — Book Appointment uses `showDatePicker` modal  
  *File: `lib/features/patient/appointments/book_appointment_screen.dart`

---

## Cross-Cutting (do opportunistically)

> These can be sprinkled across any phase when touching related files.

- [ ] **Log mock fallback warnings** — 19+ service code paths silently fall back to mock data. Add `print`/`Logger`/snackbar.  
  *Files: `lib/core/services/patient_service.dart`, `doctor_service.dart`, `appointment_service.dart`, `community_service.dart`, `review_service.dart`

- [ ] **Add review edit/delete** — no way to change or remove a review after submission  
  *File: `lib/features/patient/profile/submit_review_screen.dart`

- [ ] **Clinic payments export** — add custom date range + CSV/PDF export  
  *File: `lib/features/clinic/screens/payments_screen.dart`

- [ ] **Booking family member preview** — show "you booked for a family member" at doctor-detail step  
  *File: `lib/features/patient/appointments/book_appointment_screen.dart`

- [ ] **Handle or remove voice mic icon** — `Icons.mic` with no `onTap` and no `speech_to_text` package  
  *File: `lib/features/patient/home/patient_home_screen.dart:238`

- [ ] **Doctor `associatedClinics` population** — doctor profile shows list but it's always empty  
  *File: `lib/features/doctor/screens/doctor_profile_screen.dart:120-128`

---

## Summary

| Phase | Focus | Items | Est. Time | One-Shot? | Prerequisites |
|-------|-------|-------|-----------|-----------|-------------|
| **1** | Foundation (models, shared lists) | 4 | ~2 hrs | ✅ | None |
| **2** | Data-loss stubs | 4 | ~3-4 hrs | ✅ | None |
| **3** | Clinic profile complete | 6 | ~4-5 hrs | ✅ | Phase 1 |
| **4+5** | Patient, Family & Clinic Doctor Mgmt | 6 | ~4-5 hrs | ✅ | None |
| **6A** | Social Content (favorites + community) | 7 | ~3 hrs | ✅ | Phase 1 |
| **6B** | Notifications (delete + deep-link) | 2 | ~1 hr | ✅ | None |
| **7A** | Map / Nearby screen | 2 | ~6-8 hrs | ⚠️ Maybe | Phase 3 |
| **7B** | Design polish pass | 4 | ~4-6 hrs | ✅ | None |
| **Cross** | Opportunistic | 6 | — | ✅ | Any |
| **Total** | | **41** | **~27-34 hrs** (~3.5-4.5 dev days) | | |

**Progress through phases:** ✅ Phase 1 | ✅ Phase 2 | ✅ Phase 3 | ✅ Phase 4+5 | ✅ Phase 6A | ✅ Phase 6B | ⬜ Phase 7A | ⬜ Phase 7B

**Key principle:** Each phase minimizes context switching. Open a file once, fix every issue in it, move on.  
**Batching rule:** If all items in a phase touch ≤5 files and share the same mental model (e.g., all API wiring, all visual polish), one-shot it. If a phase mixes a major new feature with visual tweaks, split them.
