# Medicare App — Manual QA Checklist

> Step-by-step testing guide for the installed app  
> Organized by user type and natural flow order  
> Date: 2026-05-27

---

## How to Use This Checklist

1. Install the app on a test device (Android or iOS)
2. For each user type, follow the flow in order
3. For each step, perform the action and observe the result
4. Mark ✅ if it works as expected, ❌ if broken, ⚠️ if partially working
5. Note any visual discrepancies, crashes, or confusing UX

---

## Section 1: Universal / Auth Flow (All User Types)

### 1.1 Launch & Onboarding

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.1.1 | Open the app | Splash screen appears with Medicare logo | Animated splash with logo | |
| 1.1.2 | Wait on splash | App checks auth state automatically | After ~2s, redirects to Onboarding (first install) or Home (returning user) | |
| 1.1.3 | Onboarding page 1 | Swipe or tap "Continue" | Shows illustration: doctor with patient in wheelchair. Text: "Easy Doctor Booking". 3 dot indicators (first active). | |
| 1.1.4 | Onboarding page 2 | Swipe or tap "Continue" | Shows illustration: doctors team. Text: "Smart Clinic App". Second dot active. | |
| 1.1.5 | Onboarding page 3 | Swipe or tap "Continue" | Shows illustration: medicine/health. Text: "Your Health Helper". Third dot active. | |
| 1.1.6 | Tap "Continue" on last page | App navigates to Login | Login screen appears | |
| 1.1.7 | Tap "Skip" on any onboarding page | Should also navigate to Login | Login screen appears | |

**Critical Checks:**
- [ ] All 3 onboarding illustrations load (not blank/gray)
- [ ] Page indicators update correctly
- [ ] "Skip" button is visible and tappable on all pages
- [ ] App doesn't crash during onboarding swipe

---

### 1.2 Login

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.2.1 | View Login screen | Layout, fields, buttons | "Welcome Back" heading, Phone field, Password field, "Forgot Password?" link, "login" button, "Sign Up" link, social login row (Google, Apple, Facebook) | |
| 1.2.2 | Leave fields empty, tap "login" | Validation message | "Phone is required" error under phone field | |
| 1.2.3 | Enter short phone ("123"), tap "login" | Validation message | "Enter a valid phone number" error | |
| 1.2.4 | Enter valid phone, leave password empty | Validation message | "Password is required" error | |
| 1.2.5 | Enter valid phone, short password ("123") | Validation message | "Password must be at least 6 characters" error | |
| 1.2.6 | Tap password visibility icon | Password text toggles | Tapping eye icon reveals/hides password text | |
| 1.2.7 | Enter valid credentials (seeded patient: `01000000000` / `Password@123`) | Loading state | "login" button shows loading spinner, then navigates to Patient Home | |
| 1.2.8 | Enter invalid credentials | Error message | Snackbar appears: "Invalid phone or password" (or similar) | |
| 1.2.9 | Tap "Forgot Password?" | Navigation | Goes to Forgot Password screen | |
| 1.2.10 | Tap "Sign Up" | Navigation | Goes to Role Selection screen | |
| 1.2.11 | Tap Google social login button | Response | ⚠️ **Known Issue**: Button is non-functional (empty onTap). Nothing should happen. |
| 1.2.12 | Tap Apple social login button | Response | ⚠️ **Known Issue**: Button is non-functional. Nothing should happen. |
| 1.2.13 | Tap Facebook social login button | Response | ⚠️ **Known Issue**: Button is non-functional. Nothing should happen. |

**Critical Checks:**
- [ ] Form validation works for all fields
- [ ] Login with valid credentials succeeds and redirects correctly
- [ ] Login with invalid credentials shows clear error
- [ ] Password visibility toggle works
- [ ] Social login buttons are present but non-functional (document as known issue)

---

### 1.3 Role Selection & Registration

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.3.1 | View Role Selection screen | Layout, options | 3 cards: Patient, Doctor, Clinic. Each with icon and description. | |
| 1.3.2 | Tap "Patient" card | Navigation | Goes to Patient Registration form | |
| 1.3.3 | Tap "Doctor" card | Navigation | Goes to Doctor Registration form | |
| 1.3.4 | Tap "Clinic" card | Navigation | Goes to Clinic Registration form | |

**Patient Registration:**
| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.3.5 | View Patient Registration | Form fields | Full Name, Phone, Password, Confirm Password, Gender (Male/Female), Age | |
| 1.3.6 | Fill all fields, tap Register | API call | POST `/api/auth/register/patient` — should return success and auto-login | |
| 1.3.7 | Enter mismatched passwords | Validation | Error: passwords don't match | |
| 1.3.8 | Enter existing phone | Error | API returns error: phone already registered | |

