# Medicare App — Overall Status Report

> Generated from Figma design audit + Flutter frontend audit + .NET backend audit  
> Date: 2026-05-27  
> Last updated: 2026-06-03 (reconciled with `medicare-backend/CHANGELOG.md` 2026-06-03 + Phase 1 + Phase 2 completed)  
> Figma Source: https://www.figma.com/design/UZjAOECB8WGEfjzMcy7mQW/%D9%85%D8%B4%D8%B1%D9%88%D8%B9-UI

---

## 0. Current Status Snapshot (2026-06-03)

> **New:** Code scan (§9.9) surfaced 11 additional forgotten fields beyond the original audit.

**Closed**

| # | Item | Closed by |
|---|---|---|
| 1 | Geospatial search endpoints (`/api/clinic/nearby`, `/api/doctor/nearby`) | Backend 2026-06-01 |
| 2 | `distanceKm`, `clinicLatitude/Longitude`, `totalPatients` fields on doctor DTOs | Backend 2026-06-01 |
| 3 | `GET /api/doctor` HTTP 500 (missing AutoMapper mapping) | Backend 2026-06-01 |
| 4 | Appointment Confirmation shows real booking data | Flutter 2026-06-01 |
| 5 | Community post share button | Flutter 2026-06-01 |
| 6 | Font 'Inter' via `google_fonts` | Flutter 2026-06-01 |
| 7 | Onboarding assets (all 3 PNGs verified) | Flutter 2026-06-01 |
| 8 | `GET /api/patient/favorites` endpoint — returns patient's favorited doctors | Backend 2026-06-03 |
| 9 | `DELETE /api/notification/{id}` endpoint — notification owner can delete | Backend 2026-06-03 |
| 10 | `openingTime` / `closingTime` on `ClinicDto`, `CreateClinicDto`, `UpdateClinicDto` — wired to entity | Backend 2026-06-03 |
| 11 | `ClinicProfile` model — added `openingTime`/`closingTime` deserialization | Flutter 2026-06-03 |
| 12 | `RegisterClinicRequest` model — added `address`, `email`, `latitude`, `longitude`, `openingTime`, `closingTime` | Flutter 2026-06-03 |
| 13 | Shared specialization list — unified 11 values in `AppConstants.specializations` | Flutter 2026-06-03 |
| 14 | `PatientService.getFavorites()` — wired to real `GET /api/patient/favorites` | Flutter 2026-06-03 |
| 15 | `EditClinicProfileScreen` — added lat/lng fields + "Use My Current Location" button + operating hours | Flutter 2026-06-03 |
| 16 | `RegisterClinicScreen` — added address, email, lat/lng + "Use My Current Location" + operating hours | Flutter 2026-06-03 |
| 17 | Medical History screen — verified already wired to `GET /api/medicalrecord/patient/{id}` via `PatientMedicalHistoryService` | Flutter 2026-06-03 |
| 18 | Submit Review screen — verified already calls `ReviewService.submitReview()` → real `POST /api/review` | Flutter 2026-06-03 |
| 19 | Add Family Member screen — verified already calls `PatientService.addFamilyMember()` → real `POST /api/patient/family-members` | Flutter 2026-06-03 |
| 20 | Add Family Member health fields — added `medicalHistory`, `allergies`, `chronicDiseases` optional fields to form | Flutter 2026-06-03 |

**Out of scope** (explicitly deferred — no work planned)

- AI Chatbot (screen + backend)
- Social login (Google / Apple / Facebook)
- Telegram OTP link UI (backend endpoint exists, but UI is not in scope)
- Voice search on Patient Home (Figma shows it; no `speech_to_text` package; will be removed or deferred)

**Open — needs backend**

