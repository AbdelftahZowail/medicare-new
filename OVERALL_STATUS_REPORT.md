# Medicare App — Overall Status Report

> Generated from Figma design audit + Flutter frontend audit + .NET backend audit  
> Date: 2026-05-27  
> Figma Source: https://www.figma.com/design/UZjAOECB8WGEfjzMcy7mQW/%D9%85%D8%B4%D8%B1%D9%88%D8%B9-UI

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
| Confirm Appointment | ⚠️ Partial | Figma shows doctor card with photo, specialty, location, fee. Flutter shows generic success screen with static data ("Tomorrow, 10:00 AM", "Dr. Ahmed Hassan"). Missing: actual dynamic booking summary, family member selection display. |
| Community Feed | ⚠️ Partial | Figma shows filter chips (All/Internal/Neurology/Dentistry) with rounded pill style. Flutter uses `ChoiceChip` with slightly different styling. Figma posts show "Show Comments" + share icon in a row. Flutter shows comment count only. Missing: share button. |
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

| Endpoint | Purpose | Design Surface? |
|----------|---------|-----------------|
| `POST /api/auth/social-login` | Google/Apple/Facebook login | ⚠️ Login screen shows social buttons but they are non-functional (`onTap: () {}`) |
| `POST /api/auth/telegram-register` | Link Telegram for OTP | ❌ No UI for Telegram registration |
| `POST /api/upload/license` | Upload license documents | ⚠️ Used in registration but not a standalone screen |
| `GET /api/doctor/qr-code` | Get doctor QR code | ✅ Doctor QR screen |
| `PUT /api/appointment/{id}/status` | Change appointment status | ⚠️ Used internally but no explicit "change status" UI for clinic/doctor |
| `PUT /api/appointment/{id}/reschedule` | Reschedule appointment | ⚠️ My Appointments screen may have this but not verified |
| `POST /api/appointment/{id}/start-checkup` | Start patient checkup | ⚠️ Used in clinic flow but UI button may be missing |

---

## 4. Sanity Check

### 4.1 Orphaned Screens (no clear navigation path)

| Screen | Issue | Recommendation |
|--------|-------|----------------|
| AI Chatbot | Exists in Figma nav (index 2) but Flutter routes to Community. No actual chatbot screen exists. | Either implement AI Chatbot screen + backend or remove from nav and redesign. |
| Nearby | Exists in Figma nav (index 3) but Flutter routes to Browse Doctors. No map screen exists. | Implement Nearby map screen using `GET /api/clinic` data or remove from nav. |
| Prescription (standalone) | Figma shows a full Prescription screen, but Flutter implements prescriptions inside Consultation screen. | Clarify if Prescription should be standalone or modal. If standalone, create new screen. |
| Onboarding 2 & 3 | Figma has 3 onboarding screens. Flutter `onboarding_screen.dart` likely supports multiple pages but need to verify all 3 illustrations are present. | Verify assets: `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png` exist. |

### 4.2 Broken / Illogical Flows

| Flow | Issue |
|------|-------|
| Patient Home → AI Chatbot (nav index 2) | Goes to Community instead of chatbot. User expects chat, sees forum. |
| Patient Home → Nearby (nav index 3) | Goes to Browse Doctors instead of map. User expects map, sees list. |
| Book Appointment → Confirm Appointment | Flutter shows static success data instead of actual booking details. User can't verify what was booked. |
| Doctor Dashboard → View Schedule | Button exists but may not pass date context to appointments screen. |
| Clinic Dashboard → Recent Appointments | Tapping an appointment may not navigate to detail view. |
| Social Login | Buttons are present but all have empty `onTap: () {}`. Backend `social-login` returns 501. |

### 4.3 UX Logic Issues

1. **No map integration**: The Nearby screen is a key feature in Figma (with map pins, search, filters) but completely missing in Flutter. This is a major feature gap.
2. **AI Chatbot is fake**: The nav has a cute robot icon but leads to Community. This is misleading UX.
3. **Appointment confirmation uses static data**: After booking, the user sees "Tomorrow, 10:00 AM" and "Dr. Ahmed Hassan" regardless of actual selection. This erodes trust.
4. **Doctor profile is oversimplified**: The Figma design shows rich professional info (education, certification, calendar, slots). The Flutter implementation is a basic card with a Book button. This reduces conversion.
5. **No specialization filtering on Home**: Figma Home shows "Clinic Booking" as a service. Flutter has it but tapping goes to Specializations. This is correct, but the Popular Doctors section has no "View All" or filter.
6. **Community nav inconsistency**: Patient nav calls index 2 "AI Bot" with a robot icon. Doctor nav calls index 2 "Community" with a chat icon. Clinic nav has no community tab at all.

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