**Doctor Registration:**
| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.3.9 | View Doctor Registration | Form fields | Full Name, Phone, Password, Specialization, License Number, License Upload | |
| 1.3.10 | Fill all fields, upload license image | File picker | License image uploads to `/api/upload/license` | |
| 1.3.11 | Tap Register | API call | POST `/api/auth/register/doctor` — success and auto-login | |

**Clinic Registration:**
| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.3.12 | View Clinic Registration | Form fields | Facility Name, Phone, Password, Address, License Upload | |
| 1.3.13 | Fill all fields, upload license | File picker | License image uploads | |
| 1.3.14 | Tap Register | API call | POST `/api/auth/register/clinic` — success and auto-login | |

---

### 1.4 Forgot Password Flow

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 1.4.1 | Tap "Forgot Password?" from Login | Screen appears | Phone input field, "Send OTP" button | |
| 1.4.2 | Enter valid phone, tap "Send OTP" | API call | POST `/api/auth/forgot-password` — OTP sent via Telegram | |
| 1.4.3 | Enter invalid phone | Error | Error message: phone not found | |
| 1.4.4 | After OTP sent | Navigation | Goes to Verify OTP screen with phone number displayed | |
| 1.4.5 | Enter correct OTP | Validation | POST `/api/auth/verify-otp` — success | |
| 1.4.6 | Enter incorrect OTP | Error | Error message: invalid OTP | |
| 1.4.7 | After OTP verified | Navigation | Goes to Reset Password screen | |
| 1.4.8 | Enter new password & confirm | API call | POST `/api/auth/reset-password` — success | |
| 1.4.9 | After reset | Navigation | Redirects to Login screen | |

---

## Section 2: Patient QA Flow

> **Pre-requisite**: Log in as a Patient user  
> **Test Account**: `01000000000` / `Password@123` (seeded patient)

---

### 2.1 Home Screen

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.1.1 | View Home screen | Layout, components | Medicare logo + app name top-left, notification bell top-right, search bar with mic icon, "Services" heading, "Clinic Booking" card, "Popular Doctors" heading, horizontal doctor cards, "Community" heading, community illustration card, bottom nav (Home/Appointments/AI Bot/Nearby/Profile) | |
| 2.1.2 | Tap notification bell | Navigation | Goes to Notifications screen | |
| 2.1.3 | Tap search bar, type "cardio", submit | Navigation | Goes to Browse Doctors with "cardio" query | |
| 2.1.4 | Tap mic icon in search bar | Voice search | ⚠️ May not be implemented — observe behavior | |
| 2.1.5 | Tap "Clinic Booking" card | Navigation | Goes to Specializations screen | |
| 2.1.6 | Scroll Popular Doctors horizontally | Doctor cards | Cards show doctor photo, name, specialty, rating star, location, fee. Each card has heart icon (favorite toggle). | |
| 2.1.7 | Tap heart icon on a doctor card | Toggle | Heart fills/unfills. Toggle favorite status. | |
| 2.1.8 | Tap a doctor card | Navigation | Goes to Doctor Profile screen for that doctor | |
| 2.1.9 | Tap "Join Our Community" button | Navigation | Goes to Community Feed screen | |
| 2.1.10 | View bottom nav | Icons & labels | Home (active), Appointments, AI Bot (robot icon), Nearby, Profile | |
| 2.1.11 | Tap "Appointments" in bottom nav | Navigation | Goes to My Appointments screen | |
| 2.1.12 | Tap "AI Bot" in bottom nav | Navigation | ⚠️ **Known Issue**: Goes to Community Feed instead of Chatbot. Document this. | |
| 2.1.13 | Tap "Nearby" in bottom nav | Navigation | ⚠️ **Known Issue**: Goes to Browse Doctors instead of Map. Document this. | |
| 2.1.14 | Tap "Profile" in bottom nav | Navigation | Goes to Patient Profile screen | |

**Critical Checks:**
- [ ] Home screen loads without errors
- [ ] Popular Doctors load from API (not just mock data)
- [ ] Doctor cards display correct data (name, specialty, rating, fee)
- [ ] Favorite toggle works and persists
- [ ] Bottom nav icons match design (Home, Appointments, AI Bot, Nearby, Profile)
- [ ] AI Bot nav item is misleading (goes to Community) — flag as bug
- [ ] Nearby nav item is misleading (goes to Browse Doctors) — flag as bug