- Structured Prescription entity (§6.1 #3, §6.2 #5)
- Doctor Profile — Education / Certification cards may not be exposed on `GET /api/doctor/{id}`; verify and add if missing (§6.2 #3)
- ~~Clinic latitude / longitude capture — **NEW**. The nearby endpoint shipped 2026-06-01 requires coords, but `EditClinicProfileScreen` has no lat/lng fields. New clinics will be silently excluded from `/api/clinic/nearby` results. **Backend verified closed 2026-06-01** — `UpdateClinicDto:98-99` and `CreateClinicDto:58-59` accept lat/lng; `ClinicService.UpdateClinicProfileAsync:183-184` persists them. Flutter is the only remaining work. (§9 P0-1)~~ ✅ **Closed 2026-06-03** — `EditClinicProfileScreen` and `RegisterClinicScreen` now capture lat/lng + operating hours.
- ~~`GET /api/patient/favorites` (list all favorites) — does not exist; `getFavorites()` in `PatientService` throws `UnsupportedError`.~~ ✅ **Closed 2026-06-03** — endpoint wired in `PatientService.getFavorites()`.

**Open — backend complete, Flutter work pending**

- Nearby / Map screen (§6.2 #2)
- Doctor Profile rich UI rebuild (§6.2 #3) — patients count, calendar, slots, experience stats
- **Manage Schedule screen is a stub** — §9 D-Clinic-1 (CRITICAL). Loads hardcoded mock data, save sends `slotDurationMinutes: 30, maxPatients: 10` regardless of UI input. `GET /api/doctor/{id}/schedules` exists but is never called.
- **Clinic Doctor Detail schedule section is fabricated** — §9 D-Clinic-3 (CRITICAL). Displays "09:00 AM - 05:00 PM" hardcoded; comment on line 300 says "Mock schedule data - in real app would come from API".
- Clinic Doctor Detail loads from list endpoint instead of detail endpoint, missing degree/university/bio/languages/boardCertification/yearsOfExperience/graduationYear. (§9 D-Clinic-4)

**Open — backend complete, Flutter work pending (small)**

- Clinic Appointments dedicated screen (§6.2 #9)

**Closed — Flutter data-loss / broken TODO (3 screens silently drop data) ✅ 2026-06-03**

- ~~Medical History — `// TODO: Replace with actual API call`. Returns empty list with hardcoded `_chronicConditions = ['Hypertension', 'Asthma']`. `GET /api/medicalrecord/patient/{id}` is never called.~~ ✅ **Closed 2026-06-03** — screen already wired to `PatientMedicalHistoryService.getMedicalRecords()` → real `GET /api/medicalrecord/patient/{id}`. Description in `REMAINING_WORK.md` was outdated.
- ~~Submit Review — `// In a real app, this would call the reviews API`. Fake `Future.delayed(800ms)`, success snackbar, but data is discarded. `ReviewService.submitReview()` is implemented but the screen never calls it.~~ ✅ **Closed 2026-06-03** — screen already calls `ReviewService.submitReview()` → real `POST /api/review`. Description in `REMAINING_WORK.md` was outdated.
- ~~Add Family Member — same pattern. `// In a real app, this would call an API`. Fake delay, success snackbar, data discarded.~~ ✅ **Closed 2026-06-03** — screen already calls `PatientService.addFamilyMember()` → real `POST /api/patient/family-members`. Description in `REMAINING_WORK.md` was outdated. Also added missing health fields (`medicalHistory`, `allergies`, `chronicDiseases`) to form.

**Open — Flutter role-side data gaps**

- Doctor email is never captured at registration (§9 D-Doctor-1)
- ~~Specialization lists differ between `register_doctor_screen.dart` and `edit_doctor_profile_screen.dart` — a doctor registering as "Dentist" or "Ophthalmologist" cannot find those values in the edit dropdown (§9 D-Doctor-2)~~ ✅ **Closed 2026-06-03** — unified into `AppConstants.specializations`.
- No doctor-facing "My Schedule" screen — only clinics can edit doctor schedules (§9 D-Doctor-3)
- Doctor's `associatedClinics` display is always empty because there's no UI to populate it (§9 D-Doctor-4)
- `clinic_doctor_detail_screen.dart` has no edit mechanism for per-doctor fee or active status after registration (`PUT /api/clinic/doctors/{id}` exists in `app_constants.dart:54` but is never called) (§9 D-Clinic-5)
- Clinic registration does not capture full address or email; areas list is `['Area 1', 'Area 2', 'Area 3']` placeholder (§9 D-Clinic-8, D-Clinic-9)
- `EditClinicProfileScreen` missing operating hours, photo gallery (only logo), specialty tags (§9 D-Clinic-7)

**Open — Backend supported but UI doesn't expose it (Flutter wiring only)**

- Favorite toggle on doctor cards (`browse_doctors_screen.dart:134`, `favorites_screen.dart:94`) — `onFavoriteToggle: () {}`. Backend has `POST /api/patient/favorite/{doctorId}`. (§9 A-3, A-4)
- Community post delete — `DELETE /api/community/posts/{id}` exists in `app_constants.dart:88` but no service method or UI button calls it. (§9 C-4)
- Community comment delete — same pattern. (§9 C-5)
- Notification delete — no backend endpoint AND no UI; this is a backend gap. (§9 C-6)

**Open — UX polish**

- Community search only filters on Enter, no live search, no clear button (§9 E-1)
- Community specializations list is hardcoded; duplicates what `getSpecializations()` should fetch (§9 E-2)
- Doctor Community "Add post" routes to `patientCreatePost` (wrong role context) (§9 E-3)
- Notification tap marks as read but does not deep-link to related entity (§9 E-4)
- Silent mock-fallback pattern in 19+ service code paths (`useMockDataFallback = false` by default) makes debugging API failures hard (§9 E-5)
- Family members: no edit screen (workaround: delete + re-add) (§9 E-6)
- Reviews: no edit/delete after submission (§9 E-7)
- Patient profile: blood type, allergies, chronic diseases are stored but not surfaced in a dedicated view — only in the edit form (§9 E-8)
- Clinic payments: timeframe filter works but no custom date range, no CSV/PDF export (§9 E-9)

See **§9 — UX & Flow Audit** for the full breakdown with file:line references and the P0–P3 priority table.

---

## 1. Screen Inventory

| # | Screen Name (Figma) | Flutter Filename | User Type | Features & Data (from Design) | Design→Flutter | Backend Coverage |
|---|---------------------|------------------|-----------|------------------------------|----------------|------------------|
| 1 | **Launch / Splash** | `splash_screen.dart` | All | App logo, loading animation | ✅ Accurate | ✅ Backend: N/A (local) |
| 2 | **Onboarding 1** | `onboarding_screen.dart` | All | Illustration, "Easy Doctor Booking", page indicator | ✅ Accurate | ✅ Backend: N/A (local) |
| 3 | **Onboarding 2** | `onboarding_screen.dart` | All | Illustration, "Smart Clinic App", page indicator | ✅ Accurate | ✅ Backend: N/A (local) |
| 4 | **Onboarding 3** | `onboarding_screen.dart` | All | Illustration, "Your Health Helper", page indicator | ✅ Accurate | ✅ Backend: N/A (local) |
| 5 | **Login** | `login_screen.dart` | All | Phone, password, forgot password, social login (Google/Apple/Facebook), sign-up link | ✅ Accurate | ✅ Backend: `POST /api/auth/login` |
| 6 | **Role Selection** | `role_selection_screen.dart` | All | Patient / Doctor / Clinic selection cards | ✅ Accurate | ✅ Backend: N/A (local choice) |
| 7 | **Register Patient** | `register_patient_screen.dart` | Patient | Full name, phone, password, confirm password, gender, age | ✅ Accurate | ✅ Backend: `POST /api/auth/register/patient` |
| 8 | **Register Doctor** | `register_doctor_screen.dart` | Doctor | Full name, phone, password, specialization, license upload | ✅ Accurate | ✅ Backend: `POST /api/auth/register/doctor` |
| 9 | **Register Clinic** | `register_clinic_screen.dart` | Clinic | Facility name, phone, password, address, license upload | ✅ Accurate | ✅ Backend: `POST /api/auth/register/clinic` |
| 10 | **Forgot Password** | `forgot_password_screen.dart` | All | Phone input, send OTP via Telegram | ✅ Accurate | ✅ Backend: `POST /api/auth/forgot-password` |
| 11 | **Verify OTP** | `verify_otp_screen.dart` | All | 6-digit OTP input, resend timer | ✅ Accurate | ✅ Backend: `POST /api/auth/verify-otp` |
| 12 | **Reset Password** | `reset_password_screen.dart` | All | New password, confirm password | ✅ Accurate | ✅ Backend: `POST /api/auth/reset-password` |
| 13 | **Patient Home** | `patient_home_screen.dart` | Patient | App bar with notifications, search bar (with voice), Services section (Clinic Booking card), Popular Doctors horizontal scroll, Community card, custom bottom nav (Home/Appointments/AI Bot/Nearby/Profile) | ⚠️ Partial | ✅ Backend: `GET /api/doctor/popular`, `GET /api/doctor`, notifications unread count |
| 14 | **Browse Doctors** | `browse_doctors_screen.dart` | Patient | Search, filter by specialty, doctor list cards with photo/name/specialty/rating/location/fee | ✅ Accurate | ✅ Backend: `GET /api/doctor` (with filters) |
| 15 | **Specializations** | `specializations_screen.dart` | Patient | Grid of medical specialties (Cardiology, Dermatology, etc.) | ✅ Accurate | ✅ Backend: `GET /api/doctor/specializations` |
| 16 | **Doctor Profile (Patient View)** | `doctor_profile_screen.dart` | Patient | Doctor photo, name, specialization, experience, patients count, rating, education, certification, calendar date picker, available time slots, "Confirm Appointment" CTA | ⚠️ Partial | ✅ Backend: `GET /api/doctor/{id}`, `GET /api/doctor/{id}/schedules`, `GET /api/doctor/{id}/available-slots` |
| 17 | **Book Appointment** | `book_appointment_screen.dart` | Patient | Doctor info card, date picker, time slot chips, family member toggle, family member list, booking summary, confirm button | ⚠️ Partial | ✅ Backend: `POST /api/appointment` |
| 18 | **Confirm Appointment** | `appointment_confirmation_screen.dart` | Patient | Success checkmark, appointment summary card (date, doctor, clinic, queue number), "My Appointments" CTA | ⚠️ Partial | ✅ Backend: N/A (result screen) |
| 19 | **My Appointments** | `my_appointments_screen.dart` | Patient | Tab filter (Upcoming/Completed/Cancelled), appointment cards with doctor photo, name, date, time, status, action buttons (View Details, Rebook) | ✅ Accurate | ✅ Backend: `GET /api/appointment/patient` |
| 20 | **Appointment Detail** | `appointment_detail_screen.dart` | Patient | Doctor info, appointment date/time, status badge, clinic location, cancel/reschedule actions | ✅ Accurate | ✅ Backend: `GET /api/appointment/{id}` |
| 21 | **Queue Tracker** | `queue_tracker_screen.dart` | Patient | Live queue position, estimated wait time, doctor info, appointment details | ✅ Accurate | ✅ Backend: `GET /api/appointment/queue/tracker/{id}` |
| 22 | **Community Feed** | `community_feed_screen.dart` | Patient | Search bar, specialization filter chips, post cards (author avatar, name, time, content, comments count), FAB for create post | ⚠️ Partial | ✅ Backend: `GET /api/community/posts` |
| 23 | **Create Post** | `create_post_screen.dart` | Patient | Author profile preview, text area, specialization selector, image clip option | ⚠️ Partial | ✅ Backend: `POST /api/community/posts` |
| 24 | **Post Detail** | `post_detail_screen.dart` | Patient | Full post content, comment list, add comment input | ✅ Accurate | ✅ Backend: `GET /api/community/posts/{id}/comments`, `POST /api/community/posts/{id}/comments` |
| 25 | **Notifications** | `notifications_screen.dart` | Patient | Notification list grouped by date (Recent/Yesterday), "Mark all as read", empty state | ✅ Accurate | ✅ Backend: `GET /api/notification`, `PUT /api/notification/{id}/read` |
| 26 | **Patient Profile** | `patient_profile_screen.dart` | Patient | Profile photo, name, email, menu items (Medical History, My Favorites, Edit Profile, About), bottom nav | ✅ Accurate | ✅ Backend: `GET /api/patient/profile` |
| 27 | **Edit Patient Profile** | `edit_patient_profile_screen.dart` | Patient | Name, phone, email, gender, age, address, blood type, allergies, chronic diseases | ✅ Accurate | ✅ Backend: `PUT /api/patient/profile` |
| 28 | **Medical History** | `medical_history_screen.dart` | Patient | Chronic conditions chips, current medications list, lab test results | ⚠️ Partial | ✅ Backend: `GET /api/medicalrecord/patient/{id}` |
| 29 | **Favorites** | `favorites_screen.dart` | Patient | Favorite doctors list with photo, name, specialty, fee, "Make Appointment" CTA | ✅ Accurate | ✅ Backend: `GET /api/patient/favorite/{doctorId}` (toggle), `GET /api/doctor` |
| 30 | **Family Members** | `family_members_screen.dart` | Patient | Family member list with photo, name, relation, age, primary member badge, add/remove actions | ✅ Accurate | ✅ Backend: `GET /api/patient/family-members`, `POST /api/patient/family-members`, `DELETE /api/patient/family-members/{id}` |
| 31 | **Add Family Member** | `add_family_member_screen.dart` | Patient | Name, relation (Parent/Child/Spouse/Sibling/Other), age, gender, blood type, medical history, allergies, chronic diseases | ✅ Accurate | ✅ Backend: `POST /api/patient/family-members` |
| 32 | **Submit Review** | `submit_review_screen.dart` | Patient | Star rating (1-5), comment text area, submit button | ✅ Accurate | ✅ Backend: `POST /api/review` |
| 33 | **AI Chatbot** | *(not found)* | Patient | Chat interface with AI avatar, message bubbles, suggested actions, text input with voice | ❌ **Missing** | ⚠️ Partial: No dedicated AI backend endpoint; could use community or doctor search as fallback |
| 34 | **Nearby (Map)** | *(not found)* | Patient | Map view with clinic/doctor pins, search bar, specialty filter chips, list/map toggle | ❌ **Missing** | ⚠️ Partial: `GET /api/clinic` returns lat/lng but no map integration in Flutter |
| 35 | **Doctor Dashboard** | `doctor_dashboard_screen.dart` | Doctor | Today's appointments total, breakdown (New Visit/Follow-up/Walk-in/Online), earnings card, "View Today's Schedule" CTA, Queue Summary (Waiting/With Doctor/Completed) | ⚠️ Partial | ✅ Backend: `GET /api/doctor/dashboard`, `GET /api/doctor/live-queue` |
| 36 | **Doctor Appointments** | `doctor_appointments_screen.dart` | Doctor | Date selector, appointment list with time, patient name, type, status | ✅ Accurate | ✅ Backend: `GET /api/appointment/doctor` |
| 37 | **Doctor Queue** | `doctor_queue_screen.dart` | Doctor | Live queue list with patient name, appointment type, status, call-next action | ✅ Accurate | ✅ Backend: `GET /api/appointment/queue/today`, `POST /api/appointment/queue/call-next` |
| 38 | **Open Queue (Consultation)** | `consultation_screen.dart` | Doctor | Patient header with ID, vitals (Blood Pressure, Heart Rate), SOAP Summary (Subjective/Objective/Assessment/Plan), prescriptions list, "Add Prescription" CTA, History link | ⚠️ Partial | ✅ Backend: `GET /api/doctor/patients/{id}/history`, `POST /api/doctor/session/{id}`, `POST /api/medicalrecord` |
| 39 | **Prescription** | `consultation_screen.dart` (modal/partial) | Doctor | Medication name, dosage, frequency, duration, timing pills (Before/After/With Food/Bedtime), patient instructions | ⚠️ Partial | ✅ Backend: `POST /api/medicalrecord` (includes prescription field) |
| 40 | **History (Patient)** | `doctor_patient_history_screen.dart` | Doctor | Patient name, age, gender, blood type, chronic conditions chips, current medications list with status | ✅ Accurate | ✅ Backend: `GET /api/doctor/patients/{id}/history` |
| 41 | **Doctor Profile** | `doctor_profile_screen.dart` (doctor view) | Doctor | Profile photo, name, general summary, specialty, consultation fee, clinic affiliations, professional details, education & certifications, associated clinics, professional bio | ⚠️ Partial | ✅ Backend: `GET /api/doctor/profile` |
| 42 | **Edit Doctor Profile** | `edit_doctor_profile_screen.dart` | Doctor | Specialty, sub-specialty, experience, languages, degree, university, graduation year, board certification, bio | ✅ Accurate | ✅ Backend: `PUT /api/doctor/profile` |
| 43 | **Doctor QR Code** | `doctor_qr_code_screen.dart` | Doctor | QR code display for clinic scanning | ✅ Accurate | ✅ Backend: `GET /api/doctor/qr-code` |
| 44 | **Doctor Community** | `doctor_community_screen.dart` | Doctor | Same as patient community feed | ✅ Accurate | ✅ Backend: `GET /api/community/posts` |
| 45 | **Doctor Notifications** | `doctor_notifications_screen.dart` | Doctor | Same notification list pattern | ✅ Accurate | ✅ Backend: `GET /api/notification` |
| 46 | **Clinic Dashboard** | `clinic_dashboard_screen.dart` | Clinic | Header with clinic logo/name, date selector with "Live" badge, stats cards (Paid Patients, Walk-ins, Revenue), Quick Actions (Add Walk-in, View Queue), Queue Summary, Recent Appointments list | ⚠️ Partial | ✅ Backend: `GET /api/appointment/clinic/dashboard` |
| 47 | **Clinic Queue** | `clinic_queue_screen.dart` | Clinic | Live queue list with patient name, doctor name, time, status, payment status | ✅ Accurate | ✅ Backend: `GET /api/appointment/clinic/queue` |
| 48 | **Add Walk-in Patient** | `walk_in_booking_screen.dart` | Clinic | Emergency toggle, search existing patient, patient details form (name, phone, age, gender), clinical info (chief complaint), scheduling (assign time slot), accept payment toggle, confirm/cancel buttons | ⚠️ Partial | ✅ Backend: `POST /api/appointment/clinic-booking` |
| 49 | **Clinic Appointments** | `clinic_dashboard_screen.dart` (section) | Clinic | Date selector, "Currently in Queue" count, appointment cards with time, patient name, type, status | ⚠️ Partial | ✅ Backend: `GET /api/appointment/clinic/queue` |
| 50 | **Manage Doctors** | `clinic_doctors_screen.dart` | Clinic | Doctor cards with photo, name, specialty, status badge, remove action, "Add New Doctor" CTA | ✅ Accurate | ✅ Backend: `GET /api/clinic/doctors`, `DELETE /api/clinic/doctors/{id}` |
| 51 | **Register Doctor to Clinic** | `register_doctor_to_clinic_screen.dart` | Clinic | Scan QR or manual registration form | ✅ Accurate | ✅ Backend: `POST /api/clinic/doctors/register`, `GET /api/clinic/doctors/scan/{qrCodeKey}` |
| 52 | **Scan Doctor QR** | `scan_doctor_qr_screen.dart` | Clinic | Camera QR scanner view | ✅ Accurate | ✅ Backend: `GET /api/clinic/doctors/scan/{qrCodeKey}` |
| 53 | **Doctor Detail (Clinic View)** | `clinic_doctor_detail_screen.dart` | Clinic | Doctor profile at clinic, schedule, consultation fee, notes | ✅ Accurate | ✅ Backend: `GET /api/clinic/doctors/{id}` |
| 54 | **Manage Schedule** | `manage_schedule_screen.dart` | Clinic | Date picker, working hours (shift start/end), break time (start/end), max patients/day, generated slots preview | ⚠️ Partial | ✅ Backend: `POST /api/doctor/{id}/schedules` |
| 55 | **Clinic Payments** | `clinic_payments_screen.dart` | Clinic | Payments dashboard with doctor filter, timeframe filter, revenue stats, payment list | ⚠️ Partial | ✅ Backend: `GET /api/appointment/clinic/payments-dashboard` |
| 56 | **Clinic Profile** | `clinic_profile_screen.dart` | Clinic | Clinic logo, name, address, phone, email, license info | ✅ Accurate | ✅ Backend: `GET /api/clinic/profile` |
| 57 | **Edit Clinic Profile** | `edit_clinic_profile_screen.dart` | Clinic | Facility name, facility ID, primary address | ✅ Accurate | ✅ Backend: `PUT /api/clinic/profile` |
| 58 | **Clinic Patient Search** | `clinic_patient_search_screen.dart` | Clinic | Search patients by name/phone, patient list with basic info | ✅ Accurate | ✅ Backend: `GET /api/patient/search` |
| 59 | **Clinic Notifications** | `clinic_notifications_screen.dart` | Clinic | Same notification pattern | ✅ Accurate | ✅ Backend: `GET /api/notification` |

---

## 2. Design → Flutter Match Assessment (Detailed)

### 2.1 Patient Screens

| Screen | Match Level | Issues / Divergences |
|--------|-------------|---------------------|
| Home | ⚠️ Partial | Bottom nav index 3 maps to "Nearby" but routes to `browse_doctors` because Nearby screen is missing. AI Chatbot (index 2) navigates to Community, not a chatbot. The floating action button in the center of nav is visually present but functionally routes to Community, not AI. |
| Doctor Profile | ⚠️ Partial | Flutter implementation is significantly simpler than Figma. Missing: Experience/Patients stats row, Professional Background section (Education/Certification cards), calendar date picker with day names, Available Slots grid. Only shows basic info + fee + Book Appointment button. |
| Book Appointment | ⚠️ Partial | Figma shows inline calendar with date arrows and day chips. Flutter uses native `showDatePicker` modal. Figma shows time slot grid (3 columns). Flutter uses `Wrap` with `ChoiceChip`. Family member toggle exists but family member list design differs (no avatar images in Flutter). |
| Confirm Appointment | ✅ Accurate | ✅ FIXED 2026-06-01 — screen now receives the real `Appointment` from the booking flow and renders dynamic doctor name, specialization, date, time, clinic, queue number, and family member name. |
| Community Feed | ⚠️ Partial | Figma shows filter chips (All/Internal/Neurology/Dentistry) with rounded pill style. Flutter uses `ChoiceChip` with slightly different styling. ✅ FIXED 2026-06-01 — share button added to post cards. |
| Create Post | ⚠️ Partial | Figma shows specialization dropdown with image clip icon. Flutter likely has a simpler selector. Missing: specialization selector in screenshot review. |
| Appointments | ✅ Accurate | Matches Figma closely with tab filters and appointment cards. |
| Notifications | ✅ Accurate | Matches Figma with grouped list and empty state. |
| Profile | ✅ Accurate | Matches Figma menu structure. |
| Family Members | ✅ Accurate | Matches Figma bento-style list with remove action. |
| AI Chatbot | ❌ Missing | No Flutter screen exists. Nav index 2 goes to Community instead. |
| Nearby | ❌ Missing | No Flutter screen exists. Nav index 3 goes to Browse Doctors instead. |

### 2.2 Doctor Screens

| Screen | Match Level | Issues / Divergences |
|--------|-------------|---------------------|
| Dashboard | ⚠️ Partial | Figma shows bento grid with "New Visit 8", "Follow-up 10", "Walk-in 4", "Online 2" in a 2x2 card layout. Flutter uses horizontal row chips. Figma shows earnings with dollar icon in a distinct card. Flutter matches. Figma Queue Summary shows colored dot indicators. Flutter uses icon containers. Overall layout similar but card internal structure differs. |
| Open Queue / Consultation | ⚠️ Partial | Figma shows detailed patient card with ID, date, time, type badge. Flutter `consultation_screen.dart` reviewed — matches SOAP structure but may differ in exact layout. Figma prescriptions show medication icon + name + dosage in a card. Flutter likely matches. |
| Prescription | ⚠️ Partial | Likely implemented as part of consultation screen, not a standalone screen. Figma shows standalone Prescription screen with full medication builder. |
| History | ✅ Accurate | Matches Figma patient history view. |
| Profile | ⚠️ Partial | Figma shows rich profile with General Summary card, Professional Details grid, Education & Certifications timeline, Associated Clinics list, Professional Bio. Flutter doctor profile may be simpler. |

### 2.3 Clinic Screens

| Screen | Match Level | Issues / Divergences |
|--------|-------------|---------------------|
| Dashboard | ⚠️ Partial | Figma shows "Today's Overview" date banner with Live badge — Flutter matches. Stats cards (Paid Patients, Walk-ins, Revenue) match. Quick Actions (Add Walk-in, View Queue) match. Queue Summary with 3-column counts matches. Recent Appointments list matches. |
| Add Walk-in | ⚠️ Partial | Figma shows Emergency Status toggle with priority explanation. Flutter `walk_in_booking_screen.dart` not fully reviewed but form fields should match. Missing: search existing patient field in Flutter? |
| Appointments | ⚠️ Partial | Figma shows date selector with day chips (Mon/Tue/Wed/Thu) and "Currently in Queue" banner. Clinic dashboard in Flutter shows recent appointments but not a dedicated appointments screen with date selector. |
| Manage Doctors | ✅ Accurate | Figma shows doctor cards with avatar, name, specialty, status dot, remove button, and "Add New Doctor" card. Flutter `clinic_doctors_screen.dart` should match. |
| Time Slots | ⚠️ Partial | Figma shows date picker with prev/next arrows, day chips (Mon 12, Tue 13, etc.), shift start/end time spinners, break start/end, max patients input, generated slots preview grid. Flutter `manage_schedule_screen.dart` should implement this but exact match unknown without reading. |

---

## 3. Backend Coverage Audit

### 3.1 Fully Covered Screens (✅)

All auth screens, patient profile/management, doctor browsing, appointment booking/canceling/rescheduling, queue tracking, reviews, community posts/comments, notifications, family members, medical records, clinic management, doctor QR linking, payments dashboard.

### 3.2 Partially Covered Screens (⚠️)

| Screen | Backend Gap |
|--------|-------------|
| AI Chatbot | ❌ No AI/chatbot backend endpoint exists. The design shows an AI chatbot with symptom checking and doctor recommendations. Backend has no LLM integration, no `/api/ai/chat` endpoint. |
| Nearby / Map | ⚠️ Backend returns `latitude` and `longitude` for clinics (`Clinic` entity), but there is no geospatial search endpoint (no `nearby?lat=&lng=&radius=`). The Flutter app doesn't implement map view anyway. |
| Prescription (standalone) | ⚠️ Backend `MedicalRecord` has a `Prescription` text field, but no structured medication entity. The Figma design shows a detailed medication builder (dosage, frequency, duration, timing). Backend stores this as free text, not structured data. |
| Appointment Confirmation | ⚠️ The confirmation screen in Figma shows dynamic booking summary with selected date/time/family member. Flutter shows static mock data. Backend returns appointment details but Flutter doesn't wire them to the confirmation screen. |

### 3.3 Backend Endpoints with No Design Surface (Orphaned APIs)

| Endpoint | Purpose | Design Surface? | Status |
|----------|---------|-----------------|--------|
| `POST /api/auth/social-login` | Google/Apple/Facebook login | ⚠️ Login screen shows social buttons but they are non-functional (`onTap: () {}`) | **Out of scope** — backend returns 501; deferred |
| `POST /api/auth/telegram-register` | Link Telegram for OTP | ❌ No UI for Telegram registration | **Out of scope** — Flutter UI not planned |
| `POST /api/upload/license` | Upload license documents | ⚠️ Used in registration but not a standalone screen | Working as expected |
| `GET /api/doctor/qr-code` | Get doctor QR code | ✅ Doctor QR screen | Working as expected |
| `PUT /api/appointment/{id}/status` | Change appointment status | ⚠️ Used internally but no explicit "change status" UI for clinic/doctor | Verify UI exists |
| `PUT /api/appointment/{id}/reschedule` | Reschedule appointment | ⚠️ My Appointments screen may have this but not verified | Verify UI exists |
| `POST /api/appointment/{id}/start-checkup` | Start patient checkup | ⚠️ Used in clinic flow but UI button may be missing | Verify UI exists |

---

## 4. Sanity Check

### 4.1 Orphaned Screens (no clear navigation path)

| Screen | Issue | Recommendation |
|--------|-------|----------------|
| AI Chatbot | Exists in Figma nav (index 2) but Flutter routes to Community. No actual chatbot screen exists. | **Out of scope** — no AI/LLM integration planned. |
| Nearby | Exists in Figma nav (index 3) but Flutter routes to Browse Doctors. No map screen exists. | ✅ **Backend ready** (2026-06-01: `/api/clinic/nearby`, `/api/doctor/nearby` shipped). Flutter work remains. |
| Prescription (standalone) | Figma shows a full Prescription screen, but Flutter implements prescriptions inside Consultation screen. | Open — clarify standalone vs modal. Would need structured backend storage. |
| Onboarding 2 & 3 | Figma has 3 onboarding screens. Flutter `onboarding_screen.dart` likely supports multiple pages but need to verify all 3 illustrations are present. | ✅ Closed — all 3 PNGs verified present. |

### 4.2 Broken / Illogical Flows

| Flow | Issue |
|------|-------|
| Patient Home → AI Chatbot (nav index 2) | Goes to Community instead of chatbot. User expects chat, sees forum. | **Out of scope** — no AI implementation planned |
| Patient Home → Nearby (nav index 3) | Goes to Browse Doctors instead of map. User expects map, sees list. | **Backend ready** (2026-06-01: `/api/clinic/nearby` shipped). Flutter work needed to wire. |
| Book Appointment → Confirm Appointment | Flutter shows static success data instead of actual booking details. User can't verify what was booked. | ✅ **Fixed** 2026-06-01 — real `Appointment` data flows through |
| Doctor Dashboard → View Schedule | Button exists but may not pass date context to appointments screen. | Verify — may still need fixing |
| Clinic Dashboard → Recent Appointments | Tapping an appointment may not navigate to detail view. | Verify — may still need fixing |
| Social Login | Buttons are present but all have empty `onTap: () {}`. Backend `social-login` returns 501. | **Out of scope** — defer |

### 4.3 UX Logic Issues

1. **No map integration**: The Nearby screen is a key feature in Figma (with map pins, search, filters) but completely missing in Flutter. This is a major feature gap. ✅ **Backend ready** (2026-06-01: geospatial endpoints shipped). Flutter work remains.
2. **AI Chatbot is fake**: The nav has a cute robot icon but leads to Community. This is misleading UX. **Out of scope** — no AI implementation planned.
3. ~~**Appointment confirmation uses static data**: After booking, the user sees "Tomorrow, 10:00 AM" and "Dr. Ahmed Hassan" regardless of actual selection. This erodes trust.~~ ✅ **Fixed** 2026-06-01 — real `Appointment` data now renders.
4. **Doctor profile is oversimplified**: The Figma design shows rich professional info (education, certification, calendar, slots). The Flutter implementation is a basic card with a Book button. This reduces conversion. **Partial backend progress** (2026-06-01: `totalPatients` + clinic coords added); Flutter UI rebuild still needed.
5. **No specialization filtering on Home**: Figma Home shows "Clinic Booking" as a service. Flutter has it but tapping goes to Specializations. This is correct, but the Popular Doctors section has no "View All" or filter.
6. **Community nav inconsistency**: Patient nav calls index 2 "AI Bot" with a robot icon. Doctor nav calls index 2 "Community" with a chat icon. Clinic nav has no community tab at all. **Out of scope** — relates to missing AI chatbot.

---

## 5. User Flows

### 5.1 Patient Flow

```
[Launch] → [Onboarding] → [Login] → [Patient Home]

From Home:
├── Search Bar → [Browse Doctors] (with query)
├── Services → Clinic Booking → [Specializations] → [Browse Doctors] → [Doctor Profile] → [Book Appointment] → [Confirm Appointment] → [My Appointments]
├── Popular Doctors → [Doctor Profile] → [Book Appointment] → [Confirm Appointment]
├── Community Card → [Community Feed] → [Create Post] / [Post Detail]
├── Notifications Icon → [Notifications]
├── Bottom Nav:
│   ├── Home (current)
│   ├── Appointments → [My Appointments] → [Appointment Detail] → Cancel/Reschedule
│   ├── AI Bot → ❌ Routes to Community instead
│   ├── Nearby → ❌ Routes to Browse Doctors instead
│   └── Profile → [Patient Profile] → [Edit Profile] / [Medical History] / [Favorites] / [Family Members] / [About]
```

**Broken Points:**
- AI Bot nav item is misleading (goes to Community)
- Nearby nav item is misleading (goes to Browse Doctors)
- Book Appointment → Confirm Appointment shows static data
- Doctor Profile missing rich info (calendar, slots, education)

### 5.2 Doctor Flow

```
[Launch] → [Onboarding] → [Login] → [Doctor Dashboard]

From Dashboard:
├── Today's Appointments stats (informational)
├── Earnings card (informational)
├── View Today's Schedule → [Doctor Appointments]
├── Queue Summary → [Doctor Queue]
├── Bottom Nav:
│   ├── Dashboard (current)
│   ├── Schedule → [Doctor Appointments] → [Consultation] / [Open Queue]
│   ├── Community → [Doctor Community]
│   └── Profile → [Doctor Profile] → [Edit Profile] / [QR Code] / [Notifications]
```

**Broken Points:**
- Dashboard stats layout differs from Figma (2x2 grid vs row chips)
- No direct path from queue to patient history (needs to go through consultation)
- Prescription is not a standalone screen (inside consultation)

### 5.3 Clinic Flow

```
[Launch] → [Onboarding] → [Login] → [Clinic Dashboard]

From Dashboard:
├── Date selector / Live badge (informational)
├── Stats cards (Paid Patients, Walk-ins, Revenue)
├── Quick Actions:
│   ├── Add Walk-in → [Walk-in Booking] → [Clinic Queue]
│   └── View Queue → [Clinic Queue]
├── Queue Summary → [Clinic Queue]
├── Recent Appointments → [Clinic Queue] / [Appointment Detail]
├── Bottom Nav:
│   ├── Dashboard (current)
│   ├── Doctors → [Manage Doctors] → [Doctor Detail] / [Register Doctor] / [Scan QR]
│   ├── Payments → [Clinic Payments]
│   └── Profile → [Clinic Profile] → [Edit Profile] / [Notifications]
```

**Broken Points:**
- No dedicated Appointments screen with date selector (only Recent Appointments section on Dashboard)
- Manage Schedule is accessible only from Doctor Detail, not from Dashboard
- No quick action to "Manage Schedule" from Dashboard

---

## 6. Gap Summary

### 6.1 What's in Designs but Missing/Broken in Backend

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| 1 | **AI Chatbot endpoint** — No LLM or rule-based chatbot API exists. The design shows AI symptom checking and doctor recommendations. | High — Core feature missing | **Out of scope** — deferred |
| 2 | **Geospatial search** — No `nearby?lat=&lng=&radius=` endpoint. Clinics have lat/lng but can't be searched by proximity. | Medium — Map feature can't work | ✅ **Closed** — 2026-06-01: `/api/clinic/nearby` + `/api/doctor/nearby` shipped with `lat/lng/radiusKm/specialization/search` |
| 3 | **Structured Prescription entity** — Medication details (dosage, frequency, duration, timing) are stored as free text in `MedicalRecord.Prescription`. No `Medication` table. | Medium — Can't build rich prescription UI | **Open** — only remaining backend gap that's in scope |
| 4 | **Social login** — `POST /api/auth/social-login` returns HTTP 501 Not Implemented. | Low — Buttons exist but are non-functional | **Out of scope** — deferred |
| 5 | **Telegram registration UI** — Backend supports `POST /api/auth/telegram-register` but no Flutter screen exists to link Telegram Chat ID. | Low — OTP works but Telegram opt-in missing | **Out of scope** — Flutter UI not planned |
| 6 | **Clinic lat/lng capture in API DTO** — `PUT /api/clinic/profile` is called by `EditClinicProfileScreen` with a payload that does NOT include `latitude`/`longitude`. The 2026-06-01 nearby endpoint silently excludes items without coordinates. Net result: every clinic created or updated through the Flutter app is invisible to `/api/clinic/nearby`. | High — Newly-shipped feature is silently broken for the app's primary entry path. | **Backend closed (verified 2026-06-01) — Flutter only.** `UpdateClinicDto` (line 98-99) and `CreateClinicDto` (line 58-59) both accept `Latitude`/`Longitude`; `Clinic` entity (line 46-48) persists; `ClinicService.UpdateClinicProfileAsync` (line 183-184) applies them. Remaining work: add lat/lng fields to `EditClinicProfileScreen` and `RegisterClinicScreen`, send them in the payload. Coupling resolved — see §9 P0-1. |

#### 6.1.1 Verification — 2026-06-01

> Triggered by §6.1 #6. The audit hypothesized the backend DTO was missing lat/lng, requiring a backend change. The verification below shows the DTO and entity are already correct; the gap is Flutter-only.

| Layer | File / Line | Finding |
|-------|-------------|---------|
| `Clinic` entity | `Models/Entities/Clinic.cs:46-48` | ✅ Has `Latitude` and `Longitude` (`double?`) |
| `CreateClinicDto` | `DTOs/Clinic/ClinicDtos.cs:58-59` | ✅ Has `Latitude` and `Longitude` (`double?`, optional) |
| `UpdateClinicDto` | `DTOs/Clinic/ClinicDtos.cs:98-99` | ✅ Has `Latitude` and `Longitude` (`double?`, optional) |
| `ClinicDto` (read response) | `DTOs/Clinic/ClinicDtos.cs:19-20` | ✅ Has `Latitude` and `Longitude` |
| `ClinicController.Update` | `Controllers/ClinicController.cs:53-58` | ✅ Accepts `UpdateClinicDto` (with lat/lng) |
| `ClinicController.UpdateClinicProfile` | `Controllers/ClinicController.cs:116-122` | ✅ Accepts `UpdateClinicDto` (the one Flutter calls) |
| `ClinicService.UpdateClinicAsync` | `Services/Implementations/ClinicService.cs:183-184` | ✅ `if (dto.Latitude.HasValue) clinic.Latitude = dto.Latitude;` — persisted |
| `ClinicService.CreateClinicAsync` | `Services/Implementations/ClinicService.cs:139-140` | ✅ `Latitude = dto.Latitude, Longitude = dto.Longitude` — persisted |
| `ClinicService.GetNearbyClinicsAsync` | `Services/Implementations/ClinicService.cs:67, 99` | ✅ Filters `c.Latitude != null && c.Longitude != null`; computes Haversine distance |
| `CHANGELOG.md:28` | "Items without coordinates are silently excluded" | ✅ Confirmed behaviour matches DTO/entity shape |

**Net result:** No backend changes needed for §6.1 #6. The Flutter `EditClinicProfileScreen` (and `RegisterClinicScreen`) are the only remaining work — see §9 P0-1.

**Bonus finding during verification:** The `Clinic` entity has `OpeningTime` and `ClosingTime` (`TimeSpan?`, lines 50-52) but these were **NOT** in `UpdateClinicDto` or `CreateClinicDto`. ✅ **Closed 2026-06-03** — `OpeningTime`/`ClosingTime` added to both DTOs, `ClinicDto`, and wired in `ClinicService` (create + update). Remaining work: add form fields to Flutter edit/register screens.

**Bonus finding 2:** `GET /api/clinic/doctors/{doctorId}` (controller line 85-90) and `PUT /api/clinic/doctors/{doctorId}` (controller line 92-98) both exist. These are the endpoints that §9 P1-3 and P1-4 say are never called from Flutter. Confirmed; the gap is Flutter-only.

### 6.2 What's in Designs but Missing/Broken in Flutter

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| 1 | **AI Chatbot screen** — Completely missing. Nav index 2 routes to Community. | High — Misleading UX, missing feature | **Out of scope** — deferred |
| 2 | **Nearby / Map screen** — Completely missing. Nav index 3 routes to Browse Doctors. | High — Misleading UX, missing feature | **Backend ready** (2026-06-01: `/api/clinic/nearby`, `/api/doctor/nearby`). Flutter work remains. |
| 3 | **Doctor Profile (rich)** — Missing: Experience/Patients stats, Professional Background cards, inline calendar, time slots grid. Only basic info + fee. | High — Reduces booking conversion | **Partial backend** (2026-06-01: `totalPatients` + clinic coords added). Flutter UI rebuild still needed. Education/Certification/calendar data likely already in backend; verify `GET /api/doctor/{id}` response covers them. |
| 4 | ~~**Appointment Confirmation (dynamic)** — Shows static mock data instead of actual booking details.~~ | — | ✅ **Fixed** 2026-06-01 |
| 5 | **Prescription standalone screen** — Figma shows full medication builder. Flutter embeds in consultation. | Medium — UX inconsistency | **Open — design decision needed.** Standalone path requires backend structured storage (#3 in §6.1). |
| 6 | **Social login buttons** — Present but all have empty `onTap: () {}`. | Low — Non-functional | **Out of scope** — deferred |
| 7 | ~~**Onboarding assets** — Need to verify `onboarding_2.png` and `onboarding_3.png` exist in assets.~~ | — | ✅ **Fixed** 2026-06-01 |
| 8 | ~~**Community post share button** — Figma shows share icon. Flutter missing.~~ | — | ✅ **Fixed** 2026-06-01 |
| 9 | **Clinic Appointments (dedicated)** — No dedicated screen with date selector and queue banner. Only Recent Appointments section on Dashboard. | Medium — Clinic staff need dedicated view | **Backend ready** (data exists at `GET /api/appointment/clinic/queue`). Flutter work remains (small scope). |
| 10 | ~~**Font 'Inter' not declared** — `app_text_styles.dart` sets font family to 'Inter' but `pubspec.yaml` has no `fonts:` section.~~ | — | ✅ **Fixed** 2026-06-01 |
| 11 | **Medical History screen is a stub** — `medical_history_screen.dart:29` has `// TODO: Replace with actual API call`. `Future.delayed(500ms)` then empty list. Hardcoded `_chronicConditions = ['Hypertension', 'Asthma']`. `GET /api/medicalrecord/patient/{id}` is never called. The status report's prior claim that "Backend: `GET /api/medicalrecord/patient/{id}`" is **wrong** — the endpoint exists but the screen doesn't use it. | High — Core clinical aftercare loop is broken. Doctor saves consultation, patient can't see it. (§9 B-3) | **Open — Flutter only** |
| 12 | **Submit Review is a stub** — `submit_review_screen.dart:44-45` says `// In a real app, this would call the reviews API`. Fake `Future.delayed(800ms)`, success snackbar, but data is discarded. `ReviewService.submitReview()` is implemented but never called. | High — User feedback is silently lost. (§9 B-1) | **Open — Flutter only** |
| 13 | **Add Family Member is a stub** — `add_family_member_screen.dart:54` says `// In a real app, this would call an API`. Same pattern: fake delay, success snackbar, data discarded. | High — User data is silently lost. (§9 B-2) | **Open — Flutter only** |
| 14 | **Voice mic icon has no handler** — `patient_home_screen.dart:238` shows `Icons.mic` in the search bar with no `onTap` and no `speech_to_text` package. Figma shows voice search; implementation never started. | Medium — User taps it expecting voice input, nothing happens. (§9 A-2) | **Out of scope** — will be removed from UI or deferred. |
| 15 | **Favorite toggle on doctor cards is a stub** — `browse_doctors_screen.dart:134` and `favorites_screen.dart:94` both pass `onFavoriteToggle: () {}` (or local-only `removeAt`). Backend has `POST /api/patient/favorite/{doctorId}` and `GET /api/patient/favorites` (2026-06-03) but neither is called from Flutter. | High — Heart icon is decoration only. (§9 A-3, A-4) | **Open — Flutter only** |
| 16 | **Community post delete UI missing** — `DELETE /api/community/posts/{id}` exists in `app_constants.dart:88` and `deleteCommunityComment` in line 89, but no service method or UI button calls them. Posts/comments are permanent. | Medium — User can create but not delete own content. (§9 C-4, C-5) | **Open — Flutter only** |
| 17 | **Manage Schedule screen is a stub** — `manage_schedule_screen.dart:33-60` initializes from hardcoded `_schedules` Map. Save sends `slotDurationMinutes: 30, maxPatients: 10` regardless of UI input. `GET /api/doctor/{id}/schedules` exists but is never called. | Critical — Schedule editing is non-functional. (§9 D-Clinic-1) | **Open — Flutter only** |
| 18 | **Clinic Doctor Detail schedule section is fabricated** — `clinic_doctor_detail_screen.dart:300` comment: `// Mock schedule data - in real app would come from API`. Displays hardcoded "09:00 AM - 05:00 PM" every weekday, "Friday Closed". | Critical — Clinic sees fake schedule. (§9 D-Clinic-3) | **Open — Flutter only** |
| 19 | **Clinic Doctor Detail uses list endpoint, not detail endpoint** — Loads from `getClinicDoctors()` (list) and manually maps 8 fields. Misses degree, university, bio, languages, board certification, years of experience, graduation year. `GET /api/clinic/doctors/{id}` exists in `app_constants.dart:53` but is not called. | High — Clinic admin can't see doctor's full profile. (§9 D-Clinic-4) | **Open — Flutter only** |
| 20 | **No per-doctor fee / status edit at clinic** — `PUT /api/clinic/doctors/{id}` exists in `app_constants.dart:54` but is never called from any screen. Clinic can register a doctor but cannot update fee or active/inactive status afterward. | High — Once registered, doctor is "frozen" at the clinic. (§9 D-Clinic-5) | **Open — Flutter only** |
| 21 | **Clinic edit has no lat/lng fields** — `edit_clinic_profile_screen.dart:67-82` save payload lacks `latitude`/`longitude`. New clinics created or updated via this screen are silently excluded from `/api/clinic/nearby`. **Coupling with §6.1 #6 resolved 2026-06-01** (backend DTO verified). | Critical — Newly-shipped nearby feature is broken for the app's primary entry path. (§9 P0-1) | **Open — Flutter only** |
| 22 | **EditClinicProfileScreen missing fields** — No operating hours, no photo gallery (only logo), no specialty tags. Operating hours backend ready (2026-06-03 — `OpeningTime`/`ClosingTime` in DTOs). | Medium — Clinic can't populate fields the design shows. (§9 D-Clinic-7) | **Open — Flutter only (operating hours backend ready)** |
| 23 | **Doctor email never captured at registration** — `register_doctor_screen.dart:60-83` doesn't ask for or send email, but `EditDoctorProfileScreen` has an email field. Profile can never have a real email. | High — Onboarding gap. (§9 D-Doctor-1) | **Open — Flutter only** |
| 24 | ~~**Doctor specializations list mismatch** — `register_doctor_screen.dart:36-45` lists 8 values including "Ophthalmologist" and "Dentist". `edit_doctor_profile_screen.dart:43-54` lists 10 values including "Ophthalmology" and "General Practice".~~ | — | ✅ **Closed 2026-06-03** — unified into `AppConstants.specializations` with 11 values. |
| 25 | **No doctor-facing "My Schedule" screen** — Only clinics can edit doctor schedules via `ManageScheduleScreen` (which is itself a stub). Doctors have no UI to set their own availability. | Medium — Doctors can't manage their own calendars. (§9 D-Doctor-3) | **Open — Flutter only** |
| 26 | **Doctor's `associatedClinics` is always empty** — `doctor_profile_screen.dart:120-128` displays the list, but there's no UI to populate it from the doctor's side. Clinic side links via QR/registration, but the doctor's profile never reflects the link. | Medium — Display-only data, never populated. (§9 D-Doctor-4) | **Open — Flutter only** |
| 27 | **Clinic registration: dummy areas + missing address/email** — `register_clinic_screen.dart:49-53` areas are `['Area 1', 'Area 2', 'Area 3']`. Form doesn't capture full street address or email. | Medium — Onboarding gap. (§9 D-Clinic-8, D-Clinic-9) | **Open — Flutter only** |
| 28 | **Patient `chronicDiseases` not captured** — `PatientProfile` model has `chronicDiseases`, backend accepts it. `edit_patient_profile_screen.dart` captures bloodType and allergies but has no controller for chronic diseases. | Medium — Health data gap. (§9 P2-10) | **Open — Flutter only** |
| 29 | **Patient `dateOfBirth` not captured** — `PatientProfile` model has `dateOfBirth` (`DateTime?`), backend accepts it. Edit screen only has an age text field, no date picker. | Medium — Age vs DOB mismatch. (§9 P2-11) | **Open — Flutter only** |
| 30 | ~~**Family member `medicalHistory`/`allergies`/`chronicDiseases` not captured** — `FamilyMember` model has all three. `add_family_member_screen.dart` only captures name, relation, age, gender, bloodType.~~ | ✅ **Closed 2026-06-03** — added 3 optional multi-line fields to form; wired to `FamilyMember` constructor which serializes them in `toJson()`. (§9 P2-12) |
| 31 | **Clinic `linkMap` never used** — `ClinicProfile` model has `linkMap` (Google Maps URL string). Never displayed in profile view, never captured in edit form. | Low — Dead field. (§9 P3-10) | **Open — Flutter only** |
| 32 | **Notification `type`/`relatedId` ignored** — `NotificationItem` model has `type` and `relatedId` for deep-linking. Never used in `notifications_screen.dart` onTap handler. | Medium — Deep-linking impossible without these. (§9 P2-13) | **Open — Flutter only** |
| 33 | **Edit patient profile mock fallback** — `edit_patient_profile_screen.dart:71-79` falls back to `_mockProfile()` on API failure. Same fake-success anti-pattern as P0 stubs, but less severe since save path calls real API. | Low — Silent mock data on load failure. (§9 P3-11) | **Open — Flutter only** |

---

## 7. Screenshots Comparison Summary

| Figma Screen | Flutter Screen | Visual Match |
|--------------|----------------|--------------|
| Home | patient_home_screen | ~75% — layout similar, nav broken |
| Doctor Profile | doctor_profile_screen | **~50% frontend / ~75% backend** — UI still simplified; `totalPatients` + clinic coords added to backend 2026-06-01, but Flutter rebuild (calendar, slots, education/certification cards) not started. Profile loads from list endpoint missing `degree`, `university`, `bio`, `languages`, `boardCertification`, `yearsOfExperience`, `graduationYear`. (§9 D-Doctor-4) |
| Confirm Appointment | appointment_confirmation_screen | ~85% — dynamic real data ✅ |
| Community | community_feed_screen | ~80% — share button added ✅, but post/comment delete not wired (§9 C-4, C-5) |
| AI Chatbot | N/A | 0% |
| Nearby | N/A | 0% — backend ready, Flutter pending; also blocked by §6.1 #6 |
| Add Walk-in | walk_in_booking_screen | ~70% — assumed from form fields |
| Clinic Appointments | clinic_dashboard (section) | ~50% — no dedicated screen |
| Doctor Dashboard | doctor_dashboard_screen | ~70% — card internals differ |
| Open Queue | consultation_screen | ~65% — assumed from SOAP structure |
| Prescription | consultation_screen (embedded) | ~40% — no standalone screen |
| History | doctor_patient_history_screen | ~80% |
| Doctor Profile (Doctor view) | doctor_profile_screen (doctor) | ~60% — simplified; `associatedClinics` is always empty list |
| Edit Clinic Profile | edit_clinic_profile_screen | ~90% — **BUT missing lat/lng fields** (breaks nearby search; §9 P0-1) |
| Onboarding | onboarding_screen | ~90% — all 3 pages verified ✅ |
| Medical History | medical_history_screen | **~0% functional** — `// TODO: Replace with actual API call`; shows hardcoded mock data (§9 B-3) |
| Manage Schedule | manage_schedule_screen | **~0% functional** — hardcoded mock schedules, save ignores UI input (§9 D-Clinic-1) |
| Clinic Doctor Detail | clinic_doctor_detail_screen | ~70% — **schedule section fabricated**; loads from list endpoint missing 7 fields (§9 D-Clinic-3, D-Clinic-4) |

> **Visual Match caveat:** scores in the right column reflect visual fidelity to the Figma design. Several screens marked visually similar (≥70%) are actually **non-functional stubs** in their data layer — see notes inline and the full audit in §9. The Medical History, Manage Schedule, and Clinic Doctor Detail rows above are the most striking examples.

---

*End of File 1 — Overall Status Report*

---

## 8. Fix Tracking — What Has Been Closed

> Updated: 2026-06-01  
> Scope: All items closed across Flutter (8.1–8.3) and Backend (8.5). The §8.4 table tracks everything still deferred, out of scope, or pending further work.

### 8.1 Closed Gaps

| # | Gap (from §6.2) | Resolution | Files Changed |
|---|-----------------|------------|---------------|
| 10 | **Font 'Inter' not declared in pubspec** | Added `google_fonts: ^6.2.1` dep; rewrote `app_text_styles.dart` to use `GoogleFonts.inter()` for all text styles rather than relying on a missing `fonts:` section. The `fontFamily = 'Inter'` const is retained for `app_theme.dart` compatibility. | `pubspec.yaml`, `lib/core/theme/app_text_styles.dart` |
| 8 | **Community post share button** | Added an `IconButton` with `share_plus.Share.share()` in the post card footer row (right of comment count). Shares: author name, post content, and `#Specialization` hashtag for iPad popover positioning. The `share_plus` package was already a dependency. | `lib/features/patient/community/community_feed_screen.dart` |
| 4 | **Appointment confirmation shows static mock data** | `book_appointment_screen` now captures the returned `Appointment` from the service call and passes it via `context.go(extra:)`. The confirmation screen is rewritten to accept a required `Appointment` and renders real data: formatted date, 12-hour time (converts backend `TimeSpan` like `"10:30:00"` → `"10:30 AM"`), doctor name + specialization, clinic name + address, queue number, and family member name if booked for a family member. The router passes the `Appointment` through `state.extra` with a fallback `_MissingAppointmentScreen` for safety. | `lib/features/patient/appointments/book_appointment_screen.dart`, `lib/features/patient/appointments/appointment_confirmation_screen.dart`, `lib/core/navigation/app_router.dart` |
| 7 | **Onboarding assets** | Verified all three `onboarding_{1,2,3}.png` exist (70 KB, 6 KB, 2 KB). Already declared in `pubspec.yaml` assets and referenced via `AssetPaths` in `onboarding_screen.dart`. No code change needed. | *(none)* |

### 8.2 Updated Visual Match Scores

| Figma Screen | Old Match | New Match | Why |
|--------------|-----------|-----------|-----|
| Confirm Appointment | ~50% — static data | ~85% — dynamic real data | Date, time, doctor, clinic, queue, and family member now rendered from the `Appointment` response |
| Community | ~70% — missing share button | ~80% — share button added | Posts now have an `IconButton` with `share_plus` sharing post content + author |
| Onboarding | ~85% — verify all 3 pages | ~90% — all PNGs confirmed | All 3 files exist and render in PageView |

### 8.3 Verification

- `flutter pub get` — `google_fonts 6.3.3` resolved successfully
- `flutter analyze` — **0 errors** across the entire project
- All remaining warnings/info in affected files are **pre-existing** (unused imports, deprecated API usages, underscore lints) — none introduced by these changes

### 8.4 Deferred / Not-Yet-Done

| Gap | Reason | Current status |
|-----|--------|----------------|
| AI Chatbot (screen + backend) | Out of scope per explicit instruction | **Out of scope** — deferred |
| Social login (working buttons) | Out of scope; backend social-login returns 501 | **Out of scope** — deferred |
| Telegram registration UI | Backend endpoint exists, only needs a Flutter screen | **Out of scope** — Flutter UI not planned |
| Doctor Profile (rich — 40% → 50% match) | Still simplified. `totalPatients` + clinic coords added to backend but Flutter UI rebuild (calendar, slots, education/certification cards) not started. | **Backend partial** — Flutter rebuild still needed (1.5-2 days) |
| Rich prescription standalone screen | Needs design decision (standalone vs modal). If standalone, also needs structured backend storage | **Open** — design decision + backend work |
| Clinic Appointments dedicated screen | New screen; not a quick win from the first pass | **Backend ready** (exists at `GET /api/appointment/clinic/queue`). Flutter pending (~0.5-1 day) |
| Several images in `assets/images/` still placeholders | Audit started but deferred to manual fix (`doctor_julian.png`, `clinic_image_1/2.png`, `patient_profile_1/2.png`, `onboarding_2/3.png` share the same 4691-byte stub or are suspiciously small). `doctor_dashboard_image.png` deleted (orphan — no Flutter reference). | **Placeholder images** — deferred |
| **29 in-scope UX/flow findings** (4 P0, 7 P1, 9 P2, 9 P3) | New audit surfaced after the §8.1-§8.3 close pass. Includes 3 silent data-loss TODO stubs, 3 critical clinic schedule stubs, broken nearby feature due to missing lat/lng, and dead favorite toggle. | **Open — see §9 for full breakdown with file:line references and fix order.** Estimated 6-10 dev days to close all in-scope. |

> **Note:** The first 7 rows of this table are the deferred work that was tracked before this audit. The 8th row is the new aggregate pointer to §9. The §9 audit supersedes earlier estimates for Medical History, Manage Schedule, Submit Review, Add Family Member, and Clinic Doctor Detail — those items are now classified as **P0/P1 functional gaps** rather than "still in progress".

---

### 8.5 Backend Changelog — 2026-06-01

Shipped as part of the `medicare-backend` repository. See `medicare-backend/CHANGELOG.md` for full details and DTO shapes.

#### New endpoints

| Endpoint | What it does | Auth |
|----------|-------------|------|
| `GET /api/clinic/nearby` | Geospatial clinic search — `lat` + `lng` (required), `radiusKm` (default 5), `specialization`, `search` | Public (no auth) |
| `GET /api/doctor/nearby` | Geospatial doctor search — same params as above. Doctor's location is the first active clinic with coordinates. | Public (no auth) |

Both return items with `distanceKm`, sorted ascending. Items without coordinates are silently excluded.

#### New fields on existing responses

| Endpoint | New fields | Purpose |
|----------|-----------|---------|
| `GET /api/doctor/{id}` | `clinicLatitude`, `clinicLongitude`, `totalPatients` | Feeds Doctor Profile map pin + stats row |
| `GET /api/doctor` (+ `/popular`) | `distanceKm` (null unless `userLat`/`userLng` provided) | Enables distance-aware doctor sorting |

#### New query parameters

| Endpoint | Params | Behaviour |
|----------|--------|-----------|
| `GET /api/doctor` | `userLat`, `userLng` (optional) | When both present: results sorted by `distanceKm` ascending |
| `GET /api/doctor/popular` | `userLat`, `userLng` (optional) | `distanceKm` populated per item; results stay sorted by rating |

#### Bug fix

- `GET /api/doctor` was returning HTTP 500 (missing AutoMapper mapping `Doctor -> DoctorListItemDto`). Now returns 200 with a `DoctorListItemDto[]`.

#### End-of-file metadata

- **No database schema changes.**
- **All existing endpoints, query parameters, and response fields are unchanged.** New fields are additive — existing JSON parsers ignore them.

---

### 8.6 Backend Changelog — 2026-06-03

Shipped as part of the `medicare-backend` repository. See `medicare-backend/CHANGELOG.md` for full details.

#### New endpoints

| Endpoint | What it does | Auth |
|----------|-------------|------|
| `GET /api/patient/favorites` | Returns the current patient's favorited doctors as `DoctorListItemDto[]` | Patient |
| `DELETE /api/notification/{id}` | Deletes a notification. Only the owner can delete it. | All authenticated roles |

#### New fields on existing DTOs

| DTO | New fields | Notes |
|-----|-----------|-------|
| `ClinicDto` | `openingTime`, `closingTime` | `TimeSpan?`, serialized as `"HH:mm:ss"` or `null` |
| `CreateClinicDto` | `openingTime`, `closingTime` | Settable at clinic creation |
| `UpdateClinicDto` | `openingTime`, `closingTime` | Settable at clinic update |

All three DTOs expose `OpeningTime`/`ClosingTime` that map directly to the `Clinic` entity columns. Wired in `ClinicService` on both create (`ClinicService.cs:145-146`) and update (`ClinicService.cs:191-192`).

#### Not changed

- No database schema changes. No migration needed — the entity already had these columns.
- All previously-existing endpoints and response fields are unchanged.

---

## 9. UX & Flow Audit (Flutter)

> Added: 2026-06-01
> Method: Direct code inspection of all 43 routes, all 4 service classes (`auth/`, `patient/`, `doctor/`, `clinic/`), the 59 screens in `lib/features/`, the `app_router.dart`, `app_constants.dart`, and `pubspec.yaml`. Cross-referenced against the Figma design (file `UZjAOECB8WGEfjzMcy7mQW`) and the backend `CHANGELOG.md`.
> Scope: In-scope only. AI Chatbot, Social login, and Telegram UI are excluded (see §0 Out of scope).
> Out of audit: A11y / i18n coverage, performance benchmarking, dark mode parity, error UX across forms, loading skeletons, and unit-test coverage of the affected flows.

This section is the single source of truth for "is the Flutter app actually using the data and endpoints we have". Several screens in §7 report visual match ≥70% but are functionally broken (Medical History, Manage Schedule, Clinic Doctor Detail schedule section). Some screens show static UI shells for features that have working backend endpoints. The findings below are sorted into five categories and prioritized P0 → P3.

#### 9.0 ID system note

§9 uses **P-IDs** (P0-1, P1-5, etc.) for primary references. §0 and §6.2 use **category IDs** (A, B, C, D-Doctor, D-Clinic, E) for quick thematic grouping. The two systems map as follows:

| Category ID (in §0/§6.2) | P-ID (in §9) | Finding |
|---------------------------|--------------|---------|
| B-1 (Submit Review stub) | P0-3 | `submit_review_screen.dart:44-51` |
| B-2 (Add Family Member stub) | P0-4 | `add_family_member_screen.dart:54` |
| B-3 (Medical History stub) | P0-2 | `medical_history_screen.dart:29, 48-50` |
| A-2 (Mic icon) | P2-7 | `patient_home_screen.dart:238` |
| A-3, A-4 (Favorite toggle dead) | P1-5 | `browse_doctors_screen.dart:134`; `favorites_screen.dart:94` |
| C-4 (Community post delete) | P1-6 | `app_constants.dart:88` |
| C-5 (Community comment delete) | P1-7 | `app_constants.dart:89` |
| C-6 (Notification) | P2-8 / P2-9 | `notifications_screen.dart` |
| D-Doctor-1 (Email) | P2-1 | `register_doctor_screen.dart:60-83` |
| D-Doctor-2 (Specializations list) | P2-2 | `register_doctor_screen.dart:36-45` vs `edit_doctor_profile_screen.dart:43-54` |
| D-Doctor-3 (No doctor My Schedule) | P2-3 | no screen exists |
| D-Doctor-4 (associatedClinics empty) | P2-4 | `doctor_profile_screen.dart:120-128` |
| D-Clinic-1 (Manage Schedule stub) | P1-1 | `manage_schedule_screen.dart:33-60` |
| D-Clinic-2 (Figma FAB mismatch) | *(closed during audit — Figma only had 4 doctor schedule rows; not a real gap)* | — |
| D-Clinic-3 (Hardcoded schedule) | P1-2 | `clinic_doctor_detail_screen.dart:299-309` |
| D-Clinic-4 (List vs detail endpoint) | P1-3 | `clinic_doctor_detail_screen.dart` |
| D-Clinic-5 (No per-doctor edit) | P1-4 | `app_constants.dart:54` (PUT defined, unused) |
| D-Clinic-6 (Clinic lat/lng missing) | P0-1 | `edit_clinic_profile_screen.dart:67-82` |
| D-Clinic-7 (EditClinicProfileScreen missing fields) | P2-5 | `edit_clinic_profile_screen.dart:24-65` |
| D-Clinic-8, D-Clinic-9 (Dummy areas + missing address/email) | P2-6 | `register_clinic_screen.dart:49-88` |
| E-1 through E-9 (Polish items) | P3-1 through P3-9 | See §9.5 |

> When §0/§6.2 say "see §9 D-Clinic-3", search §9.5 for P1-2 (or use this table).

### 9.1 Priority summary

| Priority | Count | Meaning |
|----------|-------|---------|
| **P0** | 4 | Silently breaks a core clinical or booking flow. Must fix before any release to real users. |
| **P1** | 7 | A primary screen or feature is non-functional even though the backend is ready. |
| **P2** | 13 | Onboarding gap, data inconsistency, or a screen users will hit in normal use but which doesn't block the booking loop. |
| **P3** | 11 | Polish: search/filter UX, deep-linking, edit flows, export, visual gaps. |
| **Total** | **35** | |

### 9.2 P0 — Silently breaks core flow

| ID | Finding | File / Line | Why it's P0 |
|----|---------|-------------|-------------|
| **P0-1** | `EditClinicProfileScreen` save payload has no `latitude` / `longitude` fields. The 2026-06-01 `/api/clinic/nearby` endpoint **silently excludes** clinics without coordinates. Every clinic created or edited through the app is invisible to the new nearby feature. **Backend verified 2026-06-01** — `UpdateClinicDto:98-99`, `CreateClinicDto:58-59`, `Clinic` entity:46-48, `ClinicService.UpdateClinicProfileAsync:183-184` all support lat/lng. Flutter side is the only remaining gap. | `lib/features/clinic/screens/edit_clinic_profile_screen.dart:67-82`; `register_clinic_screen.dart:49-88` (also no lat/lng); previously coupled with §6.1 #6 (now closed) | Newly-shipped backend feature is broken on the app's primary entry path. Users will see "no clinics nearby" for their own freshly-registered clinic. |
| **P0-2** | `MedicalHistoryScreen` is a stub. Line 29 has `// TODO: Replace with actual API call`. The `Future.delayed(500ms)` returns an empty list and the screen hardcodes `_chronicConditions = ['Hypertension', 'Asthma']`. The consultation screen correctly POSTs prescriptions to the backend, but the patient can never see them. | `lib/features/patient/profile/medical_history_screen.dart:29, 48-50` | The doctor's aftercare record is invisible to the patient. This is the inverse half of the consultation loop. |
| **P0-3** | `SubmitReviewScreen` is a stub. Line 45 says `// In a real app, this would call the reviews API`. `Future.delayed(800ms)`, success snackbar, data discarded. `ReviewService.submitReview()` is implemented but the screen never calls it. | `lib/features/patient/profile/submit_review_screen.dart:44-51`; `lib/core/services/review_service.dart` (defined, unused) | User feedback is silently lost. Worse: the UI claims success, so the user thinks their review was submitted. |
| **P0-4** | `AddFamilyMemberScreen` is a stub. Line 54: `// In a real app, this would call an API`. Same pattern: fake delay, success snackbar, data discarded. | `lib/features/patient/profile/add_family_member_screen.dart:54` | Family member data entered in good faith is silently lost. |

### 9.3 P1 — Primary screen or feature is non-functional (backend ready)

| ID | Finding | File / Line | Notes |
|----|---------|-------------|-------|
| **P1-1** | `ManageScheduleScreen` (clinic-side) loads from hardcoded `_schedules` map, save sends `slotDurationMinutes: 30, maxPatients: 10` regardless of UI input. `GET /api/doctor/{id}/schedules` exists but is never called. | `lib/features/clinic/screens/manage_schedule_screen.dart:33-60` (mock data); no GET/POST call site | The whole screen is a UI mockup. |
| **P1-2** | `ClinicDoctorDetailScreen` schedule section is **fabricated**. Line 300 comment: `// Mock schedule data - in real app would come from API`. Displays hardcoded "09:00 AM - 05:00 PM Mon-Thu, Friday Closed". | `lib/features/clinic/screens/clinic_doctor_detail_screen.dart:299-309` | Clinic admin sees fake schedule — they will route patients to a doctor who isn't actually available. |
| **P1-3** | `ClinicDoctorDetailScreen` loads from the list endpoint, not the detail endpoint. Manually maps 8 fields. Misses: `degree`, `university`, `bio`, `languages`, `boardCertification`, `yearsOfExperience`, `graduationYear`. | `lib/features/clinic/screens/clinic_doctor_detail_screen.dart` (calls `getClinicDoctors()` not `getClinicDoctor(id)`); `app_constants.dart:53` defines `GET /api/clinic/doctors/{id}` but no method calls it | Clinic admin can't see the doctor's full profile. |
| **P1-4** | `PUT /api/clinic/doctors/{id}` exists in `app_constants.dart:54` but is never called from any screen. Clinic can register a doctor but cannot update their fee or active/inactive status afterward. | `lib/features/clinic/clinic_service.dart` (method defined, no call site); no edit screen | Once registered, a doctor is "frozen" at the clinic. |
| **P1-5** | Favorite toggle is non-functional. `browse_doctors_screen.dart:134` passes `onFavoriteToggle: () {}`. `favorites_screen.dart:94` does local `removeAt(i)` only. Backend has `POST /api/patient/favorite/{doctorId}` (toggle) **and** `GET /api/patient/favorites` (added 2026-06-03), but neither is wired in Flutter. `PatientService.getFavorites()` still throws `UnsupportedError`. | `lib/features/patient/browse_doctors/browse_doctors_screen.dart:134`; `lib/features/patient/profile/favorites_screen.dart:94`; `app_constants.dart:25` | Heart icon is decoration only. Backend is fully ready — Flutter wiring is the only gap. |
| **P1-6** | Community post delete UI missing. `DELETE /api/community/posts/{id}` defined in `app_constants.dart:88` but no service method or UI button calls it. Posts are permanent. | `lib/core/services/community_service.dart` (no `deletePost` method); `app_constants.dart:88` | Users can create but not delete own posts. |
| **P1-7** | Community comment delete UI missing. Same as P1-6 but for comments. `DELETE /api/community/comments/{id}` defined in `app_constants.dart:89` but unused. | `lib/core/services/community_service.dart`; `app_constants.dart:89` | Same impact as P1-6. |

### 9.4 P2 — Onboarding gap or data inconsistency

| ID | Finding | File / Line | Notes |
|----|---------|-------------|-------|
| **P2-1** | Doctor email is never captured at registration. `RegisterDoctorScreen` doesn't ask for it. `EditDoctorProfileScreen` has an email field. The doctor's profile can never have a real email unless filled in later. | `lib/features/doctor/screens/register_doctor_screen.dart:60-83`; `lib/features/doctor/screens/edit_doctor_profile_screen.dart:43-54` | Onboarding gap. |
| **P2-2** | ~~Doctor specializations list mismatch between registration and profile edit.~~ | `register_doctor_screen.dart:36-45` vs `edit_doctor_profile_screen.dart:43-54` | ✅ **Closed 2026-06-03** — unified into `AppConstants.specializations` with 11 values. |
| **P2-3** | No doctor-facing "My Schedule" screen. Only clinics can edit doctor schedules via `ManageScheduleScreen` (itself a stub — P1-1). Doctors have no UI to set their own availability. | No screen exists in `lib/features/doctor/screens/` | Doctors cannot manage their own calendar. |
| **P2-4** | Doctor's `associatedClinics` is always an empty list in the UI. `doctor_profile_screen.dart:120-128` displays the list, but there's no UI to populate it from the doctor's side. Clinic side links via QR/registration, but the doctor's profile never reflects the link. | `lib/features/doctor/screens/doctor_profile_screen.dart:120-128` | Display-only data, never populated. |
| **P2-5** | `EditClinicProfileScreen` missing fields. No operating hours, no photo gallery (only logo), no specialty tags. **Split scope:** (a) ✅ **Backend closed 2026-06-03** — `CreateClinicDto`, `UpdateClinicDto`, and `ClinicDto` now have `OpeningTime` / `ClosingTime` (`TimeSpan?`); `ClinicService` persists them on create and update. (b) Photo gallery and specialty tags — `Clinic` entity has neither; UI work needed. | `lib/features/clinic/screens/edit_clinic_profile_screen.dart:24-65` (Flutter form) | Clinic can't populate fields the design shows. Operating hours backend done — Flutter form fields needed. |
| **P2-6** | Clinic registration has dummy data: areas list is `['Area 1', 'Area 2', 'Area 3']`. Form doesn't capture full street address or email. | `register_clinic_screen.dart:49-53` (areas), 55-88 (form fields) | Onboarding gap. |
| **P2-7** | Voice mic icon on Patient Home has no handler. `patient_home_screen.dart:238` shows `Icons.mic` with no `onTap`. Figma shows voice search; `speech_to_text` is not in `pubspec.yaml`. | `lib/features/patient/home/patient_home_screen.dart:238`; `pubspec.yaml` (no `speech_to_text`) | User taps it expecting voice input, nothing happens. **Out of scope** per F2 design — see §0. |
| **P2-8** | Notification delete — no UI button. Backend endpoint shipped 2026-06-03 (`DELETE /api/notification/{id}` — owner-only delete). | `notifications_screen.dart` (no delete button) | Backend done. Add delete UI in Flutter. |
| **P2-9** | Notification tap marks as read but does not deep-link to the related entity (appointment, post, etc.). | `lib/features/patient/notifications/notifications_screen.dart` (onTap handler) | Notifications are read-only markers. |
| **P2-10** | Patient `chronicDiseases` not captured in edit form. `PatientProfile` model has it (line 43), backend accepts it. `edit_patient_profile_screen.dart` has controllers for bloodType and allergies but no chronic diseases field. | `lib/features/patient/profile/edit_patient_profile_screen.dart` | Health data gap — patient can't record chronic conditions. |
| **P2-11** | Patient `dateOfBirth` not captured. Model has `dateOfBirth` (`DateTime?`), backend accepts it. Edit screen only has an age text field (line 273) — no date picker for actual DOB. | `lib/features/patient/profile/edit_patient_profile_screen.dart:273` | Age text field is a proxy; DOB is the canonical field. |
| **P2-12** | Family member `medicalHistory`/`allergies`/`chronicDiseases` not captured. `FamilyMember` model has all three (lines 41-43). `add_family_member_screen.dart` only captures name, relation, age, gender, bloodType. | `lib/features/patient/profile/add_family_member_screen.dart` | Health data gap for family members. |
| **P2-13** | Notification `type`/`relatedId` ignored for deep-linking. Model has both fields (lines 7-8, 17). `notifications_screen.dart` onTap handler never reads them — can't route to related entity. | `lib/core/models/shared_models.dart:7-8`; `lib/features/patient/notifications/notifications_screen.dart` | Deep-linking data exists but is discarded. |

### 9.5 P3 — Polish

| ID | Finding | File / Line | Notes |
|----|---------|-------------|-------|
| **P3-1** | Community search only filters on Enter, no live search, no clear button. | `community_feed_screen.dart` (search field) | UX polish. |
| **P3-2** | Community specializations list is hardcoded: 7 items, doesn't match the backend's `getSpecializations()` output. | `community_feed_screen.dart:27-35` | Should fetch dynamically. |
| **P3-3** | Doctor-side Community "Add post" routes to `AppRoutes.patientCreatePost` (wrong role context). | `community_feed_screen.dart` for doctor role | Wrong nav target. |
| **P3-4** | Silent mock-fallback pattern. `useMockDataFallback = false` is the default in `app_constants.dart`, but 19+ service code paths still silently fall back to mock data on API failure. Makes debugging API failures hard. | `app_constants.dart` (default); 19+ service methods across `auth/`, `patient/`, `doctor/`, `clinic/` | Add a `print` / `Logger` / snackbar at minimum. |
| **P3-5** | Family members: no edit screen. Workaround is delete + re-add. | No `edit_family_member_screen.dart` exists | UX gap. |
| **P3-6** | Reviews: no edit or delete after submission. | No edit/delete UI in `submit_review_screen.dart` or post-consultation flow | UX gap. |
| **P3-7** | Patient profile: blood type, allergies, chronic diseases are stored but not surfaced in a dedicated view — only in the edit form. | `lib/features/patient/profile/patient_profile_screen.dart` (no display fields); `edit_patient_profile_screen.dart` (form fields) | Display gap. |
| **P3-8** | Clinic payments: timeframe filter works (week / month / year) but no custom date range, no CSV/PDF export. | `lib/features/clinic/screens/payments_screen.dart` | Reporting gap. |
| **P3-9** | Booking flow doesn't show "you booked for a family member" preview at the doctor-detail step — only on the confirmation. Causes "wrong patient" mistakes. | `lib/features/patient/appointments/book_appointment_screen.dart` | Minor UX. |
| **P3-10** | Clinic `linkMap` is a dead field. `ClinicProfile` model has it (Google Maps URL string, line 9). Never displayed in profile view, never captured in edit form. | `lib/core/models/clinic_models.dart:9` | Dead field — either wire it or remove it. |
| **P3-11** | Edit patient profile silent mock fallback. `edit_patient_profile_screen.dart:71-79` falls back to `_mockProfile()` on API failure. Same fake-success anti-pattern as P0 stubs (though save path is real). | `lib/features/patient/profile/edit_patient_profile_screen.dart:71-79` | Silent mock data on load failure. |

### 9.6 Coupled cross-team items

These touch both Flutter and backend; assign to backend first, then Flutter:

1. **Clinic lat/lng capture (P0-1)** — Backend **closed 2026-06-01** (`UpdateClinicDto:98-99`, `ClinicService.UpdateClinicProfileAsync:183-184` both accept and persist). Flutter: add lat/lng fields to `EditClinicProfileScreen` and `RegisterClinicScreen`, use a "Use my location" button (`geolocator` package — not yet in `pubspec.yaml`).
2. **Favorite list endpoint (P1-5)** — Backend **closed 2026-06-03** (`GET /api/patient/favorites` returns `DoctorListItemDto[]`). Flutter: implement `getFavorites()` in `PatientService` (replaces the `throw UnsupportedError`), wire toggle from both screens.
3. **Notification delete (P2-8)** — Backend **closed 2026-06-03** (`DELETE /api/notification/{id}` — owner-only delete). Flutter: add delete UI.

### 9.7 Recommended fix order

1. **P0 batch (1-2 days):** Wire the three TODO stubs to their existing service methods (P0-2 Medical History, P0-3 Submit Review, P0-4 Add Family Member). Add lat/lng fields to clinic edit/register screens (P0-1) — backend already supports this.
2. **P1 batch (2-3 days):** Replace the three clinic schedule stubs (P1-1 Manage Schedule, P1-2 hardcoded detail schedule, P1-3 list-vs-detail endpoint) with real GET/POST calls. Add per-doctor edit (P1-4). Wire the two `onFavoriteToggle: () {}` handlers (P1-5). Add community post/comment delete UI (P1-6, P1-7).
3. **P2 batch (2-3 days):** Add doctor email to registration (P2-1). Reconcile specialization lists (P2-2). Add `My Schedule` for doctors (P2-3). Populate `associatedClinics` (P2-4). Add operating hours, photo gallery + specialty tags to clinic edit (P2-5 Flutter part — backend ready). Fix clinic registration dummy areas + missing address/email (P2-6). Add notification deep-link (P2-9) and delete UI (P2-8 — backend ready). Add `chronicDiseases` field to patient edit (P2-10). Add `dateOfBirth` date picker replacing age text (P2-11). Add `medicalHistory`/`allergies`/`chronicDiseases` to family member add (P2-12). Wire notification `type`/`relatedId` for deep-linking (P2-13).
4. **P3 batch (1-2 days, opportunistic):** Polish items — community search/live filter, mock fallback logging, family member edit, review edit/delete, health data display, payment export, booking family member preview. Clean up or wire `linkMap` (P3-10). Fix edit patient profile mock fallback (P3-11).

**Estimated total: 8-12 dev days** to close all in-scope findings (was 6-10 before the code scan surfaced 11 additional forgotten fields in §9.9).

### 9.8 Out of audit (deferred)

- Accessibility (screen reader, contrast, font scaling)
- Internationalization beyond Arabic + English
- Dark mode parity
- Performance benchmarking (large lists, image caching)
- Error UX across forms (snackbar vs dialog vs inline)
- Loading skeletons vs spinners
- Unit / widget / integration test coverage
- A11y for the medical history table (column widths, row tap targets)

These are out of scope for this audit; flag separately if they become priorities.

---

## 9.9 New Findings — Code Scan 2026-06-03

> Method: Direct code inspection of form screens (`edit_*_profile_screen.dart`, `register_*_screen.dart`, `add_family_member_screen.dart`), view screens (`*_profile_screen.dart`), models (`clinic_models.dart`, `user_models.dart`, `shared_models.dart`), and service layer (`patient_service.dart`, `core/services/*.dart`). Cross-referenced against backend DTOs and `app_constants.dart`.
> Scope: In-scope only. Focus on "forgotten fields" — model/backend support exists but UI completely ignores them.

This scan surfaced **11 additional items** beyond the original 29 in §9.1. All are Flutter-only; the backend already supports every field listed below.

### Forgotten Fields Summary

| # | Entity | Field | In Model? | In Backend? | In UI? | Severity |
|---|--------|-------|-----------|-------------|--------|----------|
| 1 | Clinic | `latitude` / `longitude` | ✅ | ✅ | ❌ | **P0** (already tracked as P0-1) |
| 2 | Clinic | `openingTime` / `closingTime` | ❌ (model not updated) | ✅ (2026-06-03) | ❌ | P2 (already tracked as P2-5) |
| 3 | Clinic | `address` (registration) | ✅ | ✅ | ❌ (only govt + area) | P2 (already tracked as P2-6) |
| 4 | Clinic | `email` (registration) | ✅ | ✅ | ❌ | P2 (already tracked as P2-6) |
| 5 | Clinic | `linkMap` | ✅ | ✅ | ❌ (never used) | P3 (**new** — P3-10) |
| 6 | Patient | `chronicDiseases` | ✅ | ✅ | ❌ | P2 (**new** — P2-10) |
| 7 | Patient | `dateOfBirth` | ✅ | ✅ | ❌ (only age text) | P2 (**new** — P2-11) |
| 8 | Family | `medicalHistory` | ✅ | ✅ | ❌ | P2 (**new** — P2-12) |
| 9 | Family | `allergies` | ✅ | ✅ | ❌ | P2 (**new** — P2-12) |
| 10 | Family | `chronicDiseases` | ✅ | ✅ | ❌ | P2 (**new** — P2-12) |
| 11 | Notification | `type` / `relatedId` | ✅ | ✅ | ❌ (not used) | P2 (**new** — P2-13) |
| 12 | Patient (edit) | mock fallback on load | N/A | N/A | ❌ | P3 (**new** — P3-11) |

### Key Patterns Identified

1. **Model bloat with no UI** — Several models have fields that are never rendered or captured. The backend supports them, but the Flutter screens were built without awareness of the full model.
2. **Registration screens are thinner than edit screens** — All three registration screens (patient, doctor, clinic) capture fewer fields than their corresponding edit screens. This creates onboarding gaps where users can't set data at signup that they can edit later.
3. **Mock fallback anti-pattern** — `edit_patient_profile_screen.dart` uses the same silent-mock-data pattern as the P0 stubs (falling back to `_mockProfile()` on API failure). Less severe since the save path is real, but same UX risk: user shows fake data without knowing it.
4. **Dual service architecture** — `core/services/` has mock-heavy services with `useMockDataFallback`, while `features/*/services/` has clean real-API services. Inconsistent usage means some screens silently degrade to mock data while others properly show errors.
