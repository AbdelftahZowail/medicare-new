# Remaining Work — Medicare App

> Generated: 2026-06-03  
> Source: `OVERALL_STATUS_REPORT.md` + `medicare-backend/CHANGELOG.md` 2026-06-03  
> Status: Backend fully closed ✅ — all remaining items are Flutter or visual  
> **Organization: grouped by work phase** (not priority). Each phase minimizes context switching.

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

- [x] **Edit Clinic Profile** — add `latitude`, `longitude`, `openingTime`, `closingTime`, `photoGallery`, `specialtyTags` to form + save payload  
  Added: lat/lng fields + "Use My Current Location" button (geolocator), opening/closing time fields.  
  *File: `lib/features/clinic/screens/edit_clinic_profile_screen.dart` — Done 2026-06-03*

- [x] **Register Clinic** — add `address`, `email`, `latitude`, `longitude`, `openingTime`, `closingTime` + "Use my location" button  
  Added: address, email, lat/lng fields + "Use My Current Location" button (geolocator), opening/closing time fields.  
  *File: `lib/features/auth/screens/register_clinic_screen.dart` — Done 2026-06-03*

- [ ] **Clinic Profile View** — surface all new fields (lat/lng, hours, address, email)  
  Currently shows: name, facilityId, description, doctorsCount, government, area, address, phone, email.  
  *File: `lib/features/clinic/screens/clinic_profile_screen.dart`

- [ ] **Decide on `linkMap`** — either wire it (display + capture) or remove it from the model  
  Currently a dead field: model has it, backend accepts it, UI completely ignores it.  
  *File: `lib/core/models/clinic_models.dart:9`

- [ ] **Update `ClinicService.updateClinicProfile`** — ensure all new fields are sent in the payload  
  *File: `lib/features/clinic/clinic_service.dart:79-89`

- [ ] **Add operating hours to `ClinicProfile` model deserialization** — Phase 1 adds the fields, this wires them in the view  
  *File: `lib/core/models/clinic_models.dart:38-57`

---

## Phase 4: Patient & Family (health data)

> **Goal:** Complete the health data capture and display loop.  
> **Est. time:** ~3 hours  
> **Prerequisites:** None

- [ ] **Edit Patient Profile** — add `chronicDiseases` field, replace age text with `dateOfBirth` date picker  
  Currently: bloodType and allergies captured, chronicDiseases missing. Age text field instead of DOB date picker.  
  *File: `lib/features/patient/profile/edit_patient_profile_screen.dart`

- [ ] **Fix edit patient profile mock fallback** — remove `_mockProfile()` fallback on API failure  
  Same fake-success anti-pattern as P0 stubs (though save path is real).  
  *File: `lib/features/patient/profile/edit_patient_profile_screen.dart:71-79`

- [ ] **Patient Profile View** — surface `bloodType`, `allergies`, `chronicDiseases` in read-only section  
  Currently only shows: name, email, phone. Health data is completely hidden.  
  *File: `lib/features/patient/profile/patient_profile_screen.dart`

- [ ] **Family Members List** — add edit button + route (or make add screen reusable for edit)  
  Currently: delete + re-add is the only way to update.  
  *File: `lib/features/patient/profile/family_members_screen.dart`

---

## Phase 5: Doctor & Schedule (clinic management flow)

> **Goal:** Fix everything related to clinic managing doctors. Stay in clinic/doctor screens.  
> **Est. time:** ~6-8 hours  
> **Prerequisites:** Phase 1 (shared specialization list)

- [x] **Register Doctor** — add `email` field  
  Added email field to `RegisterDoctorRequest` model and `RegisterDoctorScreen` form.  
  *File: `lib/features/auth/screens/register_doctor_screen.dart` — Done 2026-06-03*

- [x] **Fix specialization lists** — both registration and edit now pull from shared list (Phase 1)  
  Already completed in Phase 1.  
  *Files: `register_doctor_screen.dart` + `edit_doctor_profile_screen.dart` — Done 2026-06-03*

- [x] **Manage Schedule** — wire to `GET /api/doctor/{id}/schedules` and real save  
  Fetches real schedules on init, allows editing `slotDurationMinutes` and `maxPatients` per slot, sends actual values.  
  *File: `lib/features/clinic/screens/manage_schedule_screen.dart` — Done 2026-06-03*

- [x] **Clinic Doctor Detail** — switch to detail endpoint `GET /api/clinic/doctors/{id}`  
  Now uses `getClinicDoctorDetail` endpoint. Displays all fields: degree, university, bio, languages, board cert, experience, graduation year.  
  *File: `lib/features/clinic/screens/clinic_doctor_detail_screen.dart` — Done 2026-06-03*