---

### 2.2 Browse Doctors & Specializations

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.2.1 | View Specializations screen | Grid layout | Grid of specialty cards: Cardiology, Dermatology, Pediatrics, Orthopedics, Neurology, General, etc. | |
| 2.2.2 | Tap a specialization | Navigation | Goes to Browse Doctors filtered by that specialty | |
| 2.2.3 | View Browse Doctors screen | List layout | Search bar at top, filter chips, vertical list of doctor cards | |
| 2.2.4 | Tap filter chip (e.g., "Cardiology") | Filter | List updates to show only Cardiology doctors | |
| 2.2.5 | Tap a doctor card | Navigation | Goes to Doctor Profile screen | |
| 2.2.6 | Tap back arrow | Navigation | Returns to previous screen | |

**Critical Checks:**
- [ ] Specializations load from API
- [ ] Filtering works correctly
- [ ] Doctor list loads with pagination (if applicable)
- [ ] Search returns relevant results

---

### 2.3 Doctor Profile & Booking

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.3.1 | View Doctor Profile | Layout | Doctor photo (circle), name, specialty, fee. "Book Appointment" button. "My Appointments" outlined button. | |
| 2.3.2 | Compare with Figma design | Visual elements | ⚠️ **Known Issue**: Missing: Experience/Patients stats, Professional Background section (Education/Certification cards), inline calendar, Available Slots grid. Only basic info shown. | |
| 2.3.3 | Tap "Book Appointment" | Navigation | Goes to Book Appointment screen | |
| 2.3.4 | View Book Appointment screen | Layout | Doctor info card at top, "Select Date" section with date picker, "Select Time" with time slot chips, family member toggle (if family members exist), booking summary, "Confirm Appointment" button | |
| 2.3.5 | Tap date field | Date picker | Native date picker opens, select a future date | |
| 2.3.6 | Tap a time slot chip | Selection | Chip becomes selected (filled blue) | |
| 2.3.7 | Toggle "Book for Family Member" | Family list | List of family members appears with radio-style selection | |
| 2.3.8 | Select a family member | Selection | Member card gets highlighted, checkmark appears | |
| 2.3.9 | Tap "Confirm Appointment" | API call | POST `/api/appointment` with doctorId, date, time, familyMemberId (if selected) | |
| 2.3.10 | After successful booking | Navigation | Goes to Appointment Confirmation screen | |
| 2.3.11 | View Appointment Confirmation | Layout | ⚠️ **Known Issue**: Shows static data: "Tomorrow, 10:00 AM", "Dr. Ahmed Hassan", "Medicare Clinic". Should show actual selected date/time/doctor. | |
| 2.3.12 | Tap "My Appointments" | Navigation | Goes to My Appointments screen | |
| 2.3.13 | Tap "Back to Home" | Navigation | Goes to Patient Home | |

**Critical Checks:**
- [ ] Doctor profile loads from API with correct data
- [ ] Date picker works and limits to future dates
- [ ] Time slots load from API for selected doctor and date
- [ ] Family member toggle works (if family members exist)
- [ ] Booking API call succeeds
- [ ] Confirmation screen shows actual booking details (not static data) — **flag if static**
- [ ] Missing from Figma: calendar view, education/certification cards, experience stats

---

### 2.4 My Appointments

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.4.1 | View My Appointments | Tabs & list | Tabs: Upcoming, Completed, Cancelled. Appointment cards with doctor photo, name, date, time, status badge, action buttons | |
| 2.4.2 | Tap "Upcoming" tab | Filter | Shows only upcoming appointments | |
| 2.4.3 | Tap "Completed" tab | Filter | Shows only completed appointments | |
| 2.4.4 | Tap "Cancelled" tab | Filter | Shows only cancelled appointments | |
| 2.4.5 | Tap "View Details" on an appointment | Navigation | Goes to Appointment Detail screen | |
| 2.4.6 | View Appointment Detail | Layout | Doctor info, appointment date/time, status, clinic location, "Cancel" button, "Reschedule" button | |
| 2.4.7 | Tap "Cancel" | Dialog | Confirmation dialog appears with reason options | |
| 2.4.8 | Select reason, confirm cancel | API call | PUT `/api/appointment/{id}/cancel` — appointment status changes to Cancelled | |
| 2.4.9 | Tap "Reschedule" | Date picker | Select new date, then new time slot | |
| 2.4.10 | Confirm reschedule | API call | PUT `/api/appointment/{id}/reschedule` — appointment updated | |
| 2.4.11 | Tap "Rebook" on a completed/cancelled appointment | Navigation | Goes to Book Appointment for that doctor | |
| 2.4.12 | Tap "Queue Tracker" (if available) | Navigation | Goes to Queue Tracker screen | |