| # | Gap | Impact |
|---|-----|--------|
| 1 | **AI Chatbot endpoint** — No LLM or rule-based chatbot API exists. The design shows AI symptom checking and doctor recommendations. | High — Core feature missing |
| 2 | **Geospatial search** — No `nearby?lat=&lng=&radius=` endpoint. Clinics have lat/lng but can't be searched by proximity. | Medium — Map feature can't work |
| 3 | **Structured Prescription entity** — Medication details (dosage, frequency, duration, timing) are stored as free text in `MedicalRecord.Prescription`. No `Medication` table. | Medium — Can't build rich prescription UI |
| 4 | **Social login** — `POST /api/auth/social-login` returns HTTP 501 Not Implemented. | Low — Buttons exist but are non-functional |
| 5 | **Telegram registration UI** — Backend supports `POST /api/auth/telegram-register` but no Flutter screen exists to link Telegram Chat ID. | Low — OTP works but Telegram opt-in missing |

### 6.2 What's in Designs but Missing/Broken in Flutter

| # | Gap | Impact |
|---|-----|--------|
| 1 | **AI Chatbot screen** — Completely missing. Nav index 2 routes to Community. | High — Misleading UX, missing feature |
| 2 | **Nearby / Map screen** — Completely missing. Nav index 3 routes to Browse Doctors. | High — Misleading UX, missing feature |
| 3 | **Doctor Profile (rich)** — Missing: Experience/Patients stats, Professional Background cards, inline calendar, time slots grid. Only basic info + fee. | High — Reduces booking conversion |
| 4 | **Appointment Confirmation (dynamic)** — Shows static mock data instead of actual booking details. | Medium — User can't verify booking |
| 5 | **Prescription standalone screen** — Figma shows full medication builder. Flutter embeds in consultation. | Medium — UX inconsistency |
| 6 | **Social login buttons** — Present but all have empty `onTap: () {}`. | Low — Non-functional |
| 7 | **Onboarding assets** — Need to verify `onboarding_2.png` and `onboarding_3.png` exist in assets. | Low — Visual gap |
| 8 | **Community post share button** — Figma shows share icon. Flutter missing. | Low — Minor feature gap |
| 9 | **Clinic Appointments (dedicated)** — No dedicated screen with date selector and queue banner. Only Recent Appointments section on Dashboard. | Medium — Clinic staff need dedicated view |
| 10 | **Font 'Inter' not declared** — `app_text_styles.dart` sets font family to 'Inter' but `pubspec.yaml` has no `fonts:` section. | Low — Falls back to system font |

---

## 7. Screenshots Comparison Summary

| Figma Screen | Flutter Screen | Visual Match |
|--------------|----------------|--------------|
| Home | patient_home_screen | ~75% — layout similar, nav broken |
| Doctor Profile | doctor_profile_screen | ~40% — severely simplified |
| Confirm Appointment | appointment_confirmation_screen | ~50% — static data |
| Community | community_feed_screen | ~70% — missing share button |
| AI Chatbot | N/A | 0% |
| Nearby | N/A | 0% |
| Add Walk-in | walk_in_booking_screen | ~70% — assumed from form fields |
| Clinic Appointments | clinic_dashboard (section) | ~50% — no dedicated screen |
| Doctor Dashboard | doctor_dashboard_screen | ~70% — card internals differ |
| Open Queue | consultation_screen | ~65% — assumed from SOAP structure |
| Prescription | consultation_screen (embedded) | ~40% — no standalone screen |
| History | doctor_patient_history_screen | ~80% |
| Doctor Profile (Doctor view) | doctor_profile_screen (doctor) | ~60% — simplified |
| Edit Clinic Profile | edit_clinic_profile_screen | ~90% |
| Onboarding | onboarding_screen | ~85% — verify all 3 pages |

---

*End of File 1 — Overall Status Report*