- [x] **Clinic Doctor Detail schedule** — wire schedule section to real data instead of hardcoded "09:00-05:00"  
  Now fetches real schedules via `getDoctorSchedules` and displays actual time slots per day.  
  *File: `lib/features/clinic/screens/clinic_doctor_detail_screen.dart` — Done 2026-06-03*

- [ ] **Per-doctor fee/status edit** — build dialog/screen calling `PUT /api/clinic/doctors/{id}`  
  Endpoint exists in `app_constants.dart:54`. Never called from any screen.  
  *File: `lib/features/clinic/clinic_service.dart` (add method) + new UI

- [ ] **Doctor "My Schedule" screen** — build screen for doctors to set their own availability  
  Currently only clinics can manage doctor schedules.  
  *New file: `lib/features/doctor/screens/doctor_schedule_screen.dart`

---

## Phase 6: Social Features (favorites + community + notifications)

> **Goal:** Wire all social interaction features. Same patterns throughout (toggle, API call, refresh).  
> **Est. time:** ~4-5 hours  
> **Prerequisites:** Phase 1 (getFavorites fix)

- [ ] **Wire favorite toggle on Browse Doctors** — call `POST /api/patient/favorite/{doctorId}` instead of `() {}`  
  *File: `lib/features/patient/browse_doctors/browse_doctors_screen.dart:134`

- [ ] **Wire Favorites screen** — call `GET /api/patient/favorites` instead of local `removeAt(i)`  
  *File: `lib/features/patient/profile/favorites_screen.dart:94`

- [ ] **Community post delete** — add delete button calling `DELETE /api/community/posts/{id}`  
  Endpoint exists in constants, no service method or UI calls it.  
  *Files: `lib/core/services/community_service.dart` + `community_feed_screen.dart`

- [ ] **Community comment delete** — add delete button calling `DELETE /api/community/comments/{id}`  
  *Files: `lib/core/services/community_service.dart` + `post_detail_screen.dart`

- [ ] **Fix doctor "Add post" routing** — routes to `patientCreatePost` instead of doctor context  
  *File: `lib/features/doctor/screens/doctor_community_screen.dart`

- [ ] **Add live search + clear button on community feed** — currently only filters on Enter  
  *File: `lib/features/patient/community/community_feed_screen.dart`

- [ ] **Fetch specializations dynamically** — currently hardcoded 7 items  
  *File: `lib/features/patient/community/community_feed_screen.dart:27-35`

- [ ] **Notification delete UI** — add swipe/button calling `DELETE /api/notification/{id}`  
  Backend endpoint shipped 2026-06-03.  
  *File: `lib/features/patient/notifications/notifications_screen.dart`

- [ ] **Notification deep-link** — wire `type`/`relatedId` to route to related entity on tap  
  Model has both fields, onTap handler never reads them.  
  *Files: `lib/core/models/shared_models.dart:7-8` + `notifications_screen.dart`

---

## Phase 7: Map & Design (parallelizable)

> **Goal:** Build the Nearby/Map screen and apply visual polish. Can be done in parallel or after everything else.  
> **Est. time:** ~10-14 hours (map 6-8h, design 4-6h)  
> **Prerequisites:** Phase 3 (clinic lat/lng capture)

### Map
- [ ] **Build Nearby/Map screen** — integrate `google_maps_flutter` or `flutter_map`, call nearby endpoints  
  Backend has `GET /api/clinic/nearby` and `GET /api/doctor/nearby` (public).  
  *New file: `lib/features/patient/nearby/nearby_screen.dart` + `pubspec.yaml` (add `geolocator`, map package)

- [ ] **Fix bottom nav index 3** — currently routes to Browse Doctors, should route to Nearby  
  *File: `lib/core/navigation/app_router.dart`

### Design
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

| Phase | Focus | Items | Est. Time | Prerequisites |
|-------|-------|-------|-----------|-------------|
| **1** | Foundation (models, shared lists) | 4 | ~2 hrs | None |
| **2** | Data-loss stubs | 4 | ~3-4 hrs | None |
| **3** | Clinic profile complete | 6 | ~4-5 hrs | Phase 1 |
| **4** | Patient & family | 4 | ~3 hrs | None |
| **5** | Doctor & schedule | 7 | ~6-8 hrs | Phase 1 |
| **6** | Social features | 9 | ~4-5 hrs | Phase 1 |
| **7** | Map & design | 6 | ~10-14 hrs | Phase 3 |
| **Cross** | Opportunistic | 6 | — | Any |
| **Total** | | **41** | **~32-41 hrs** (~4-5 dev days) | |

**Key principle:** Each phase minimizes context switching. Open a file once, fix every issue in it, move on.