**Critical Checks:**
- [ ] Appointments load from API correctly
- [ ] Tab filtering works
- [ ] Cancel appointment works with reason
- [ ] Reschedule appointment works
- [ ] Appointment detail shows correct info
- [ ] Queue tracker shows live position

---

### 2.5 Community

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.5.1 | View Community Feed | Layout | Search bar, specialization filter chips (All, Cardiology, Dermatology, etc.), post cards, floating action button (+) | |
| 2.5.2 | Tap filter chip "Cardiology" | Filter | List updates to show only Cardiology posts | |
| 2.5.3 | Scroll through posts | Post cards | Each card: author avatar, name, role, time ago, content, specialization chip, comment count | |
| 2.5.4 | Tap a post card | Navigation | Goes to Post Detail screen | |
| 2.5.5 | View Post Detail | Layout | Full post content, comment list, comment input field at bottom | |
| 2.5.6 | Type a comment, tap send | API call | POST `/api/community/posts/{id}/comments` — comment appears in list | |
| 2.5.7 | Tap back | Navigation | Returns to Community Feed | |
| 2.5.8 | Tap FAB (+) | Navigation | Goes to Create Post screen | |
| 2.5.9 | View Create Post screen | Layout | Author profile preview, text area, specialization dropdown | |
| 2.5.10 | Type post content, select specialization | Inputs | Content and specialization selected | |
| 2.5.11 | Tap "Post" | API call | POST `/api/community/posts` — post created, returns to feed | |
| 2.5.12 | Verify new post appears | Feed | New post appears at top of feed | |

**Critical Checks:**
- [ ] Posts load from API
- [ ] Filter chips work
- [ ] Post detail loads comments
- [ ] Adding comment works
- [ ] Creating post works
- [ ] New post appears in feed after creation
- [ ] ⚠️ Missing: share button on post cards (present in Figma, missing in Flutter)

---

### 2.6 Patient Profile & Settings

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.6.1 | View Patient Profile | Layout | Profile photo, name, email, menu list: Medical History, My Favorites, Edit Profile, About | |
| 2.6.2 | Tap "Medical History" | Navigation | Goes to Medical History screen | |
| 2.6.3 | View Medical History | Layout | Chronic conditions chips, current medications list, lab test results | |
| 2.6.4 | Tap "My Favorites" | Navigation | Goes to Favorites screen with favorite doctors list | |
| 2.6.5 | Tap a favorite doctor | Navigation | Goes to Doctor Profile | |
| 2.6.6 | Tap "Edit Profile" | Navigation | Goes to Edit Profile form | |
| 2.6.7 | View Edit Profile | Form fields | Name, Phone, Email, Gender, Age, Address, Blood Type, Allergies, Chronic Diseases | |
| 2.6.8 | Modify a field, tap Save | API call | PUT `/api/patient/profile` — profile updated | |
| 2.6.9 | Tap "About" | Navigation | Goes to About screen with app info | |
| 2.6.10 | Tap "Family Members" (from menu or elsewhere) | Navigation | Goes to Family Members screen | |
| 2.6.11 | View Family Members | List | Family member cards: avatar, name, relation, age, primary badge, remove icon | |
| 2.6.12 | Tap "Add Family Member" | Navigation | Goes to Add Family Member form | |
| 2.6.13 | Fill form (name, relation, age, gender, etc.), tap Save | API call | POST `/api/patient/family-members` — member added | |
| 2.6.14 | Tap remove icon on a member | Dialog | Confirmation dialog: "Remove Member?" | |
| 2.6.15 | Confirm removal | API call | DELETE `/api/patient/family-members/{id}` — member removed | |

**Critical Checks:**
- [ ] Profile loads correct data
- [ ] Edit profile saves changes
- [ ] Medical history loads from API
- [ ] Favorites list loads
- [ ] Family members CRUD works
- [ ] About screen shows app version and description

---

### 2.7 Notifications

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 2.7.1 | Tap notification bell on Home | Navigation | Goes to Notifications screen | |
| 2.7.2 | View Notifications | Layout | List grouped by "Recent" and "Yesterday", each item: icon, title, message, time, "Mark all as read" link | |
| 2.7.3 | Tap "Mark all as read" | API call | PUT `/api/notification/{id}/read` for all — items marked as read | |
| 2.7.4 | Tap a notification | Action | Navigates to relevant screen (appointment, community post, etc.) | |
| 2.7.5 | View empty state | Layout | If no notifications: "Appointment Not Found" illustration, "Go to Schedule" button | |

**Critical Checks:**
- [ ] Notifications load from API
- [ ] Mark all as read works
- [ ] Tapping notification navigates correctly
- [ ] Empty state displays when no notifications

---

## Section 3: Doctor QA Flow

> **Pre-requisite**: Log in as a Doctor user  
> **Test Account**: Use seeded doctor account or register new doctor

---

### 3.1 Doctor Dashboard

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 3.1.1 | View Doctor Dashboard | Layout | Profile avatar + "Medicare" top-left, notification bell top-right, "Today's Appointments" card with total count, 4 stat chips (New Visit, Follow Up, Walk-in, Online), Earnings card, "View Today's Schedule" button, "Queue Summary" heading, Queue Summary card (Waiting/With Doctor/Completed) | |
| 3.1.2 | Compare with Figma | Visual details | ⚠️ **Known Issue**: Figma shows 2x2 bento grid for stats. Flutter uses horizontal row chips. Layout similar but card internals differ. | |
| 3.1.3 | Tap notification bell | Navigation | Goes to Doctor Notifications | |
| 3.1.4 | Tap "View Today's Schedule" | Navigation | Goes to Doctor Appointments screen | |
| 3.1.5 | View Queue Summary | Stats | Shows counts for Waiting, With Doctor, Completed | |
| 3.1.6 | Tap Queue Summary row | Navigation | Goes to Doctor Queue screen | |
| 3.1.7 | View bottom nav | Icons & labels | Home (active), Schedule, Community, Profile | |
| 3.1.8 | Tap "Schedule" in bottom nav | Navigation | Goes to Doctor Appointments | |
| 3.1.9 | Tap "Community" in bottom nav | Navigation | Goes to Doctor Community Feed | |
| 3.1.10 | Tap "Profile" in bottom nav | Navigation | Goes to Doctor Profile | |

**Critical Checks:**
- [ ] Dashboard loads from API with real stats
- [ ] Stats match actual appointment data
- [ ] Earnings display correctly
- [ ] Queue summary reflects live data
- [ ] Bottom nav uses correct icons and labels

---

### 3.2 Doctor Appointments & Queue

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 3.2.1 | View Doctor Appointments | Layout | Date selector, appointment list with time, patient name, type, status | |
| 3.2.2 | Tap a date | Filter | List updates to show appointments for selected date | |
| 3.2.3 | Tap an appointment | Navigation | Goes to Consultation screen | |
| 3.2.4 | View Doctor Queue | Layout | Live queue list with patient name, appointment type, status, "Call Next" button | |
| 3.2.5 | Tap "Call Next" | API call | POST `/api/appointment/queue/call-next` — next patient called | |
| 3.2.6 | Verify queue updates | List | Queue list refreshes, status changes | |

**Critical Checks:**
- [ ] Appointments load for selected date
- [ ] Queue shows live data
- [ ] Call Next works and updates queue
- [ ] Status changes reflect in real-time

---

### 3.3 Consultation & Prescription

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 3.3.1 | View Consultation screen | Layout | Patient header (name, ID, type badge, date, time), Vitals section (Blood Pressure, Heart Rate), SOAP Summary (Subjective, Objective, Assessment, Plan), Prescriptions list, "Add Prescription" button, "History" link | |
| 3.3.2 | Tap "Add Prescription" | Navigation/Modal | Opens prescription form (may be modal or new screen) | |
| 3.3.3 | View Prescription form | Layout | Medication name, dosage, frequency, duration, timing pills (Before Food, After Food, With Food, Bedtime), patient instructions | |
| 3.3.4 | Fill prescription fields | Inputs | All fields accept input | |
| 3.3.5 | Tap "Save Medication" | API call | POST `/api/medicalrecord` with prescription data | |
| 3.3.6 | Verify prescription appears | List | New prescription appears in consultation screen | |
| 3.3.7 | Tap "History" | Navigation | Goes to Patient History screen | |
| 3.3.8 | View Patient History | Layout | Patient name, age, gender, blood type, chronic conditions chips, current medications list | |
| 3.3.9 | Tap back | Navigation | Returns to Consultation | |

**Critical Checks:**
- [ ] Consultation screen loads patient data
- [ ] Vitals display correctly
- [ ] SOAP fields can be filled and saved
- [ ] Prescription can be added
- [ ] Patient history loads correctly
- [ ] ⚠️ Missing: standalone Prescription screen (Figma shows full screen, Flutter embeds in consultation)

---

### 3.4 Doctor Profile & Settings

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 3.4.1 | View Doctor Profile | Layout | Profile photo, name, General Summary card, Professional Details grid, Education & Certifications, Associated Clinics, Professional Bio | |
| 3.4.2 | Compare with Figma | Visual details | ⚠️ **Known Issue**: Figma shows rich layout with multiple cards. Flutter may be simplified. | |
| 3.4.3 | Tap "Edit Profile" | Navigation | Goes to Edit Doctor Profile form | |
| 3.4.4 | View Edit Profile | Form fields | Specialty, Sub-specialty, Experience, Languages, Degree, University, Graduation Year, Board Certification, Bio | |
| 3.4.5 | Modify fields, tap Save | API call | PUT `/api/doctor/profile` — profile updated | |
| 3.4.6 | Tap "QR Code" | Navigation | Goes to QR Code screen | |
| 3.4.7 | View QR Code | Display | QR code displayed for clinic scanning | |
| 3.4.8 | Tap back, then "Notifications" | Navigation | Goes to Doctor Notifications | |

**Critical Checks:**
- [ ] Profile loads correct data
- [ ] Edit profile saves changes
- [ ] QR code generates and displays
- [ ] Notifications load correctly

---

## Section 4: Clinic QA Flow

> **Pre-requisite**: Log in as a Clinic user  
> **Test Account**: Register new clinic or use seeded clinic admin

---

### 4.1 Clinic Dashboard

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 4.1.1 | View Clinic Dashboard | Layout | Clinic logo + name header, date banner with "Live" badge, 3 stat cards (Paid Patients, Walk-ins, Revenue), Quick Actions row (Add Walk-in, View Queue), Queue Summary card, Recent Appointments list | |
| 4.1.2 | Verify stats | Numbers | Stats reflect today's actual data | |
| 4.1.3 | Tap "Add Walk-in" | Navigation | Goes to Walk-in Booking screen | |
| 4.1.4 | Tap "View Queue" | Navigation | Goes to Clinic Queue screen | |
| 4.1.5 | Tap "See All" on Queue Summary | Navigation | Goes to Clinic Queue screen | |
| 4.1.6 | Scroll Recent Appointments | List | Shows up to 5 recent appointments with patient name, doctor name, time, status, payment status | |
| 4.1.7 | Tap an appointment in list | Navigation | Should go to appointment detail | |
| 4.1.8 | View bottom nav | Icons & labels | Dashboard (active), Doctors, Payments, Profile | |
| 4.1.9 | Tap "Doctors" in bottom nav | Navigation | Goes to Manage Doctors screen | |
| 4.1.10 | Tap "Payments" in bottom nav | Navigation | Goes to Clinic Payments screen | |
| 4.1.11 | Tap "Profile" in bottom nav | Navigation | Goes to Clinic Profile screen | |

**Critical Checks:**
- [ ] Dashboard loads with real clinic data
- [ ] Stats cards update correctly
- [ ] Quick actions navigate correctly
- [ ] Recent appointments load from API
- [ ] Bottom nav uses correct icons and labels

---

### 4.2 Walk-in Booking

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 4.2.1 | View Walk-in Booking | Layout | "Add Walk-in Patient" header, Emergency Status toggle, Search Existing Patient field, Patient Details section (Full Name, Phone, Age, Gender), Clinical Information (Chief Complaint), Scheduling (Assign Time Slot), Accept Payment toggle, Confirm & Add / Cancel buttons | |
| 4.2.2 | Toggle Emergency Status | Switch | Toggle turns on/off, changes priority | |
| 4.2.3 | Search existing patient | Search | Type name/phone, search results appear | |
| 4.2.4 | Fill patient details | Form | Full name, phone, age, gender dropdown | |
| 4.2.5 | Enter chief complaint | Text area | Brief description of symptoms | |
| 4.2.6 | Select time slot | Dropdown | Available slots for today | |
| 4.2.7 | Toggle Accept Payment | Switch | Payment acceptance toggle | |
| 4.2.8 | Tap "Confirm & Add" | API call | POST `/api/appointment/clinic-booking` — walk-in appointment created | |
| 4.2.9 | After success | Navigation | Returns to Clinic Dashboard or Clinic Queue | |
| 4.2.10 | Tap "Cancel" | Navigation | Returns to Clinic Dashboard | |

**Critical Checks:**
- [ ] Form loads correctly
- [ ] Emergency toggle works
- [ ] Search existing patient works
- [ ] Time slots load for selected doctor
- [ ] Walk-in booking API call succeeds
- [ ] Dashboard/Queue updates after booking

---

### 4.3 Clinic Queue

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 4.3.1 | View Clinic Queue | Layout | List of patients with name, doctor name, time, status badge, payment status (Paid/Unpaid) | |
| 4.3.2 | Verify queue order | Sequence | Patients ordered by appointment time/queue number | |
| 4.3.3 | Tap "Start Checkup" on a patient | API call | POST `/api/appointment/{id}/start-checkup` — status changes to In Progress | |
| 4.3.4 | Verify status update | List | Patient card updates to "In Progress" status | |
| 4.3.5 | Tap a patient card | Navigation | Goes to appointment detail or consultation view | |

**Critical Checks:**
- [ ] Queue loads with live data
- [ ] Status updates work
- [ ] Payment status displays correctly
- [ ] Queue order is correct

---

### 4.4 Manage Doctors

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 4.4.1 | View Manage Doctors | Layout | List of doctor cards with avatar, name, specialty, status dot, remove icon. "Add New Doctor" card at bottom. | |
| 4.4.2 | Tap a doctor card | Navigation | Goes to Doctor Detail (Clinic view) | |
| 4.4.3 | Tap "Manage Schedule" on doctor detail | Navigation | Goes to Manage Schedule screen | |
| 4.4.4 | View Manage Schedule | Layout | Date picker with prev/next arrows, day chips, Shift Start/End time inputs, Break Start/End, Max Patients input, Generated Slots preview | |
| 4.4.5 | Set working hours | Inputs | Enter shift start (09:00 AM), shift end (05:00 PM) | |
| 4.4.6 | Set break time | Inputs | Enter break start (01:00 PM), break end (02:00 PM) | |
| 4.4.7 | Set max patients | Input | Enter max patients per day (e.g., 20) | |
| 4.4.8 | Tap "Generate Slots" | Calculation | Slots preview grid appears with time slots | |
| 4.4.9 | Tap "Save Schedule" | API call | POST `/api/doctor/{id}/schedules` — schedule saved | |
| 4.4.10 | Go back to Manage Doctors | Navigation | Returns to doctor list | |
| 4.4.11 | Tap "Add New Doctor" | Options | Shows options: Scan QR or Manual Registration | |
| 4.4.12 | Tap "Scan QR" | Navigation | Goes to Scan QR screen | |
| 4.4.13 | View Scan QR | Camera | Camera view opens for QR scanning | |
| 4.4.14 | Scan a doctor's QR code | API call | GET `/api/clinic/doctors/scan/{qrCodeKey}` — doctor linked to clinic | |
| 4.4.15 | Tap "Manual Registration" | Navigation | Goes to Register Doctor to Clinic form | |
| 4.4.16 | Fill doctor details, tap Register | API call | POST `/api/clinic/doctors/register` — doctor registered | |
| 4.4.17 | Tap remove icon on a doctor | Dialog | Confirmation dialog appears | |
| 4.4.18 | Confirm removal | API call | DELETE `/api/clinic/doctors/{id}` — doctor removed | |

**Critical Checks:**
- [ ] Doctor list loads from API
- [ ] Doctor detail shows correct info
- [ ] Schedule can be set and saved
- [ ] Slots generate correctly based on hours/break/max patients
- [ ] QR scanning works
- [ ] Manual registration works
- [ ] Remove doctor works

---

### 4.5 Clinic Payments

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 4.5.1 | View Clinic Payments | Layout | Payments dashboard with doctor filter dropdown, timeframe filter, revenue stats, payment list | |
| 4.5.2 | Select a doctor from filter | Filter | Payment list updates for selected doctor | |
| 4.5.3 | Select timeframe (Today/Week/Month) | Filter | Stats update for selected timeframe | |
| 4.5.4 | Verify revenue calculations | Numbers | Revenue = sum of paid appointment fees | |
| 4.5.5 | Scroll payment list | List | Each item: patient name, doctor name, amount, date, payment method | |

**Critical Checks:**
- [ ] Payments dashboard loads
- [ ] Doctor filter works
- [ ] Timeframe filter works
- [ ] Revenue calculations are correct
- [ ] Payment list loads from API

---

### 4.6 Clinic Profile & Settings

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 4.6.1 | View Clinic Profile | Layout | Clinic logo, name, address, phone, email, license info | |
| 4.6.2 | Tap "Edit Profile" | Navigation | Goes to Edit Clinic Profile form | |
| 4.6.3 | View Edit Profile | Form fields | Facility Name, Facility ID, Primary Address | |
| 4.6.4 | Modify fields, tap Save | API call | PUT `/api/clinic/profile` — profile updated | |
| 4.6.5 | Tap "Notifications" | Navigation | Goes to Clinic Notifications | |
| 4.6.6 | Tap "Patient Search" | Navigation | Goes to Patient Search screen | |
| 4.6.7 | Search patient by name | Search | GET `/api/patient/search?query=` — results appear | |
| 4.6.8 | Tap a patient result | Navigation | Goes to patient detail/history | |

**Critical Checks:**
- [ ] Profile loads correct data
- [ ] Edit profile saves changes
- [ ] Patient search works
- [ ] Notifications load correctly

---

## Section 5: Cross-Cutting Tests

### 5.1 Navigation & Routing

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 5.1.1 | Deep link to doctor profile | URL/App link | `/patient/doctor-profile/1` opens correct doctor | |
| 5.1.2 | Press back from inner screen | Navigation | Returns to previous screen (not home) | |
| 5.1.3 | Press back from Home | App behavior | Shows exit confirmation or stays (depending on OS) | |
| 5.1.4 | Background app, reopen | State | App resumes at same screen with data intact | |
| 5.1.5 | Kill app, reopen | Auth state | If token valid, auto-login to correct role home. If expired, goes to Login. | |

### 5.2 Offline / Network Issues

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 5.2.1 | Turn off WiFi, open app | Behavior | Shows error or cached data (if any) | |
| 5.2.2 | Turn off WiFi, tap Book Appointment | Behavior | Shows error message, doesn't crash | |
| 5.2.3 | Turn WiFi back on, pull to refresh | Behavior | Data refreshes correctly | |

### 5.3 Token & Security

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 5.3.1 | Login, wait 1+ hour | Token expiry | After access token expires, app should auto-refresh using refresh token | |
| 5.3.2 | Login on device A, then device B | Concurrent sessions | Both devices work (if backend supports multiple sessions) | |
| 5.3.3 | Logout | State | Token cleared, redirect to Login. Back button doesn't re-enter app. | |
| 5.3.4 | Tamper with token | Security | App handles invalid token gracefully (redirects to login) | |

### 5.4 Visual & UX Polish

| Step | Action | What to Observe | Expected | Status |
|------|--------|-----------------|----------|--------|
| 5.4.1 | Scroll on all major screens | Performance | Smooth 60fps scrolling, no jank | |
| 5.4.2 | Tap rapidly on buttons | Debounce | No duplicate API calls, no crashes | |
| 5.4.3 | Rotate device | Orientation | App stays in portrait (if locked) or adapts gracefully | |
| 5.4.4 | Use app with large font (accessibility) | Layout | Text doesn't overflow or clip badly | |
| 5.4.5 | Use app with screen reader | Accessibility | Buttons and inputs have labels | |
| 5.4.6 | Verify font family | Typography | Text uses Inter font (or falls back to system font if not configured) | |

---

## Section 6: Known Issues Summary (For Reference)

| # | Issue | Severity | Where Observed |
|---|-------|----------|----------------|
| 1 | AI Chatbot screen missing — nav routes to Community | High | Patient Home bottom nav |
| 2 | Nearby/Map screen missing — nav routes to Browse Doctors | High | Patient Home bottom nav |
| 3 | Doctor Profile screen oversimplified vs Figma | High | Patient → Doctor Profile |
| 4 | Appointment Confirmation shows static data | Medium | Patient → Book Appointment → Confirmation |
| 5 | Social login buttons non-functional | Medium | Login screen |
| 6 | Prescription not standalone screen | Medium | Doctor → Consultation |
| 7 | Community post missing share button | Low | Community Feed |
| 8 | Font 'Inter' not declared in pubspec.yaml | Low | App-wide typography |
| 9 | Clinic lacks dedicated Appointments screen | Medium | Clinic Dashboard |
| 10 | AI Chatbot backend endpoint missing | High | Backend API |
| 11 | Geospatial search endpoint missing | Medium | Backend API |
| 12 | Structured prescription entity missing | Medium | Backend API |

---

## QA Sign-Off

| Role | Tester Name | Date | Result |
|------|-------------|------|--------|
| Patient Flow | | | |
| Doctor Flow | | | |
| Clinic Flow | | | |
| Cross-Cutting | | | |

**Overall App Status:** ☐ Ready for Release ☐ Needs Fixes ☐ Major Rework Required

---

*End of File 2 — Manual QA Checklist*
