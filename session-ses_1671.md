# Unify bottom navigation across app

**Session ID:** ses_16714a4b7ffeCfZKPHT2WbgY0c
**Created:** 6/5/2026, 8:53:41 PM
**Updated:** 6/5/2026, 8:56:14 PM

---

## User

the bottom navigation bar is horrible and inconsistent throughout the app, it is not following best practices and is different on each screen fix it

---

## Assistant (Sisyphus - Ultraworker · Kimi K2.6 · 35.0s)

I read this as a **visual-engineering** task — fixing an inconsistent bottom navigation bar across a Flutter app. Let me explore the codebase first to understand the current state.

**Tool: task**

**Input:**
```json
{
  "prompt": "Find ALL bottom navigation bar implementations in this Flutter app. Search for:\n1. BottomNavigationBar widgets\n2. Custom bottom nav widgets/components\n3. Any navigation-related files in lib/\n4. Screen files that might contain their own bottom nav\n\nReturn: file paths, line numbers, and brief descriptions of each implementation found. Be thorough — check every screen.",
  "description": "Find all bottom nav implementations",
  "run_in_background": true,
  "subagent_type": "explore"
}
```

**Output:**
```
Background task launched.

Background Task ID: bg_1e9ee41f
Description: Find all bottom nav implementations
Agent: explore
Status: pending

System notifies on completion. Use `background_output` with task_id="bg_1e9ee41f" to check.

Do NOT call background_output now. Wait for <system-reminder> notification first.

<task_metadata>
session_id: ses_167142affffedzqbMBi6IQ9BYV
background_task_id: bg_1e9ee41f
subagent: explore
</task_metadata>

to continue: task(task_id="ses_167142affffedzqbMBi6IQ9BYV", load_skills=[], run_in_background=false, prompt="...")
```

**Tool: glob**

**Input:**
```json
{
  "pattern": "lib/**/*.dart",
  "path": "C:\\Users\\Zowail\\StudioProjects\\medicare"
}
```

**Output:**
```
Found 93 file(s)

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\services\doctor_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\consultation_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\shared_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\patient_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\widgets\debug_account_switcher.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\constants\app_constants.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\manage_schedule_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\appointment_confirmation_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\doctor_profile\doctor_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\appointment_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\book_appointment_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\doctor_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_doctor_detail_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\clinic_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\services\api_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\register_clinic_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\edit_clinic_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\navigation\app_router.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\register_doctor_to_clinic_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\scan_doctor_qr_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\nearby\nearby_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\services\appointment_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\services\patient_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\home\patient_home_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_dashboard_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\nearby\nearby_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\notifications_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\post_detail_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\create_post_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_community_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\community_feed_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\browse_doctors\browse_doctors_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\favorites_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\services\patient_notifications_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\services\patient_community_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\family_members_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\add_family_member_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\edit_patient_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\clinic_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\register_doctor_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\auth_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\submit_review_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\medical_history_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\services\patient_medical_history_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\edit_doctor_profile_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\theme\app_text_styles.dart
C:\Users\Zowail\StudioProjects\medicare\lib\main.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\specializations\specializations_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\services\patient_profile_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\services\patient_family_members_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\services\patient_appointments_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\data\doctor_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\queue_tracker_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\my_appointments_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\appointment_detail_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_queue_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_qr_code_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_patient_history_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_notifications_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_appointments_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\walk_in_booking_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_queue_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_payments_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_patient_search_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_notifications_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_doctors_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_dashboard_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\widgets\otp_input.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\widgets\dashed_upload.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\widgets\auth_layout.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\verify_otp_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\splash_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\role_selection_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\reset_password_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\register_patient_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\onboarding_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\login_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\features\auth\screens\forgot_password_screen.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\widgets\doctor_card.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\widgets\app_text_field.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\widgets\app_button.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\widgets\app_bottom_nav.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\theme\app_theme.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\theme\app_colors.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\services\review_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\services\community_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\services\auth_service.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\user_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\community_models.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\models\api_response.dart
C:\Users\Zowail\StudioProjects\medicare\lib\core\bloc\auth_bloc.dart
```

---

## Assistant (Sisyphus - Ultraworker · Kimi K2.6 · 10.3s)

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\core\\widgets\\app_bottom_nav.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\core\widgets\app_bottom_nav.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import '../theme/app_colors.dart';
3: import '../theme/app_text_styles.dart';
4: 
5: class AppBottomNav extends StatelessWidget {
6:   final int currentIndex;
7:   final List<BottomNavItem> items;
8:   final Function(int) onTap;
9: 
10:   const AppBottomNav({
11:     super.key,
12:     required this.currentIndex,
13:     required this.items,
14:     required this.onTap,
15:   });
16: 
17:   @override
18:   Widget build(BuildContext context) {
19:     return Container(
20:       decoration: BoxDecoration(
21:         color: AppColors.surface,
22:         boxShadow: [
23:           BoxShadow(
24:             color: AppColors.shadow,
25:             blurRadius: 10,
26:             offset: const Offset(0, -2),
27:           ),
28:         ],
29:       ),
30:       child: SafeArea(
31:         child: Padding(
32:           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
33:           child: Row(
34:             mainAxisAlignment: MainAxisAlignment.spaceAround,
35:             children: List.generate(items.length, (index) {
36:               final item = items[index];
37:               final isSelected = index == currentIndex;
38: 
39:               return Expanded(
40:                 child: GestureDetector(
41:                   onTap: () => onTap(index),
42:                   behavior: HitTestBehavior.opaque,
43:                   child: Column(
44:                     mainAxisSize: MainAxisSize.min,
45:                     children: [
46:                       Icon(
47:                         isSelected ? item.selectedIcon : item.icon,
48:                         color: isSelected ? AppColors.primary : AppColors.textTertiary,
49:                         size: 24,
50:                       ),
51:                       const SizedBox(height: 4),
52:                       Text(
53:                         item.label,
54:                         style: AppTextStyles.labelSmall.copyWith(
55:                           color: isSelected ? AppColors.primary : AppColors.textTertiary,
56:                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
57:                         ),
58:                         maxLines: 1,
59:                         overflow: TextOverflow.ellipsis,
60:                       ),
61:                     ],
62:                   ),
63:                 ),
64:               );
65:             }),
66:           ),
67:         ),
68:       ),
69:     );
70:   }
71: }
72: 
73: class BottomNavItem {
74:   final IconData icon;
75:   final IconData selectedIcon;
76:   final String label;
77: 
78:   BottomNavItem({
79:     required this.icon,
80:     required this.selectedIcon,
81:     required this.label,
82:   });
83: }
84: 
85: // Role-specific bottom nav configurations
86: class PatientNavItems {
87:   static List<BottomNavItem> get items => [
88:         BottomNavItem(
89:           icon: Icons.home_outlined,
90:           selectedIcon: Icons.home,
91:           label: 'Home',
92:         ),
93:         BottomNavItem(
94:           icon: Icons.calendar_today_outlined,
95:           selectedIcon: Icons.calendar_today,
96:           label: 'Appointments',
97:         ),
98:         BottomNavItem(
99:           icon: Icons.chat_bubble_outline,
100:           selectedIcon: Icons.chat_bubble,
101:           label: 'AI Bot',
102:         ),
103:         BottomNavItem(
104:           icon: Icons.location_on_outlined,
105:           selectedIcon: Icons.location_on,
106:           label: 'Nearby',
107:         ),
108:         BottomNavItem(
109:           icon: Icons.person_outline,
110:           selectedIcon: Icons.person,
111:           label: 'Profile',
112:         ),
113:       ];
114: }
115: 
116: class DoctorNavItems {
117:   static List<BottomNavItem> get items => [
118:         BottomNavItem(
119:           icon: Icons.dashboard_outlined,
120:           selectedIcon: Icons.dashboard,
121:           label: 'Dashboard',
122:         ),
123:         BottomNavItem(
124:           icon: Icons.calendar_today_outlined,
125:           selectedIcon: Icons.calendar_today,
126:           label: 'Schedule',
127:         ),
128:         BottomNavItem(
129:           icon: Icons.chat_bubble_outline,
130:           selectedIcon: Icons.chat_bubble,
131:           label: 'Community',
132:         ),
133:         BottomNavItem(
134:           icon: Icons.person_outline,
135:           selectedIcon: Icons.person,
136:           label: 'Profile',
137:         ),
138:       ];
139: }
140: 
141: class ClinicNavItems {
142:   static List<BottomNavItem> get items => [
143:         BottomNavItem(
144:           icon: Icons.dashboard_outlined,
145:           selectedIcon: Icons.dashboard,
146:           label: 'Dashboard',
147:         ),
148:         BottomNavItem(
149:           icon: Icons.people_outline,
150:           selectedIcon: Icons.people,
151:           label: 'Doctors',
152:         ),
153:         BottomNavItem(
154:           icon: Icons.payments_outlined,
155:           selectedIcon: Icons.payments,
156:           label: 'Payments',
157:         ),
158:         BottomNavItem(
159:           icon: Icons.person_outline,
160:           selectedIcon: Icons.person,
161:           label: 'Profile',
162:         ),
163:       ];
164: }

(End of file - total 164 lines)
</content>

[Project README: C:\Users\Zowail\StudioProjects\medicare\README.md]
# medicare

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\core\\navigation\\app_router.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\core\navigation\app_router.dart</path>
<type>file</type>
<content>
1: import 'dart:async';
2: 
3: import 'package:flutter/material.dart';
4: import 'package:flutter_bloc/flutter_bloc.dart';
5: import 'package:go_router/go_router.dart';
6: 
7: import '../bloc/auth_bloc.dart';
8: import '../constants/app_constants.dart';
9: import '../models/appointment_models.dart';
10: import '../models/shared_models.dart';
11: import '../theme/app_colors.dart';
12: import '../theme/app_text_styles.dart';
13: import '../widgets/app_button.dart';
14: 
15: import '../../features/auth/screens/splash_screen.dart';
16: import '../../features/auth/screens/onboarding_screen.dart';
17: import '../../features/auth/screens/login_screen.dart';
18: import '../../features/auth/screens/role_selection_screen.dart';
19: import '../../features/auth/screens/register_patient_screen.dart';
20: import '../../features/auth/screens/register_doctor_screen.dart';
21: import '../../features/auth/screens/register_clinic_screen.dart';
22: import '../../features/auth/screens/forgot_password_screen.dart';
23: import '../../features/auth/screens/verify_otp_screen.dart';
24: import '../../features/auth/screens/reset_password_screen.dart';
25: 
26: import '../../features/patient/browse_doctors/browse_doctors_screen.dart';
27: import '../../features/patient/doctor_profile/doctor_profile_screen.dart';
28: import '../../features/patient/home/patient_home_screen.dart';
29: import '../../features/patient/nearby/nearby_screen.dart';
30: import '../../features/patient/specializations/specializations_screen.dart';
31: 
32: import '../../features/patient/appointments/book_appointment_screen.dart';
33: import '../../features/patient/appointments/appointment_confirmation_screen.dart';
34: import '../../features/patient/appointments/my_appointments_screen.dart';
35: import '../../features/patient/appointments/appointment_detail_screen.dart';
36: import '../../features/patient/appointments/queue_tracker_screen.dart';
37: 
38: import '../../features/patient/community/community_feed_screen.dart';
39: import '../../features/patient/community/create_post_screen.dart';
40: import '../../features/patient/community/post_detail_screen.dart';
41: 
42: import '../../features/patient/profile/patient_profile_screen.dart';
43: import '../../features/patient/profile/edit_patient_profile_screen.dart';
44: import '../../features/patient/profile/medical_history_screen.dart';
45: import '../../features/patient/profile/family_members_screen.dart';
46: import '../../features/patient/profile/add_family_member_screen.dart';
47: import '../../features/patient/profile/favorites_screen.dart';
48: import '../../features/patient/profile/notifications_screen.dart';
49: import '../../features/patient/profile/submit_review_screen.dart';
50: 
51: import '../../features/doctor/screens/doctor_dashboard_screen.dart';
52: import '../../features/doctor/screens/doctor_appointments_screen.dart';
53: import '../../features/doctor/screens/doctor_queue_screen.dart';
54: import '../../features/doctor/screens/doctor_patient_history_screen.dart';
55: import '../../features/doctor/screens/consultation_screen.dart';
56: import '../../features/doctor/screens/doctor_profile_screen.dart' as doctor_screens;
57: import '../../features/doctor/screens/edit_doctor_profile_screen.dart';
58: import '../../features/doctor/screens/doctor_qr_code_screen.dart';
59: import '../../features/doctor/screens/doctor_community_screen.dart';
60: import '../../features/doctor/screens/doctor_notifications_screen.dart';
61: 
62: import '../../features/clinic/screens/clinic_dashboard_screen.dart';
63: import '../../features/clinic/screens/clinic_queue_screen.dart';
64: import '../../features/clinic/screens/clinic_doctors_screen.dart';
65: import '../../features/clinic/screens/clinic_doctor_detail_screen.dart';
66: import '../../features/clinic/screens/scan_doctor_qr_screen.dart';
67: import '../../features/clinic/screens/register_doctor_to_clinic_screen.dart';
68: import '../../features/clinic/screens/manage_schedule_screen.dart';
69: import '../../features/clinic/screens/clinic_payments_screen.dart';
70: import '../../features/clinic/screens/walk_in_booking_screen.dart';
71: import '../../features/clinic/screens/clinic_profile_screen.dart';
72: import '../../features/clinic/screens/edit_clinic_profile_screen.dart';
73: import '../../features/clinic/screens/clinic_patient_search_screen.dart';
74: import '../../features/clinic/screens/clinic_notifications_screen.dart';
75: 
76: class AppRouter {
77:   static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
78: 
79:   static GoRouter createRouter(AuthBloc authBloc) {
80:     return GoRouter(
81:       navigatorKey: navigatorKey,
82:       initialLocation: AppRoutes.splash,
83:       refreshListenable: GoRouterRefreshStream(authBloc.stream),
84:       redirect: (context, state) {
85:         final authState = authBloc.state;
86:         final isAuthenticated = authState is AuthAuthenticated;
87:         final isAuthRoute = state.matchedLocation.startsWith('/login') ||
88:             state.matchedLocation.startsWith('/register') ||
89:             state.matchedLocation.startsWith('/forgot') ||
90:             state.matchedLocation.startsWith('/verify') ||
91:             state.matchedLocation.startsWith('/reset') ||
92:             state.matchedLocation == AppRoutes.onboarding ||
93:             state.matchedLocation == AppRoutes.splash ||
94:             state.matchedLocation == AppRoutes.roleSelection;
95: 
96:         if (authState is AuthLoading) return null;
97: 
98:         if (!isAuthenticated && !isAuthRoute) {
99:           return AppRoutes.login;
100:         }
101: 
102:         if (isAuthenticated && isAuthRoute && state.matchedLocation != AppRoutes.splash) {
103:           final role = authState.role;
104:           switch (role) {
105:             case 'Patient':
106:               return AppRoutes.patientHome;
107:             case 'Doctor':
108:               return AppRoutes.doctorDashboard;
109:             case 'ClinicAdmin':
110:               return AppRoutes.clinicDashboard;
111:             default:
112:               return AppRoutes.patientHome;
113:           }
114:         }
115: 
116:         return null;
117:       },
118:       routes: [
119:         // Auth Routes
120:         GoRoute(
121:           path: AppRoutes.splash,
122:           builder: (context, state) => const SplashScreen(),
123:         ),
124:         GoRoute(
125:           path: AppRoutes.onboarding,
126:           builder: (context, state) => const OnboardingScreen(),
127:         ),
128:         GoRoute(
129:           path: AppRoutes.login,
130:           builder: (context, state) => const LoginScreen(),
131:         ),
132:         GoRoute(
133:           path: AppRoutes.roleSelection,
134:           builder: (context, state) => const RoleSelectionScreen(),
135:         ),
136:         GoRoute(
137:           path: AppRoutes.registerPatient,
138:           builder: (context, state) => const RegisterPatientScreen(),
139:         ),
140:         GoRoute(
141:           path: AppRoutes.registerDoctor,
142:           builder: (context, state) => const RegisterDoctorScreen(),
143:         ),
144:         GoRoute(
145:           path: AppRoutes.registerClinic,
146:           builder: (context, state) => const RegisterClinicScreen(),
147:         ),
148:         GoRoute(
149:           path: AppRoutes.forgotPassword,
150:           builder: (context, state) => const ForgotPasswordScreen(),
151:         ),
152:         GoRoute(
153:           path: AppRoutes.verifyOtp,
154:           builder: (context, state) {
155:             final phone = state.extra as String?;
156:             return VerifyOtpScreen(phone: phone ?? '');
157:           },
158:         ),
159:         GoRoute(
160:           path: AppRoutes.resetPassword,
161:           builder: (context, state) {
162:             final extra = state.extra as Map<String, String>?;
163:             return ResetPasswordScreen(
164:               phone: extra?['phone'] ?? '',
165:               otpCode: extra?['otpCode'] ?? '',
166:             );
167:           },
168:         ),
169: 
170:         // Patient Routes
171:         GoRoute(
172:           path: AppRoutes.patientHome,
173:           builder: (context, state) => const PatientHomeScreen(),
174:         ),
175:         GoRoute(
176:           path: AppRoutes.patientSpecializations,
177:           builder: (context, state) => const SpecializationsScreen(),
178:         ),
179:         GoRoute(
180:           path: AppRoutes.patientBrowseDoctors,
181:           builder: (context, state) => const BrowseDoctorsScreen(),
182:         ),
183:         GoRoute(
184:           path: AppRoutes.patientNearby,
185:           builder: (context, state) => const NearbyScreen(),
186:         ),
187:         GoRoute(
188:           path: '${AppRoutes.patientDoctorProfile}/:id',
189:           builder: (context, state) {
190:             final doctorId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
191:             return DoctorProfileScreen(doctorId: doctorId);
192:           },
193:         ),
194:         GoRoute(
195:           path: AppRoutes.patientBookAppointment,
196:           builder: (context, state) {
197:             final extra = state.extra as Map<String, dynamic>?;
198:             return BookAppointmentScreen(
199:               doctorId: extra?['doctorId'] ?? 0,
200:             );
201:           },
202:         ),
203:         GoRoute(
204:           path: AppRoutes.patientAppointmentConfirmation,
205:           builder: (context, state) {
206:             final appointment = state.extra;
207:             if (appointment is! Appointment) {
208:               return const _MissingAppointmentScreen();
209:             }
210:             return AppointmentConfirmationScreen(appointment: appointment);
211:           },
212:         ),
213:         GoRoute(
214:           path: AppRoutes.patientAppointments,
215:           builder: (context, state) => const MyAppointmentsScreen(),
216:         ),
217:         GoRoute(
218:           path: '${AppRoutes.patientAppointmentDetail}/:id',
219:           builder: (context, state) {
220:             final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
221:             return AppointmentDetailScreen(appointmentId: id);
222:           },
223:         ),
224:         GoRoute(
225:           path: '${AppRoutes.patientQueueTracker}/:id',
226:           builder: (context, state) {
227:             final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
228:             return QueueTrackerScreen(appointmentId: id);
229:           },
230:         ),
231:         GoRoute(
232:           path: AppRoutes.patientCommunity,
233:           builder: (context, state) => const CommunityFeedScreen(),
234:         ),
235:         GoRoute(
236:           path: AppRoutes.patientCreatePost,
237:           builder: (context, state) => const CreatePostScreen(),
238:         ),
239:         GoRoute(
240:           path: '${AppRoutes.patientPostDetail}/:id',
241:           builder: (context, state) {
242:             final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
243:             return PostDetailScreen(postId: id);
244:           },
245:         ),
246:         GoRoute(
247:           path: AppRoutes.patientProfile,
248:           builder: (context, state) => const PatientProfileScreen(),
249:         ),
250:         GoRoute(
251:           path: AppRoutes.patientEditProfile,
252:           builder: (context, state) => const EditPatientProfileScreen(),
253:         ),
254:         GoRoute(
255:           path: AppRoutes.patientMedicalHistory,
256:           builder: (context, state) => const MedicalHistoryScreen(),
257:         ),
258:         GoRoute(
259:           path: AppRoutes.patientFamilyMembers,
260:           builder: (context, state) => const FamilyMembersScreen(),
261:         ),
262:         GoRoute(
263:           path: AppRoutes.patientAddFamilyMember,
264:           builder: (context, state) {
265:             final member = state.extra as FamilyMember?;
266:             return AddFamilyMemberScreen(existingMember: member);
267:           },
268:         ),
269:         GoRoute(
270:           path: AppRoutes.patientFavorites,
271:           builder: (context, state) => const FavoritesScreen(),
272:         ),
273:         GoRoute(
274:           path: AppRoutes.patientNotifications,
275:           builder: (context, state) => const NotificationsScreen(),
276:         ),
277:         GoRoute(
278:           path: AppRoutes.patientSubmitReview,
279:           builder: (context, state) {
280:             final extra = state.extra as Map<String, dynamic>?;
281:             return SubmitReviewScreen(
282:               doctorId: extra?['doctorId'] ?? 0,
283:               appointmentId: extra?['appointmentId'] ?? 0,
284:             );
285:           },
286:         ),
287: 
288:         // Doctor Routes
289:         GoRoute(
290:           path: AppRoutes.doctorDashboard,
291:           builder: (context, state) => const DoctorDashboardScreen(),
292:         ),
293:         GoRoute(
294:           path: AppRoutes.doctorAppointments,
295:           builder: (context, state) => const DoctorAppointmentsScreen(),
296:         ),
297:         GoRoute(
298:           path: AppRoutes.doctorQueue,
299:           builder: (context, state) => const DoctorQueueScreen(),
300:         ),
301:         GoRoute(
302:           path: '${AppRoutes.doctorPatientHistory}/:id',
303:           builder: (context, state) {
304:             final patientId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
305:             return DoctorPatientHistoryScreen(patientId: patientId);
306:           },
307:         ),
308:         GoRoute(
309:           path: '${AppRoutes.doctorConsultation}/:id',
310:           builder: (context, state) {
311:             final appointmentId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
312:             return ConsultationScreen(appointmentId: appointmentId);
313:           },
314:         ),
315:         GoRoute(
316:           path: AppRoutes.doctorProfile,
317:           builder: (context, state) => const doctor_screens.DoctorProfileScreen(),
318:         ),
319:         GoRoute(
320:           path: AppRoutes.doctorEditProfile,
321:           builder: (context, state) => const EditDoctorProfileScreen(),
322:         ),
323:         GoRoute(
324:           path: AppRoutes.doctorQrCode,
325:           builder: (context, state) => const DoctorQrCodeScreen(),
326:         ),
327:         GoRoute(
328:           path: AppRoutes.doctorCommunity,
329:           builder: (context, state) => const DoctorCommunityScreen(),
330:         ),
331:         GoRoute(
332:           path: AppRoutes.doctorCreatePost,
333:           builder: (context, state) => const CreatePostScreen(),
334:         ),
335:         GoRoute(
336:           path: AppRoutes.doctorNotifications,
337:           builder: (context, state) => const DoctorNotificationsScreen(),
338:         ),
339:         GoRoute(
340:           path: AppRoutes.doctorSchedule,
341:           builder: (context, state) {
342:             final extra = state.extra as Map<String, dynamic>?;
343:             final doctorId = extra?['doctorId'] ?? 0;
344:             return ManageScheduleScreen(doctorId: doctorId);
345:           },
346:         ),
347: 
348:         // Clinic Routes
349:         GoRoute(
350:           path: AppRoutes.clinicDashboard,
351:           builder: (context, state) => const ClinicDashboardScreen(),
352:         ),
353:         GoRoute(
354:           path: AppRoutes.clinicQueue,
355:           builder: (context, state) => const ClinicQueueScreen(),
356:         ),
357:         GoRoute(
358:           path: AppRoutes.clinicDoctors,
359:           builder: (context, state) => const ClinicDoctorsScreen(),
360:         ),
361:         GoRoute(
362:           path: '${AppRoutes.clinicDoctorDetail}/:id',
363:           builder: (context, state) {
364:             final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
365:             return ClinicDoctorDetailScreen(doctorId: id);
366:           },
367:         ),
368:         GoRoute(
369:           path: AppRoutes.clinicScanQr,
370:           builder: (context, state) => const ScanDoctorQrScreen(),
371:         ),
372:         GoRoute(
373:           path: AppRoutes.clinicRegisterDoctor,
374:           builder: (context, state) => const RegisterDoctorToClinicScreen(),
375:         ),
376:         GoRoute(
377:           path: '${AppRoutes.clinicManageSchedule}/:id',
378:           builder: (context, state) {
379:             final doctorId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
380:             return ManageScheduleScreen(doctorId: doctorId);
381:           },
382:         ),
383:         GoRoute(
384:           path: AppRoutes.clinicPayments,
385:           builder: (context, state) => const ClinicPaymentsScreen(),
386:         ),
387:         GoRoute(
388:           path: AppRoutes.clinicWalkInBooking,
389:           builder: (context, state) => const WalkInBookingScreen(),
390:         ),
391:         GoRoute(
392:           path: AppRoutes.clinicProfile,
393:           builder: (context, state) => const ClinicProfileScreen(),
394:         ),
395:         GoRoute(
396:           path: AppRoutes.clinicEditProfile,
397:           builder: (context, state) => const EditClinicProfileScreen(),
398:         ),
399:         GoRoute(
400:           path: AppRoutes.clinicPatientSearch,
401:           builder: (context, state) => const ClinicPatientSearchScreen(),
402:         ),
403:         GoRoute(
404:           path: AppRoutes.clinicNotifications,
405:           builder: (context, state) => const ClinicNotificationsScreen(),
406:         ),
407:       ],
408:     );
409:   }
410: }
411: 
412: // Stream listener for router refresh
413: class GoRouterRefreshStream extends ChangeNotifier {
414:   GoRouterRefreshStream(Stream<AuthState> stream) {
415:     notifyListeners();
416:     _subscription = stream.asBroadcastStream().listen((_) {
417:       notifyListeners();
418:     });
419:   }
420: 
421:   late final StreamSubscription<AuthState> _subscription;
422: 
423:   @override
424:   void dispose() {
425:     _subscription.cancel();
426:     super.dispose();
427:   }
428: }
429: 
430: class _MissingAppointmentScreen extends StatelessWidget {
431:   const _MissingAppointmentScreen();
432: 
433:   @override
434:   Widget build(BuildContext context) {
435:     return Scaffold(
436:       backgroundColor: AppColors.background,
437:       body: SafeArea(
438:         child: Padding(
439:           padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
440:           child: Column(
441:             mainAxisAlignment: MainAxisAlignment.center,
442:             children: [
443:               const Icon(Icons.event_busy, color: AppColors.textTertiary, size: 64),
444:               const SizedBox(height: 16),
445:               Text(
446:                 'No appointment details found',
447:                 style: AppTextStyles.heading3,
448:                 textAlign: TextAlign.center,
449:               ),
450:               const SizedBox(height: 8),
451:               Text(
452:                 'Please book a new appointment to continue.',
453:                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
454:                 textAlign: TextAlign.center,
455:               ),
456:               const SizedBox(height: 24),
457:               AppButton(
458:                 text: 'Browse Doctors',
459:                 onPressed: () => context.go(AppRoutes.patientBrowseDoctors),
460:               ),
461:               const SizedBox(height: 12),
462:               AppButton(
463:                 text: 'Back to Home',
464:                 isOutlined: true,
465:                 onPressed: () => context.go(AppRoutes.patientHome),
466:               ),
467:             ],
468:           ),
469:         ),
470:       ),
471:     );
472:   }
473: }
474: 
475: // All screens implemented across auth, patient, doctor, and clinic features.

(End of file - total 475 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\home\\patient_home_screen.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\home\patient_home_screen.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import 'package:go_router/go_router.dart';
3: 
4: import '../../../core/constants/app_constants.dart';
5: import '../../../core/theme/app_colors.dart';
6: import '../../../core/theme/app_text_styles.dart';
7: import '../../../core/widgets/doctor_card.dart';
8: import '../data/doctor_service.dart';
9: 
10: class PatientHomeScreen extends StatefulWidget {
11:   const PatientHomeScreen({super.key});
12: 
13:   @override
14:   State<PatientHomeScreen> createState() => _PatientHomeScreenState();
15: }
16: 
17: class _PatientHomeScreenState extends State<PatientHomeScreen> {
18:   final _doctorService = DoctorService();
19:   final _searchController = TextEditingController();
20: 
21:   int _navIndex = 0;
22:   final Set<int> _favoritedDoctorIds = <int>{};
23: 
24:   @override
25:   void dispose() {
26:     _searchController.dispose();
27:     super.dispose();
28:   }
29: 
30:   void _openBrowseDoctors({String? query}) {
31:     final q = query?.trim();
32:     final uri = Uri(
33:       path: AppRoutes.patientBrowseDoctors,
34:       queryParameters: {
35:         if (q != null && q.isNotEmpty) 'q': q,
36:       },
37:     );
38:     context.push(uri.toString());
39:   }
40: 
41:   void _onNavTap(int index) {
42:     setState(() => _navIndex = index);
43: 
44:     switch (index) {
45:       case 0:
46:         context.go(AppRoutes.patientHome);
47:         break;
48:       case 1:
49:         context.go(AppRoutes.patientAppointments);
50:         break;
51:       case 2:
52:         context.go(AppRoutes.patientCommunity);
53:         break;
54:       case 3:
55:         context.go(AppRoutes.patientNearby);
56:         break;
57:       case 4:
58:         context.go(AppRoutes.patientProfile);
59:         break;
60:     }
61:   }
62: 
63:   @override
64:   Widget build(BuildContext context) {
65:     return Scaffold(
66:       backgroundColor: AppColors.background,
67:       body: SafeArea(
68:         child: SingleChildScrollView(
69:           padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
70:           child: Column(
71:             crossAxisAlignment: CrossAxisAlignment.start,
72:             children: [
73:               _TopBar(
74:                 onNotificationsTap: () => context.push(AppRoutes.patientNotifications),
75:               ),
76:               const SizedBox(height: 12),
77:               _SearchBar(
78:                 controller: _searchController,
79:                 onSubmitted: (v) => _openBrowseDoctors(query: v),
80:               ),
81:               const SizedBox(height: 18),
82:               Text('Services', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
83:               const SizedBox(height: 4),
84:               Text(
85:                 'How can we help you today',
86:                 style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
87:               ),
88:               const SizedBox(height: 10),
89:               _ServiceCard(
90:                 title: 'Clinic Booking',
91:                 onTap: () => context.push(AppRoutes.patientSpecializations),
92:               ),
93:               const SizedBox(height: 18),
94:               Text('Popular Doctors', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
95:               const SizedBox(height: 10),
96:               FutureBuilder(
97:                 future: _doctorService.getPopularDoctors(),
98:                 builder: (context, snapshot) {
99:                   final doctors = snapshot.data ?? const [];
100:                   if (snapshot.connectionState == ConnectionState.waiting && doctors.isEmpty) {
101:                     return const SizedBox(
102:                       height: 190,
103:                       child: Center(child: CircularProgressIndicator()),
104:                     );
105:                   }
106: 
107:                   return SizedBox(
108:                     height: 190,
109:                     child: ListView.separated(
110:                       scrollDirection: Axis.horizontal,
111:                       itemBuilder: (context, index) {
112:                         final d = doctors[index];
113:                         final isFav = _favoritedDoctorIds.contains(d.id) || d.isFavorited;
114:                         final doctorAssets = [
115:                           AssetPaths.doctorPhoto1,
116:                           AssetPaths.doctorPhoto2,
117:                           AssetPaths.doctorPhoto3,
118:                         ];
119:                         return DoctorCard(
120:                           imageAsset: doctorAssets[index % doctorAssets.length],
121:                           name: d.fullName,
122:                           specialization: d.specialization,
123:                           rating: d.averageRating,
124:                           reviewsCount: d.totalReviews,
125:                           fee: d.consultationFee,
126:                           location: d.clinicArea,
127:                           isFavorite: isFav,
128:                           onFavoriteToggle: () {
129:                             setState(() {
130:                               if (isFav) {
131:                                 _favoritedDoctorIds.remove(d.id);
132:                               } else {
133:                                 _favoritedDoctorIds.add(d.id);
134:                               }
135:                             });
136:                           },
137:                           onTap: () => context.push('${AppRoutes.patientDoctorProfile}/${d.id}'),
138:                         );
139:                       },
140:                       separatorBuilder: (_, __) => const SizedBox(width: 12),
141:                       itemCount: doctors.length,
142:                     ),
143:                   );
144:                 },
145:               ),
146:               const SizedBox(height: 16),
147:               Text('Community', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
148:               const SizedBox(height: 10),
149:               _CommunityCard(
150:                 onJoinTap: () => context.go(AppRoutes.patientCommunity),
151:               ),
152:             ],
153:           ),
154:         ),
155:       ),
156:       bottomNavigationBar: _PatientBottomNavBar(
157:         currentIndex: _navIndex,
158:         onTap: _onNavTap,
159:       ),
160:     );
161:   }
162: }
163: 
164: class _TopBar extends StatelessWidget {
165:   const _TopBar({required this.onNotificationsTap});
166: 
167:   final VoidCallback onNotificationsTap;
168: 
169:   @override
170:   Widget build(BuildContext context) {
171:     return Row(
172:       children: [
173:         Container(
174:           height: 34,
175:           width: 34,
176:           decoration: BoxDecoration(
177:             color: AppColors.primary100,
178:             borderRadius: BorderRadius.circular(12),
179:           ),
180:           child: const Icon(Icons.health_and_safety, color: AppColors.primary),
181:         ),
182:         const SizedBox(width: 10),
183:         Text('Medicare', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
184:         const Spacer(),
185:         GestureDetector(
186:           onTap: onNotificationsTap,
187:           child: Container(
188:             height: 40,
189:             width: 40,
190:             decoration: const BoxDecoration(
191:               color: AppColors.primary,
192:               shape: BoxShape.circle,
193:             ),
194:             child: const Icon(Icons.notifications_none, color: AppColors.textOnPrimary, size: 22),
195:           ),
196:         ),
197:       ],
198:     );
199:   }
200: }
201: 
202: class _SearchBar extends StatelessWidget {
203:   const _SearchBar({
204:     required this.controller,
205:     required this.onSubmitted,
206:   });
207: 
208:   final TextEditingController controller;
209:   final ValueChanged<String> onSubmitted;
210: 
211:   @override
212:   Widget build(BuildContext context) {
213:     return Container(
214:       decoration: BoxDecoration(
215:         color: AppColors.surface,
216:         borderRadius: BorderRadius.circular(18),
217:       ),
218:       padding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
219:       child: Row(
220:         children: [
221:           const Icon(Icons.search, color: AppColors.textTertiary),
222:           const SizedBox(width: 8),
223:           Expanded(
224:             child: TextField(
225:               controller: controller,
226:               textInputAction: TextInputAction.search,
227:               onSubmitted: onSubmitted,
228:               decoration: InputDecoration(
229:                 hintText: 'Search',
230:                 hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
231:                 border: InputBorder.none,
232:                 isDense: true,
233:               ),
234:             ),
235:           ),
236:           // Voice search removed — no speech_to_text package available
237:         ],
238:       ),
239:     );
240:   }
241: }
242: 
243: class _ServiceCard extends StatelessWidget {
244:   const _ServiceCard({required this.title, required this.onTap});
245: 
246:   final String title;
247:   final VoidCallback onTap;
248: 
249:   @override
250:   Widget build(BuildContext context) {
251:     return InkWell(
252:       onTap: onTap,
253:       borderRadius: BorderRadius.circular(16),
254:       child: Container(
255:         width: double.infinity,
256:         padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
257:         decoration: BoxDecoration(
258:           color: AppColors.surface,
259:           borderRadius: BorderRadius.circular(16),
260:           border: Border.all(color: AppColors.borderLight),
261:         ),
262:         child: Column(
263:           children: [
264:             ClipRRect(
265:               borderRadius: BorderRadius.circular(14),
266:               child: Image.asset(
267:                 AssetPaths.illustrationOnlineDoctor,
268:                 height: 64,
269:                 width: double.infinity,
270:                 fit: BoxFit.cover,
271:               ),
272:             ),
273:             const SizedBox(height: 10),
274:             Text(title, style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.w700)),
275:           ],
276:         ),
277:       ),
278:     );
279:   }
280: }
281: 
282: class _CommunityCard extends StatelessWidget {
283:   const _CommunityCard({required this.onJoinTap});
284: 
285:   final VoidCallback onJoinTap;
286: 
287:   @override
288:   Widget build(BuildContext context) {
289:     return Column(
290:       children: [
291:         Container(
292:           width: double.infinity,
293:           padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
294:           decoration: BoxDecoration(
295:             color: AppColors.surface,
296:             borderRadius: BorderRadius.circular(16),
297:             border: Border.all(color: AppColors.borderLight),
298:           ),
299:           child: ClipRRect(
300:             borderRadius: BorderRadius.circular(14),
301:             child: Image.asset(
302:               AssetPaths.illustrationDoctorsCuate,
303:               height: 160,
304:               width: double.infinity,
305:               fit: BoxFit.cover,
306:             ),
307:           ),
308:         ),
309:         const SizedBox(height: 12),
310:         SizedBox(
311:           height: 52,
312:           width: double.infinity,
313:           child: ElevatedButton(
314:             onPressed: onJoinTap,
315:             child: const Text('Join Our Community'),
316:           ),
317:         ),
318:       ],
319:     );
320:   }
321: }
322: 
323: class _PatientBottomNavBar extends StatelessWidget {
324:   const _PatientBottomNavBar({
325:     required this.currentIndex,
326:     required this.onTap,
327:   });
328: 
329:   final int currentIndex;
330:   final ValueChanged<int> onTap;
331: 
332:   @override
333:   Widget build(BuildContext context) {
334:     const barHeight = 86.0;
335:     const fabSize = 62.0;
336: 
337:     return SizedBox(
338:       height: barHeight + 14,
339:       child: Stack(
340:         alignment: Alignment.bottomCenter,
341:         children: [
342:           Container(
343:             margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
344:             padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
345:             decoration: BoxDecoration(
346:               color: AppColors.primary100,
347:               borderRadius: BorderRadius.circular(18),
348:               boxShadow: [
349:                 BoxShadow(
350:                   color: AppColors.shadow,
351:                   blurRadius: 14,
352:                   offset: const Offset(0, 4),
353:                 ),
354:               ],
355:             ),
356:             child: Row(
357:               children: [
358:                 _NavItem(
359:                   label: 'Home',
360:                   icon: Icons.home_outlined,
361:                   selectedIcon: Icons.home,
362:                   isSelected: currentIndex == 0,
363:                   onTap: () => onTap(0),
364:                 ),
365:                 _NavItem(
366:                   label: 'Appointments',
367:                   icon: Icons.calendar_today_outlined,
368:                   selectedIcon: Icons.calendar_today,
369:                   isSelected: currentIndex == 1,
370:                   onTap: () => onTap(1),
371:                 ),
372:                 const SizedBox(width: fabSize),
373:                 _NavItem(
374:                   label: 'Nearby',
375:                   icon: Icons.location_on_outlined,
376:                   selectedIcon: Icons.location_on,
377:                   isSelected: currentIndex == 3,
378:                   onTap: () => onTap(3),
379:                 ),
380:                 _NavItem(
381:                   label: 'Profile',
382:                   icon: Icons.person_outline,
383:                   selectedIcon: Icons.person,
384:                   isSelected: currentIndex == 4,
385:                   onTap: () => onTap(4),
386:                 ),
387:               ],
388:             ),
389:           ),
390:           Positioned(
391:             bottom: 22,
392:             child: GestureDetector(
393:               onTap: () => onTap(2),
394:               child: Container(
395:                 height: fabSize,
396:                 width: fabSize,
397:                 decoration: BoxDecoration(
398:                   color: AppColors.surface,
399:                   shape: BoxShape.circle,
400:                   boxShadow: [
401:                     BoxShadow(
402:                       color: AppColors.shadow,
403:                       blurRadius: 18,
404:                       offset: const Offset(0, 6),
405:                     ),
406:                   ],
407:                 ),
408:                 alignment: Alignment.center,
409:                 child: Container(
410:                   height: 46,
411:                   width: 46,
412:                   decoration: const BoxDecoration(
413:                     color: AppColors.primary,
414:                     shape: BoxShape.circle,
415:                   ),
416:                   child: const Icon(Icons.smart_toy_outlined, color: AppColors.textOnPrimary, size: 26),
417:                 ),
418:               ),
419:             ),
420:           ),
421:         ],
422:       ),
423:     );
424:   }
425: }
426: 
427: class _NavItem extends StatelessWidget {
428:   const _NavItem({
429:     required this.label,
430:     required this.icon,
431:     required this.selectedIcon,
432:     required this.isSelected,
433:     required this.onTap,
434:   });
435: 
436:   final String label;
437:   final IconData icon;
438:   final IconData selectedIcon;
439:   final bool isSelected;
440:   final VoidCallback onTap;
441: 
442:   @override
443:   Widget build(BuildContext context) {
444:     final fg = isSelected ? AppColors.primary : AppColors.textSecondary;
445:     return Expanded(
446:       child: GestureDetector(
447:         onTap: onTap,
448:         behavior: HitTestBehavior.opaque,
449:         child: Column(
450:           mainAxisSize: MainAxisSize.min,
451:           children: [
452:             Container(
453:               height: 38,
454:               width: double.infinity,
455:               alignment: Alignment.center,
456:               decoration: isSelected
457:                   ? BoxDecoration(
458:                       color: AppColors.surface,
459:                       borderRadius: BorderRadius.circular(12),
460:                     )
461:                   : null,
462:               child: Icon(isSelected ? selectedIcon : icon, color: fg, size: 22),
463:             ),
464:             const SizedBox(height: 6),
465:             Text(
466:               label,
467:               style: AppTextStyles.labelSmall.copyWith(
468:                 color: fg,
469:                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
470:               ),
471:               maxLines: 1,
472:               overflow: TextOverflow.ellipsis,
473:             ),
474:           ],
475:         ),
476:       ),
477:     );
478:   }
479: }

(End of file - total 479 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\doctor\\screens\\doctor_dashboard_screen.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_dashboard_screen.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import 'package:go_router/go_router.dart';
3: 
4: import '../../../core/constants/app_constants.dart';
5: import '../../../core/theme/app_colors.dart';
6: import '../../../core/theme/app_text_styles.dart';
7: import '../../../core/widgets/app_bottom_nav.dart';
8: import '../../doctor/services/doctor_service.dart';
9: 
10: class DoctorDashboardScreen extends StatefulWidget {
11:   const DoctorDashboardScreen({super.key});
12: 
13:   @override
14:   State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
15: }
16: 
17: class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
18:   final _service = DoctorService();
19:   int _navIndex = 0;
20: 
21:   void _onNavTap(int index) {
22:     setState(() => _navIndex = index);
23:     switch (index) {
24:       case 0:
25:         context.go(AppRoutes.doctorDashboard);
26:         break;
27:       case 1:
28:         context.go(AppRoutes.doctorAppointments);
29:         break;
30:       case 2:
31:         context.go(AppRoutes.doctorCommunity);
32:         break;
33:       case 3:
34:         context.go(AppRoutes.doctorProfile);
35:         break;
36:     }
37:   }
38: 
39:   @override
40:   Widget build(BuildContext context) {
41:     return Scaffold(
42:       backgroundColor: AppColors.background,
43:       body: SafeArea(
44:         child: FutureBuilder(
45:           future: _service.getDashboard(),
46:           builder: (context, snapshot) {
47:             if (snapshot.connectionState == ConnectionState.waiting) {
48:               return const Center(child: CircularProgressIndicator());
49:             }
50: 
51:             if (snapshot.hasError || !snapshot.hasData) {
52:               return Center(
53:                 child: Padding(
54:                   padding: const EdgeInsets.all(24),
55:                   child: Column(
56:                     mainAxisAlignment: MainAxisAlignment.center,
57:                     children: [
58:                       const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
59:                       const SizedBox(height: 12),
60:                       Text(
61:                         snapshot.error?.toString() ?? 'Failed to load dashboard',
62:                         style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
63:                         textAlign: TextAlign.center,
64:                       ),
65:                       const SizedBox(height: 16),
66:                       OutlinedButton(
67:                         onPressed: () => setState(() {}),
68:                         child: const Text('Retry'),
69:                       ),
70:                     ],
71:                   ),
72:                 ),
73:               );
74:             }
75: 
76:             final data = snapshot.data!;
77: 
78:             return SingleChildScrollView(
79:               padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
80:               child: Column(
81:                 crossAxisAlignment: CrossAxisAlignment.start,
82:                 children: [
83:                   _TopBar(
84:                     onNotificationsTap: () =>
85:                         context.push(AppRoutes.doctorNotifications),
86:                   ),
87:                   const SizedBox(height: 20),
88:                   _TodayAppointmentsCard(
89:                     total: data['totalAppointments'] as int? ?? 0,
90:                     newPatients: data['newPatientsCount'] as int? ?? 0,
91:                     followUps: data['followUpsCount'] as int? ?? 0,
92:                     walkIns: data['walkInsCount'] as int? ?? 0,
93:                     online: data['onlineCount'] as int? ?? 0,
94:                   ),
95:                   const SizedBox(height: 16),
96:                   _EarningsCard(
97:                     amount: (data['todayEarnings'] as num?)?.toDouble() ?? 0,
98:                   ),
99:                   const SizedBox(height: 16),
100:                   _ScheduleButton(
101:                     onTap: () => context.go(AppRoutes.doctorAppointments),
102:                   ),
103:                   const SizedBox(height: 12),
104:                   SizedBox(
105:                     height: 52,
106:                     width: double.infinity,
107:                     child: OutlinedButton.icon(
108:                       onPressed: () async {
109:                         try {
110:                           final profile = await DoctorService().getProfile();
111:                           if (mounted) {
112:                             context.push(
113:                               AppRoutes.doctorSchedule,
114:                               extra: {'doctorId': profile.id},
115:                             );
116:                           }
117:                         } catch (e) {
118:                           if (mounted) {
119:                             ScaffoldMessenger.of(context).showSnackBar(
120:                               SnackBar(content: Text('Failed to load schedule: $e')),
121:                             );
122:                           }
123:                         }
124:                       },
125:                       icon: const Icon(Icons.edit_calendar, size: 18),
126:                       label: const Text('Manage My Schedule'),
127:                     ),
128:                   ),
129:                   const SizedBox(height: 20),
130:                   Text(
131:                     'Queue Summary',
132:                     style: AppTextStyles.heading2.copyWith(
133:                       color: AppColors.primaryDark,
134:                     ),
135:                   ),
136:                   const SizedBox(height: 12),
137:                   _QueueSummaryCard(
138:                     waiting: data['waitingCount'] as int? ?? 0,
139:                     withDoctor: data['withDoctorCount'] as int? ?? 0,
140:                     completed: data['completedCount'] as int? ?? 0,
141:                   ),
142:                 ],
143:               ),
144:             );
145:           },
146:         ),
147:       ),
148:       bottomNavigationBar: AppBottomNav(
149:         currentIndex: _navIndex,
150:         items: DoctorNavItems.items,
151:         onTap: _onNavTap,
152:       ),
153:     );
154:   }
155: }
156: 
157: class _TopBar extends StatelessWidget {
158:   const _TopBar({required this.onNotificationsTap});
159: 
160:   final VoidCallback onNotificationsTap;
161: 
162:   @override
163:   Widget build(BuildContext context) {
164:     return Row(
165:       children: [
166:         const CircleAvatar(
167:           radius: 20,
168:           backgroundImage: AssetImage(AssetPaths.doctorJulian),
169:         ),
170:         const SizedBox(width: 10),
171:         Text('Medicare', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
172:         const Spacer(),
173:         GestureDetector(
174:           onTap: onNotificationsTap,
175:           child: Container(
176:             height: 40,
177:             width: 40,
178:             decoration: const BoxDecoration(
179:               color: AppColors.primary,
180:               shape: BoxShape.circle,
181:             ),
182:             child: const Icon(Icons.notifications_none, color: AppColors.textOnPrimary, size: 22),
183:           ),
184:         ),
185:       ],
186:     );
187:   }
188: }
189: 
190: class _TodayAppointmentsCard extends StatelessWidget {
191:   final int total;
192:   final int newPatients;
193:   final int followUps;
194:   final int walkIns;
195:   final int online;
196: 
197:   const _TodayAppointmentsCard({
198:     required this.total,
199:     required this.newPatients,
200:     required this.followUps,
201:     required this.walkIns,
202:     required this.online,
203:   });
204: 
205:   @override
206:   Widget build(BuildContext context) {
207:     return Container(
208:       width: double.infinity,
209:       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
210:       decoration: BoxDecoration(
211:         color: AppColors.surface,
212:         borderRadius: BorderRadius.circular(16),
213:         border: Border.all(color: AppColors.borderLight),
214:       ),
215:       child: Column(
216:         crossAxisAlignment: CrossAxisAlignment.start,
217:         children: [
218:           Text('Today\'s Appointments', style: AppTextStyles.labelMedium),
219:           const SizedBox(height: 8),
220:           Text(
221:             total.toString(),
222:             style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
223:           ),
224:           const SizedBox(height: 12),
225:           Row(
226:             children: [
227:               _StatChip(label: 'New Visit', value: newPatients, color: AppColors.primary50, icon: Icons.person_add_alt_1),
228:               const SizedBox(width: 8),
229:               _StatChip(label: 'Follow Up', value: followUps, color: AppColors.successBg, icon: Icons.repeat),
230:             ],
231:           ),
232:           const SizedBox(height: 8),
233:           Row(
234:             children: [
235:               _StatChip(label: 'Walk-in', value: walkIns, color: AppColors.warningBg, icon: Icons.directions_walk),
236:               const SizedBox(width: 8),
237:               _StatChip(label: 'Online', value: online, color: AppColors.infoBg, icon: Icons.videocam_outlined),
238:             ],
239:           ),
240:         ],
241:       ),
242:     );
243:   }
244: }
245: 
246: class _StatChip extends StatelessWidget {
247:   final String label;
248:   final int value;
249:   final Color color;
250:   final IconData icon;
251: 
252:   const _StatChip({required this.label, required this.value, required this.color, required this.icon});
253: 
254:   @override
255:   Widget build(BuildContext context) {
256:     return Expanded(
257:       child: Container(
258:         padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
259:         decoration: BoxDecoration(
260:           color: color,
261:           borderRadius: BorderRadius.circular(12),
262:         ),
263:         child: Column(
264:           crossAxisAlignment: CrossAxisAlignment.start,
265:           children: [
266:             Icon(icon, size: 18, color: AppColors.primary),
267:             const SizedBox(height: 8),
268:             Text(
269:               value.toString(),
270:               style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
271:             ),
272:             const SizedBox(height: 2),
273:             Text(
274:               label,
275:               style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
276:             ),
277:           ],
278:         ),
279:       ),
280:     );
281:   }
282: }
283: 
284: class _EarningsCard extends StatelessWidget {
285:   final double amount;
286: 
287:   const _EarningsCard({required this.amount});
288: 
289:   @override
290:   Widget build(BuildContext context) {
291:     return Container(
292:       width: double.infinity,
293:       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
294:       decoration: BoxDecoration(
295:         color: AppColors.surface,
296:         borderRadius: BorderRadius.circular(16),
297:         border: Border.all(color: AppColors.borderLight),
298:       ),
299:       child: Row(
300:         children: [
301:           Column(
302:             crossAxisAlignment: CrossAxisAlignment.start,
303:             children: [
304:               Text('Earnings', style: AppTextStyles.labelMedium),
305:               const SizedBox(height: 4),
306:               Text(
307:                 '\$${amount.toStringAsFixed(0)}',
308:                 style: AppTextStyles.heading1.copyWith(color: AppColors.primaryDark),
309:               ),
310:             ],
311:           ),
312:           const Spacer(),
313:           Container(
314:             height: 44,
315:             width: 44,
316:             decoration: BoxDecoration(
317:               color: AppColors.primary50,
318:               borderRadius: BorderRadius.circular(12),
319:             ),
320:             child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
321:           ),
322:         ],
323:       ),
324:     );
325:   }
326: }
327: 
328: class _ScheduleButton extends StatelessWidget {
329:   final VoidCallback onTap;
330: 
331:   const _ScheduleButton({required this.onTap});
332: 
333:   @override
334:   Widget build(BuildContext context) {
335:     return SizedBox(
336:       height: 52,
337:       width: double.infinity,
338:       child: ElevatedButton.icon(
339:         onPressed: onTap,
340:         icon: const Icon(Icons.calendar_today, size: 18),
341:         label: const Text('View Today\'s Schedule'),
342:       ),
343:     );
344:   }
345: }
346: 
347: class _QueueSummaryCard extends StatelessWidget {
348:   final int waiting;
349:   final int withDoctor;
350:   final int completed;
351: 
352:   const _QueueSummaryCard({
353:     required this.waiting,
354:     required this.withDoctor,
355:     required this.completed,
356:   });
357: 
358:   @override
359:   Widget build(BuildContext context) {
360:     return Container(
361:       width: double.infinity,
362:       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
363:       decoration: BoxDecoration(
364:         color: AppColors.surface,
365:         borderRadius: BorderRadius.circular(16),
366:         border: Border.all(color: AppColors.borderLight),
367:       ),
368:       child: Column(
369:         children: [
370:           _QueueRow(
371:             label: 'Waiting',
372:             value: waiting,
373:             color: AppColors.warning,
374:             bgColor: AppColors.warningBg,
375:             icon: Icons.hourglass_top,
376:           ),
377:           const Divider(height: 16),
378:           _QueueRow(
379:             label: 'With Doctor',
380:             value: withDoctor,
381:             color: AppColors.primary,
382:             bgColor: AppColors.primary50,
383:             icon: Icons.local_hospital,
384:           ),
385:           const Divider(height: 16),
386:           _QueueRow(
387:             label: 'Completed',
388:             value: completed,
389:             color: AppColors.success,
390:             bgColor: AppColors.successBg,
391:             icon: Icons.check_circle,
392:           ),
393:         ],
394:       ),
395:     );
396:   }
397: }
398: 
399: class _QueueRow extends StatelessWidget {
400:   final String label;
401:   final int value;
402:   final Color color;
403:   final Color bgColor;
404:   final IconData icon;
405: 
406:   const _QueueRow({
407:     required this.label,
408:     required this.value,
409:     required this.color,
410:     required this.bgColor,
411:     required this.icon,
412:   });
413: 
414:   @override
415:   Widget build(BuildContext context) {
416:     return Row(
417:       children: [
418:         Container(
419:           height: 36,
420:           width: 36,
421:           decoration: BoxDecoration(
422:             color: bgColor,
423:             borderRadius: BorderRadius.circular(10),
424:           ),
425:           child: Icon(icon, color: color, size: 18),
426:         ),
427:         const SizedBox(width: 12),
428:         Text(label, style: AppTextStyles.bodyLarge),
429:         const Spacer(),
430:         Container(
431:           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
432:           decoration: BoxDecoration(
433:             color: bgColor,
434:             borderRadius: BorderRadius.circular(20),
435:           ),
436:           child: Text(
437:             value.toString(),
438:             style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.w700),
439:           ),
440:         ),
441:       ],
442:     );
443:   }
444: }

(End of file - total 444 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\clinic\\screens\\clinic_dashboard_screen.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_dashboard_screen.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import 'package:go_router/go_router.dart';
3: import '../../../core/constants/app_constants.dart';
4: import '../../../core/theme/app_colors.dart';
5: import '../../../core/theme/app_text_styles.dart';
6: import '../../../core/widgets/app_bottom_nav.dart';
7: import '../../clinic/clinic_service.dart';
8: 
9: class ClinicDashboardScreen extends StatefulWidget {
10:   const ClinicDashboardScreen({super.key});
11: 
12:   @override
13:   State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
14: }
15: 
16: class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
17:   final _service = ClinicService();
18:   Map<String, dynamic>? _dashboardData;
19:   bool _isLoading = true;
20:   String? _error;
21: 
22:   @override
23:   void initState() {
24:     super.initState();
25:     _loadDashboard();
26:   }
27: 
28:   Future<void> _loadDashboard() async {
29:     try {
30:       setState(() {
31:         _isLoading = true;
32:         _error = null;
33:       });
34:       final data = await _service.getClinicDashboard();
35:       setState(() {
36:         _dashboardData = data;
37:         _isLoading = false;
38:       });
39:     } catch (e) {
40:       setState(() {
41:         _error = e.toString();
42:         _isLoading = false;
43:       });
44:     }
45:   }
46: 
47:   void _onNavTap(int index) {
48:     switch (index) {
49:       case 0:
50:         context.go(AppRoutes.clinicDashboard);
51:         break;
52:       case 1:
53:         context.go(AppRoutes.clinicDoctors);
54:         break;
55:       case 2:
56:         context.go(AppRoutes.clinicPayments);
57:         break;
58:       case 3:
59:         context.go(AppRoutes.clinicProfile);
60:         break;
61:     }
62:   }
63: 
64:   @override
65:   Widget build(BuildContext context) {
66:     final todayStats = _dashboardData?['todayStats'] as Map<String, dynamic>? ?? {};
67:     final queueSummary = _dashboardData?['queueSummary'] as Map<String, dynamic>? ?? {};
68:     final recentAppointments = (_dashboardData?['recentAppointments'] as List<dynamic>?) ?? [];
69: 
70:     return Scaffold(
71:       backgroundColor: AppColors.background,
72:       body: SafeArea(
73:         child: RefreshIndicator(
74:           onRefresh: _loadDashboard,
75:           child: SingleChildScrollView(
76:             physics: const AlwaysScrollableScrollPhysics(),
77:             padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
78:             child: Column(
79:               crossAxisAlignment: CrossAxisAlignment.start,
80:               children: [
81:                 _buildHeader(),
82:                 const SizedBox(height: 20),
83:                 _buildDateSelector(),
84:                 const SizedBox(height: 20),
85:                 _buildStatsCards(todayStats),
86:                 const SizedBox(height: 24),
87:                 _buildQuickActions(),
88:                 const SizedBox(height: 24),
89:                 _buildQueueSummary(queueSummary),
90:                 const SizedBox(height: 24),
91:                 _buildRecentAppointments(recentAppointments),
92:               ],
93:             ),
94:           ),
95:         ),
96:       ),
97:       bottomNavigationBar: AppBottomNav(
98:         currentIndex: 0,
99:         items: ClinicNavItems.items,
100:         onTap: _onNavTap,
101:       ),
102:     );
103:   }
104: 
105:   Widget _buildHeader() {
106:     return Row(
107:       children: [
108:         ClipRRect(
109:           borderRadius: BorderRadius.circular(14),
110:           child: Image.asset(
111:             AssetPaths.clinicImage1,
112:             width: 48,
113:             height: 48,
114:             fit: BoxFit.cover,
115:           ),
116:         ),
117:         const SizedBox(width: 12),
118:         Expanded(
119:           child: Column(
120:             crossAxisAlignment: CrossAxisAlignment.start,
121:             children: [
122:               Text('Clinic', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
123:               Text(
124:                 'Dashboard',
125:                 style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
126:               ),
127:             ],
128:           ),
129:         ),
130:         GestureDetector(
131:           onTap: () => context.push(AppRoutes.clinicNotifications),
132:           child: Container(
133:             height: 44,
134:             width: 44,
135:             decoration: BoxDecoration(
136:               color: AppColors.surface,
137:               borderRadius: BorderRadius.circular(12),
138:               border: Border.all(color: AppColors.borderLight),
139:             ),
140:             child: const Icon(Icons.notifications_none, color: AppColors.primary, size: 22),
141:           ),
142:         ),
143:       ],
144:     );
145:   }
146: 
147:   Widget _buildDateSelector() {
148:     final now = DateTime.now();
149:     final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';
150: 
151:     return Container(
152:       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
153:       decoration: BoxDecoration(
154:         color: AppColors.primary,
155:         borderRadius: BorderRadius.circular(16),
156:       ),
157:       child: Row(
158:         children: [
159:           const Icon(Icons.calendar_today, color: AppColors.textOnPrimary, size: 20),
160:           const SizedBox(width: 12),
161:           Expanded(
162:             child: Column(
163:               crossAxisAlignment: CrossAxisAlignment.start,
164:               children: [
165:                 Text(
166:                   dateStr,
167:                   style: AppTextStyles.bodyLarge.copyWith(
168:                     color: AppColors.textOnPrimary,
169:                     fontWeight: FontWeight.w600,
170:                   ),
171:                 ),
172:                 Text(
173:                   'Today\'s Overview',
174:                   style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary100),
175:                 ),
176:               ],
177:             ),
178:           ),
179:           Container(
180:             padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
181:             decoration: BoxDecoration(
182:               color: AppColors.primaryDark,
183:               borderRadius: BorderRadius.circular(20),
184:             ),
185:             child: Text(
186:               'Live',
187:               style: AppTextStyles.labelMedium.copyWith(color: AppColors.textOnPrimary),
188:             ),
189:           ),
190:         ],
191:       ),
192:     );
193:   }
194: 
195:   Widget _buildStatsCards(Map<String, dynamic> stats) {
196:     final paidCount = stats['paidCount'] ?? 0;
197:     final walkIns = stats['walkIns'] ?? 0;
198:     final revenue = stats['revenue'] ?? 0.0;
199: 
200:     return Row(
201:       children: [
202:         Expanded(
203:           child: _StatCard(
204:             icon: Icons.people_alt_outlined,
205:             iconColor: AppColors.primary,
206:             iconBg: AppColors.primary100,
207:             value: paidCount.toString(),
208:             label: 'Paid Patients',
209:           ),
210:         ),
211:         const SizedBox(width: 12),
212:         Expanded(
213:           child: _StatCard(
214:             icon: Icons.person_add_alt_outlined,
215:             iconColor: AppColors.success,
216:             iconBg: AppColors.successBg,
217:             value: walkIns.toString(),
218:             label: 'Walk-ins',
219:           ),
220:         ),
221:         const SizedBox(width: 12),
222:         Expanded(
223:           child: _StatCard(
224:             icon: Icons.attach_money,
225:             iconColor: AppColors.warning,
226:             iconBg: AppColors.warningBg,
227:             value: '\$${(revenue as num).toStringAsFixed(0)}',
228:             label: 'Revenue',
229:           ),
230:         ),
231:       ],
232:     );
233:   }
234: 
235:   Widget _buildQuickActions() {
236:     return Column(
237:       crossAxisAlignment: CrossAxisAlignment.start,
238:       children: [
239:         Text('Quick Actions', style: AppTextStyles.heading2),
240:         const SizedBox(height: 12),
241:         Row(
242:           children: [
243:             Expanded(
244:               child: _ActionButton(
245:                 icon: Icons.person_add,
246:                 label: 'Add Walk-in',
247:                 color: AppColors.primary,
248:                 onTap: () => context.push(AppRoutes.clinicWalkInBooking),
249:               ),
250:             ),
251:             const SizedBox(width: 12),
252:             Expanded(
253:               child: _ActionButton(
254:                 icon: Icons.queue_play_next,
255:                 label: 'View Queue',
256:                 color: AppColors.success,
257:                 onTap: () => context.push(AppRoutes.clinicQueue),
258:               ),
259:             ),
260:           ],
261:         ),
262:       ],
263:     );
264:   }
265: 
266:   Widget _buildQueueSummary(Map<String, dynamic> summary) {
267:     final totalWaiting = summary['totalWaiting'] ?? 0;
268:     final totalInProgress = summary['totalInProgress'] ?? 0;
269:     final totalCompleted = summary['totalCompleted'] ?? 0;
270: 
271:     return Container(
272:       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
273:       decoration: BoxDecoration(
274:         color: AppColors.surface,
275:         borderRadius: BorderRadius.circular(16),
276:         border: Border.all(color: AppColors.borderLight),
277:       ),
278:       child: Column(
279:         crossAxisAlignment: CrossAxisAlignment.start,
280:         children: [
281:           Row(
282:             mainAxisAlignment: MainAxisAlignment.spaceBetween,
283:             children: [
284:               Text('Queue Summary', style: AppTextStyles.heading2),
285:               TextButton(
286:                 onPressed: () => context.push(AppRoutes.clinicQueue),
287:                 child: const Text('See All'),
288:               ),
289:             ],
290:           ),
291:           const SizedBox(height: 12),
292:           Row(
293:             children: [
294:               Expanded(
295:                 child: _QueueStatusItem(
296:                   count: totalWaiting.toString(),
297:                   label: 'Waiting',
298:                   color: AppColors.warning,
299:                 ),
300:               ),
301:               Expanded(
302:                 child: _QueueStatusItem(
303:                   count: totalInProgress.toString(),
304:                   label: 'In Progress',
305:                   color: AppColors.primary,
306:                 ),
307:               ),
308:               Expanded(
309:                 child: _QueueStatusItem(
310:                   count: totalCompleted.toString(),
311:                   label: 'Completed',
312:                   color: AppColors.success,
313:                 ),
314:               ),
315:             ],
316:           ),
317:         ],
318:       ),
319:     );
320:   }
321: 
322:   Widget _buildRecentAppointments(List<dynamic> appointments) {
323:     return Column(
324:       crossAxisAlignment: CrossAxisAlignment.start,
325:       children: [
326:         Text('Recent Appointments', style: AppTextStyles.heading2),
327:         const SizedBox(height: 12),
328:         if (_isLoading)
329:           const SizedBox(
330:             height: 120,
331:             child: Center(child: CircularProgressIndicator()),
332:           )
333:         else if (_error != null)
334:           Center(
335:             child: Column(
336:               children: [
337:                 Text('Error: $_error', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
338:                 const SizedBox(height: 8),
339:                 TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
340:               ],
341:             ),
342:           )
343:         else if (appointments.isEmpty)
344:           Container(
345:             padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
346:             decoration: BoxDecoration(
347:               color: AppColors.surface,
348:               borderRadius: BorderRadius.circular(16),
349:             ),
350:             child: Center(
351:               child: Text(
352:                 'No appointments today',
353:                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
354:               ),
355:             ),
356:           )
357:         else
358:           ListView.separated(
359:             shrinkWrap: true,
360:             physics: const NeverScrollableScrollPhysics(),
361:             itemCount: appointments.length.clamp(0, 5),
362:             separatorBuilder: (_, __) => const SizedBox(height: 10),
363:             itemBuilder: (context, index) {
364:               final appt = appointments[index] as Map<String, dynamic>;
365:               return _AppointmentListItem(
366:                 patientName: appt['patientName'] ?? '',
367:                 doctorName: appt['doctorName'] ?? '',
368:                 time: appt['startTime'] ?? '--:--',
369:                 status: appt['statusText'] ?? '',
370:                 isPaid: appt['isPaid'] ?? false,
371:               );
372:             },
373:           ),
374:       ],
375:     );
376:   }
377: 
378:   String _monthName(int month) {
379:     const names = [
380:       'January', 'February', 'March', 'April', 'May', 'June',
381:       'July', 'August', 'September', 'October', 'November', 'December'
382:     ];
383:     return names[month - 1];
384:   }
385: }
386: 
387: class _StatCard extends StatelessWidget {
388:   final IconData icon;
389:   final Color iconColor;
390:   final Color iconBg;
391:   final String value;
392:   final String label;
393: 
394:   const _StatCard({
395:     required this.icon,
396:     required this.iconColor,
397:     required this.iconBg,
398:     required this.value,
399:     required this.label,
400:   });
401: 
402:   @override
403:   Widget build(BuildContext context) {
404:     return Container(
405:       padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
406:       decoration: BoxDecoration(
407:         color: AppColors.surface,
408:         borderRadius: BorderRadius.circular(16),
409:         border: Border.all(color: AppColors.borderLight),
410:       ),
411:       child: Column(
412:         crossAxisAlignment: CrossAxisAlignment.start,
413:         children: [
414:           Container(
415:             height: 36,
416:             width: 36,
417:             decoration: BoxDecoration(
418:               color: iconBg,
419:               borderRadius: BorderRadius.circular(10),
420:             ),
421:             child: Icon(icon, color: iconColor, size: 18),
422:           ),
423:           const SizedBox(height: 10),
424:           Text(value, style: AppTextStyles.heading1.copyWith(fontSize: 22)),
425:           const SizedBox(height: 4),
426:           Text(label, style: AppTextStyles.bodySmall),
427:         ],
428:       ),
429:     );
430:   }
431: }
432: 
433: class _ActionButton extends StatelessWidget {
434:   final IconData icon;
435:   final String label;
436:   final Color color;
437:   final VoidCallback onTap;
438: 
439:   const _ActionButton({
440:     required this.icon,
441:     required this.label,
442:     required this.color,
443:     required this.onTap,
444:   });
445: 
446:   @override
447:   Widget build(BuildContext context) {
448:     return InkWell(
449:       onTap: onTap,
450:       borderRadius: BorderRadius.circular(14),
451:       child: Container(
452:         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
453:         decoration: BoxDecoration(
454:           color: AppColors.surface,
455:           borderRadius: BorderRadius.circular(14),
456:           border: Border.all(color: AppColors.borderLight),
457:         ),
458:         child: Row(
459:           children: [
460:             Container(
461:               height: 40,
462:               width: 40,
463:               decoration: BoxDecoration(
464:                 color: color.withOpacity(0.1),
465:                 borderRadius: BorderRadius.circular(10),
466:               ),
467:               child: Icon(icon, color: color, size: 20),
468:             ),
469:             const SizedBox(width: 12),
470:             Expanded(
471:               child: Text(
472:                 label,
473:                 style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
474:               ),
475:             ),
476:             Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary, size: 14),
477:           ],
478:         ),
479:       ),
480:     );
481:   }
482: }
483: 
484: class _QueueStatusItem extends StatelessWidget {
485:   final String count;
486:   final String label;
487:   final Color color;
488: 
489:   const _QueueStatusItem({
490:     required this.count,
491:     required this.label,
492:     required this.color,
493:   });
494: 
495:   @override
496:   Widget build(BuildContext context) {
497:     return Column(
498:       children: [
499:         Text(count, style: AppTextStyles.heading1.copyWith(color: color, fontSize: 24)),
500:         const SizedBox(height: 4),
501:         Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
502:       ],
503:     );
504:   }
505: }
506: 
507: class _AppointmentListItem extends StatelessWidget {
508:   final String patientName;
509:   final String doctorName;
510:   final String time;
511:   final String status;
512:   final bool isPaid;
513: 
514:   const _AppointmentListItem({
515:     required this.patientName,
516:     required this.doctorName,
517:     required this.time,
518:     required this.status,
519:     required this.isPaid,
520:   });
521: 
522:   @override
523:   Widget build(BuildContext context) {
524:     Color statusColor;
525:     switch (status.toLowerCase()) {
526:       case 'completed':
527:         statusColor = AppColors.success;
528:         break;
529:       case 'in progress':
530:         statusColor = AppColors.primary;
531:         break;
532:       case 'cancelled':
533:         statusColor = AppColors.error;
534:         break;
535:       default:
536:         statusColor = AppColors.warning;
537:     }
538: 
539:     return Container(
540:       padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
541:       decoration: BoxDecoration(
542:         color: AppColors.surface,
543:         borderRadius: BorderRadius.circular(14),
544:         border: Border.all(color: AppColors.borderLight),
545:       ),
546:       child: Row(
547:         children: [
548:           const CircleAvatar(
549:             radius: 22,
550:             backgroundImage: AssetImage(AssetPaths.patientProfile1),
551:           ),
552:           const SizedBox(width: 12),
553:           Expanded(
554:             child: Column(
555:               crossAxisAlignment: CrossAxisAlignment.start,
556:               children: [
557:                 Text(patientName, style: AppTextStyles.labelLarge),
558:                 const SizedBox(height: 2),
559:                 Text(
560:                   'Dr. $doctorName · $time',
561:                   style: AppTextStyles.bodySmall,
562:                 ),
563:               ],
564:             ),
565:           ),
566:           Column(
567:             crossAxisAlignment: CrossAxisAlignment.end,
568:             children: [
569:               Container(
570:                 padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
571:                 decoration: BoxDecoration(
572:                   color: statusColor.withOpacity(0.1),
573:                   borderRadius: BorderRadius.circular(20),
574:                 ),
575:                 child: Text(
576:                   status,
577:                   style: AppTextStyles.labelSmall.copyWith(color: statusColor),
578:                 ),
579:               ),
580:               const SizedBox(height: 4),
581:               if (isPaid)
582:                 Text(
583:                   'Paid',
584:                   style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
585:                 )
586:               else
587:                 Text(
588:                   'Unpaid',
589:                   style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
590:                 ),
591:             ],
592:           ),
593:         ],
594:       ),
595:     );
596:   }
597: }

(End of file - total 597 lines)
</content>
```

---

## Assistant (Sisyphus - Ultraworker · Kimi K2.6 · 29.1s)

**Tool: grep**

**Input:**
```json
{
  "pattern": "bottomNavigationBar",
  "path": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib",
  "output_mode": "content"
}
```

**Output:**
```
Found 17 match(es) in 17 file(s)

C:\Users\Zowail\StudioProjects\medicare\lib\core\theme\app_theme.dart
  42: bottomNavigationBarTheme: BottomNavigationBarThemeData(

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_queue_screen.dart
  185: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_profile_screen.dart
  222: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_notifications_screen.dart
  146: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_dashboard_screen.dart
  148: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_community_screen.dart
  122: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_appointments_screen.dart
  248: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\home\patient_home_screen.dart
  156: bottomNavigationBar: _PatientBottomNavBar(

C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_doctors_screen.dart
  111: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\community_feed_screen.dart
  247: bottomNavigationBar: _CommunityBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_dashboard_screen.dart
  97: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_queue_screen.dart
  126: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_profile_screen.dart
  223: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\clinic\screens\clinic_payments_screen.dart
  130: bottomNavigationBar: AppBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\patient_profile_screen.dart
  255: bottomNavigationBar: _ProfileBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\my_appointments_screen.dart
  141: bottomNavigationBar: _AppointmentsBottomNav(

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\nearby\nearby_screen.dart
  351: bottomNavigationBar: _NearbyBottomNav(

```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\appointments\\my_appointments_screen.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\appointments\my_appointments_screen.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import 'package:go_router/go_router.dart';
3: import 'package:intl/intl.dart';
4: 
5: import '../../../core/constants/app_constants.dart';
6: import '../../../core/models/appointment_models.dart';
7: import '../../../core/theme/app_colors.dart';
8: import '../../../core/theme/app_text_styles.dart';
9: import '../../../core/widgets/app_button.dart';
10: import '../services/patient_appointments_service.dart';
11: 
12: class MyAppointmentsScreen extends StatefulWidget {
13:   const MyAppointmentsScreen({super.key});
14: 
15:   @override
16:   State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
17: }
18: 
19: class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
20:     with SingleTickerProviderStateMixin {
21:   final _service = PatientAppointmentsService();
22:   late TabController _tabController;
23: 
24:   bool _loading = true;
25:   List<Appointment> _appointments = [];
26: 
27:   @override
28:   void initState() {
29:     super.initState();
30:     _tabController = TabController(length: 3, vsync: this);
31:     _tabController.addListener(_onTabChanged);
32:     _loadAppointments();
33:   }
34: 
35:   @override
36:   void dispose() {
37:     _tabController.removeListener(_onTabChanged);
38:     _tabController.dispose();
39:     super.dispose();
40:   }
41: 
42:   void _onTabChanged() {
43:     if (_tabController.indexIsChanging) {
44:       _loadAppointments();
45:     }
46:   }
47: 
48:   Future<void> _loadAppointments() async {
49:     setState(() => _loading = true);
50: 
51:     String? filter;
52:     switch (_tabController.index) {
53:       case 0:
54:         filter = 'upcoming';
55:         break;
56:       case 1:
57:         filter = 'completed';
58:         break;
59:       case 2:
60:         filter = 'cancelled';
61:         break;
62:     }
63: 
64:     try {
65:       final appointments = await _service.getMyAppointments(filter: filter);
66:       if (!mounted) return;
67:       setState(() {
68:         _appointments = appointments;
69:         _loading = false;
70:       });
71:     } catch (e) {
72:       if (!mounted) return;
73:       setState(() {
74:         _appointments = [];
75:         _loading = false;
76:       });
77:       if (context.mounted) {
78:         ScaffoldMessenger.of(context).showSnackBar(
79:           const SnackBar(content: Text('Failed to load appointments. Please try again.')),
80:         );
81:       }
82:     }
83:   }
84: 
85:   void _onNavTap(int index) {
86:     switch (index) {
87:       case 0:
88:         context.go(AppRoutes.patientHome);
89:         break;
90:       case 1:
91:         // Already on appointments
92:         break;
93:       case 2:
94:         context.go(AppRoutes.patientCommunity);
95:         break;
96:       case 3:
97:         context.go(AppRoutes.patientBrowseDoctors);
98:         break;
99:       case 4:
100:         context.go(AppRoutes.patientProfile);
101:         break;
102:     }
103:   }
104: 
105:   @override
106:   Widget build(BuildContext context) {
107:     return Scaffold(
108:       backgroundColor: AppColors.background,
109:       appBar: AppBar(
110:         title: const Text('My Appointments'),
111:         bottom: TabBar(
112:           controller: _tabController,
113:           tabs: const [
114:             Tab(text: 'Upcoming'),
115:             Tab(text: 'Completed'),
116:             Tab(text: 'Cancelled'),
117:           ],
118:         ),
119:       ),
120:       body: Column(
121:         children: [
122:           Expanded(
123:             child: TabBarView(
124:               controller: _tabController,
125:               children: [
126:                 _buildTabContent('upcoming'),
127:                 _buildTabContent('completed'),
128:                 _buildTabContent('cancelled'),
129:               ],
130:             ),
131:           ),
132:           Padding(
133:             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
134:             child: AppButton(
135:               text: 'Book New Appointment',
136:               onPressed: () => context.push(AppRoutes.patientSpecializations),
137:             ),
138:           ),
139:         ],
140:       ),
141:       bottomNavigationBar: _AppointmentsBottomNav(
142:         currentIndex: 1,
143:         onTap: _onNavTap,
144:       ),
145:     );
146:   }
147: 
148:   Widget _buildTabContent(String filter) {
149:     if (_loading) {
150:       return const Center(child: CircularProgressIndicator());
151:     }
152: 
153:     final filtered = _appointments.where((a) {
154:       if (filter == 'upcoming') {
155:         return a.status == AppEnums.pending || a.status == AppEnums.confirmed || a.status == AppEnums.inProgress;
156:       } else if (filter == 'completed') {
157:         return a.status == AppEnums.completed;
158:       } else {
159:         return a.status == AppEnums.cancelled || a.status == AppEnums.noShow;
160:       }
161:     }).toList();
162: 
163:     if (filtered.isEmpty) {
164:       return _EmptyState(filter: filter);
165:     }
166: 
167:     return RefreshIndicator(
168:       onRefresh: _loadAppointments,
169:       child: ListView.separated(
170:         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
171:         itemCount: filtered.length,
172:         separatorBuilder: (_, __) => const SizedBox(height: 12),
173:         itemBuilder: (context, index) {
174:           final appointment = filtered[index];
175:           return _AppointmentCard(
176:             appointment: appointment,
177:             onTap: () => context.push('${AppRoutes.patientAppointmentDetail}/${appointment.id}'),
178:           );
179:         },
180:       ),
181:     );
182:   }
183: }
184: 
185: class _AppointmentCard extends StatelessWidget {
186:   final Appointment appointment;
187:   final VoidCallback? onTap;
188: 
189:   const _AppointmentCard({required this.appointment, this.onTap});
190: 
191:   @override
192:   Widget build(BuildContext context) {
193:     return GestureDetector(
194:       onTap: onTap,
195:       child: Container(
196:         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
197:         decoration: BoxDecoration(
198:           color: AppColors.surface,
199:           borderRadius: BorderRadius.circular(16),
200:           border: Border.all(color: AppColors.borderLight),
201:         ),
202:         child: Column(
203:           crossAxisAlignment: CrossAxisAlignment.start,
204:           children: [
205:             Row(
206:               children: [
207:                 CircleAvatar(
208:                   radius: 24,
209:                   backgroundColor: AppColors.primary100,
210:                   backgroundImage: AssetImage(
211:                     [
212:                       AssetPaths.doctorPhoto1,
213:                       AssetPaths.doctorPhoto2,
214:                       AssetPaths.doctorPhoto3,
215:                       AssetPaths.doctorPhoto4,
216:                     ][(appointment.doctorId - 1) % 4],
217:                   ),
218:                 ),
219:                 const SizedBox(width: 12),
220:                 Expanded(
221:                   child: Column(
222:                     crossAxisAlignment: CrossAxisAlignment.start,
223:                     children: [
224:                       Text(
225:                         appointment.doctorName,
226:                         style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
227:                         maxLines: 1,
228:                         overflow: TextOverflow.ellipsis,
229:                       ),
230:                       const SizedBox(height: 2),
231:                       Text(
232:                         appointment.specialization,
233:                         style: AppTextStyles.bodySmall,
234:                       ),
235:                     ],
236:                   ),
237:                 ),
238:                 _StatusBadge(status: appointment.status, statusText: appointment.statusText),
239:               ],
240:             ),
241:             const Divider(height: 20),
242:             Row(
243:               children: [
244:                 const Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
245:                 const SizedBox(width: 6),
246:                 Text(
247:                   DateFormat('MMM d, yyyy').format(appointment.appointmentDate),
248:                   style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
249:                 ),
250:                 const SizedBox(width: 16),
251:                 const Icon(Icons.access_time, size: 16, color: AppColors.textTertiary),
252:                 const SizedBox(width: 6),
253:                 Text(
254:                   appointment.startTime,
255:                   style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
256:                 ),
257:               ],
258:             ),
259:             if (appointment.queueNumber != null) ...[
260:               const SizedBox(height: 8),
261:               Row(
262:                 children: [
263:                   const Icon(Icons.confirmation_number, size: 16, color: AppColors.textTertiary),
264:                   const SizedBox(width: 6),
265:                   Text(
266:                     'Queue #${appointment.queueNumber}',
267:                     style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
268:                   ),
269:                 ],
270:               ),
271:             ],
272:           ],
273:         ),
274:       ),
275:     );
276:   }
277: }
278: 
279: class _StatusBadge extends StatelessWidget {
280:   final int status;
281:   final String statusText;
282: 
283:   const _StatusBadge({required this.status, required this.statusText});
284: 
285:   Color get _bgColor {
286:     switch (status) {
287:       case AppEnums.pending:
288:         return AppColors.warningBg;
289:       case AppEnums.confirmed:
290:         return AppColors.infoBg;
291:       case AppEnums.inProgress:
292:         return AppColors.primary100;
293:       case AppEnums.completed:
294:         return AppColors.successBg;
295:       case AppEnums.cancelled:
296:         return AppColors.errorBg;
297:       default:
298:         return AppColors.surfaceVariant;
299:     }
300:   }
301: 
302:   Color get _fgColor {
303:     switch (status) {
304:       case AppEnums.pending:
305:         return AppColors.warning;
306:       case AppEnums.confirmed:
307:         return AppColors.info;
308:       case AppEnums.inProgress:
309:         return AppColors.primary;
310:       case AppEnums.completed:
311:         return AppColors.success;
312:       case AppEnums.cancelled:
313:         return AppColors.error;
314:       default:
315:         return AppColors.textSecondary;
316:     }
317:   }
318: 
319:   @override
320:   Widget build(BuildContext context) {
321:     return Container(
322:       padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
323:       decoration: BoxDecoration(
324:         color: _bgColor,
325:         borderRadius: BorderRadius.circular(20),
326:       ),
327:       child: Text(
328:         statusText,
329:         style: AppTextStyles.labelSmall.copyWith(
330:           color: _fgColor,
331:           fontWeight: FontWeight.w600,
332:         ),
333:       ),
334:     );
335:   }
336: }
337: 
338: class _EmptyState extends StatelessWidget {
339:   final String filter;
340:   const _EmptyState({required this.filter});
341: 
342:   @override
343:   Widget build(BuildContext context) {
344:     return Center(
345:       child: Padding(
346:         padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
347:         child: Column(
348:           mainAxisAlignment: MainAxisAlignment.center,
349:           children: [
350:             ClipRRect(
351:               borderRadius: BorderRadius.circular(24),
352:               child: Image.asset(
353:                 AssetPaths.emptyAppointments,
354:                 height: 120,
355:                 width: 120,
356:                 fit: BoxFit.cover,
357:               ),
358:             ),
359:             const SizedBox(height: 20),
360:             Text(
361:               'No ${filter} appointments',
362:               style: AppTextStyles.heading3,
363:               textAlign: TextAlign.center,
364:             ),
365:             const SizedBox(height: 8),
366:             Text(
367:               'You don\'t have any ${filter} appointments at the moment.',
368:               style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
369:               textAlign: TextAlign.center,
370:             ),
371:           ],
372:         ),
373:       ),
374:     );
375:   }
376: }
377: 
378: class _AppointmentsBottomNav extends StatelessWidget {
379:   final int currentIndex;
380:   final Function(int) onTap;
381: 
382:   const _AppointmentsBottomNav({
383:     required this.currentIndex,
384:     required this.onTap,
385:   });
386: 
387:   @override
388:   Widget build(BuildContext context) {
389:     const items = [
390:       _NavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
391:       _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today, label: 'Appointments'),
392:       _NavItemData(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'AI Bot'),
393:       _NavItemData(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'Nearby'),
394:       _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
395:     ];
396: 
397:     return Container(
398:       decoration: BoxDecoration(
399:         color: AppColors.surface,
400:         boxShadow: [
401:           BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, -2)),
402:         ],
403:       ),
404:       child: SafeArea(
405:         child: Padding(
406:           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
407:           child: Row(
408:             mainAxisAlignment: MainAxisAlignment.spaceAround,
409:             children: List.generate(items.length, (index) {
410:               final item = items[index];
411:               final isSelected = index == currentIndex;
412:               return Expanded(
413:                 child: GestureDetector(
414:                   onTap: () => onTap(index),
415:                   behavior: HitTestBehavior.opaque,
416:                   child: Column(
417:                     mainAxisSize: MainAxisSize.min,
418:                     children: [
419:                       Icon(
420:                         isSelected ? item.selectedIcon : item.icon,
421:                         color: isSelected ? AppColors.primary : AppColors.textTertiary,
422:                         size: 24,
423:                       ),
424:                       const SizedBox(height: 4),
425:                       Text(
426:                         item.label,
427:                         style: AppTextStyles.labelSmall.copyWith(
428:                           color: isSelected ? AppColors.primary : AppColors.textTertiary,
429:                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
430:                         ),
431:                         maxLines: 1,
432:                         overflow: TextOverflow.ellipsis,
433:                       ),
434:                     ],
435:                   ),
436:                 ),
437:               );
438:             }),
439:           ),
440:         ),
441:       ),
442:     );
443:   }
444: }
445: 
446: class _NavItemData {
447:   final IconData icon;
448:   final IconData selectedIcon;
449:   final String label;
450:   const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
451: }

(End of file - total 451 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\profile\\patient_profile_screen.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\profile\patient_profile_screen.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import 'package:flutter_bloc/flutter_bloc.dart';
3: import 'package:go_router/go_router.dart';
4: 
5: import '../../../core/bloc/auth_bloc.dart';
6: import '../../../core/constants/app_constants.dart';
7: import '../../../core/models/user_models.dart';
8: import '../../../core/theme/app_colors.dart';
9: import '../../../core/theme/app_text_styles.dart';
10: import '../../../core/widgets/app_button.dart';
11: import '../../../core/widgets/debug_account_switcher.dart';
12: import '../services/patient_profile_service.dart';
13: 
14: class PatientProfileScreen extends StatefulWidget {
15:   const PatientProfileScreen({super.key});
16: 
17:   @override
18:   State<PatientProfileScreen> createState() => _PatientProfileScreenState();
19: }
20: 
21: class _PatientProfileScreenState extends State<PatientProfileScreen> {
22:   final _service = PatientProfileService();
23:   bool _loading = true;
24:   PatientProfile? _profile;
25: 
26:   @override
27:   void initState() {
28:     super.initState();
29:     _loadProfile();
30:   }
31: 
32:   Future<void> _loadProfile() async {
33:     try {
34:       final profile = await _service.getProfile();
35:       if (!mounted) return;
36:       setState(() {
37:         _profile = profile;
38:         _loading = false;
39:       });
40:     } catch (e) {
41:       if (!mounted) return;
42:       setState(() {
43:         _profile = null;
44:         _loading = false;
45:       });
46:       if (context.mounted) {
47:         ScaffoldMessenger.of(context).showSnackBar(
48:           const SnackBar(content: Text('Failed to load profile. Please try again.')),
49:         );
50:       }
51:     }
52:   }
53: 
54:   void _onNavTap(int index) {
55:     switch (index) {
56:       case 0:
57:         context.go(AppRoutes.patientHome);
58:         break;
59:       case 1:
60:         context.go(AppRoutes.patientAppointments);
61:         break;
62:       case 2:
63:         context.go(AppRoutes.patientCommunity);
64:         break;
65:       case 3:
66:         context.go(AppRoutes.patientBrowseDoctors);
67:         break;
68:       case 4:
69:         // Already on profile
70:         break;
71:     }
72:   }
73: 
74:   Future<void> _showLogoutDialog() async {
75:     final confirmed = await showDialog<bool>(
76:       context: context,
77:       builder: (ctx) => AlertDialog(
78:         title: const Text('Logout'),
79:         content: const Text('Are you sure you want to log out?'),
80:         actions: [
81:           TextButton(
82:             onPressed: () => Navigator.of(ctx).pop(false),
83:             child: const Text('Cancel'),
84:           ),
85:           TextButton(
86:             onPressed: () => Navigator.of(ctx).pop(true),
87:             child: const Text('Logout'),
88:           ),
89:         ],
90:       ),
91:     );
92: 
93:     if (confirmed == true && mounted) {
94:       context.read<AuthBloc>().add(AuthLogoutRequested());
95:     }
96:   }
97: 
98:   @override
99:   Widget build(BuildContext context) {
100:     return Scaffold(
101:       backgroundColor: AppColors.background,
102:       appBar: AppBar(
103:         title: const Text('Profile'),
104:         actions: [
105:           IconButton(
106:             icon: const Icon(Icons.notifications_none, color: AppColors.primary),
107:             onPressed: () => context.push(AppRoutes.patientNotifications),
108:           ),
109:         ],
110:       ),
111:       body: SafeArea(
112:         child: _loading
113:             ? const Center(child: CircularProgressIndicator())
114:             : RefreshIndicator(
115:                 onRefresh: _loadProfile,
116:                 child: SingleChildScrollView(
117:                   physics: const AlwaysScrollableScrollPhysics(),
118:                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
119:                   child: Column(
120:                     crossAxisAlignment: CrossAxisAlignment.center,
121:                     children: [
122:                       // Profile Photo
123:                       Stack(
124:                         alignment: Alignment.bottomRight,
125:                         children: [
126:                           const CircleAvatar(
127:                             radius: 50,
128:                             backgroundColor: AppColors.primary100,
129:                             backgroundImage: AssetImage(AssetPaths.patientProfile1),
130:                           ),
131:                           GestureDetector(
132:                             onTap: () => context.push(AppRoutes.patientEditProfile),
133:                             child: Container(
134:                               height: 32,
135:                               width: 32,
136:                               decoration: const BoxDecoration(
137:                                 color: AppColors.primary,
138:                                 shape: BoxShape.circle,
139:                               ),
140:                               child: const Icon(Icons.edit, color: AppColors.textOnPrimary, size: 16),
141:                             ),
142:                           ),
143:                         ],
144:                       ),
145:                       const SizedBox(height: 16),
146:                       Text(
147:                         _profile?.fullName ?? '',
148:                         style: AppTextStyles.heading2,
149:                       ),
150:                       const SizedBox(height: 4),
151:                       Text(
152:                         _profile?.email ?? '',
153:                         style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
154:                       ),
155:                       const SizedBox(height: 4),
156:                       Text(
157:                         _profile?.phoneNumber ?? '',
158:                         style: AppTextStyles.bodySmall,
159:                       ),
160:                       // Health Info Section
161:                       if (_profile?.bloodType != null ||
162:                           _profile?.allergies != null ||
163:                           _profile?.chronicDiseases != null) ...[
164:                         Align(
165:                           alignment: AlignmentDirectional.centerStart,
166:                           child: Text('Health Information', style: AppTextStyles.heading3),
167:                         ),
168:                         const SizedBox(height: 12),
169:                         if (_profile?.bloodType != null)
170:                           _HealthCard(
171:                             icon: Icons.bloodtype,
172:                             title: 'Blood Type',
173:                             value: _profile!.bloodType!,
174:                           ),
175:                         if (_profile?.allergies != null && _profile!.allergies!.isNotEmpty)
176:                           _HealthCard(
177:                             icon: Icons.warning_amber_rounded,
178:                             title: 'Allergies',
179:                             value: _profile!.allergies!,
180:                           ),
181:                         if (_profile?.chronicDiseases != null && _profile!.chronicDiseases!.isNotEmpty)
182:                           _HealthCard(
183:                             icon: Icons.medical_services_outlined,
184:                             title: 'Chronic Diseases',
185:                             value: _profile!.chronicDiseases!,
186:                           ),
187:                         const SizedBox(height: 24),
188:                       ],
189: 
190:                       // Add Family Member Button
191:                       AppButton(
192:                         text: 'Add Family Member',
193:                         isSmall: true,
194:                         icon: Icons.person_add,
195:                         onPressed: () => context.push(AppRoutes.patientAddFamilyMember),
196:                       ),
197:                       const SizedBox(height: 24),
198: 
199:                       // Menu Items
200:                       _MenuItem(
201:                         icon: Icons.medical_services_outlined,
202:                         title: 'Medical History',
203:                         onTap: () => context.push(AppRoutes.patientMedicalHistory),
204:                       ),
205:                       _MenuItem(
206:                         icon: Icons.favorite_outline,
207:                         title: 'My Favorites',
208:                         onTap: () => context.push(AppRoutes.patientFavorites),
209:                       ),
210:                       _MenuItem(
211:                         icon: Icons.people_outline,
212:                         title: 'Family Members',
213:                         onTap: () => context.push(AppRoutes.patientFamilyMembers),
214:                       ),
215:                       _MenuItem(
216:                         icon: Icons.edit_outlined,
217:                         title: 'Edit Profile',
218:                         onTap: () => context.push(AppRoutes.patientEditProfile),
219:                       ),
220:                       _MenuItem(
221:                         icon: Icons.info_outline,
222:                         title: 'About Medicare',
223:                         onTap: () {
224:                           showAboutDialog(
225:                             context: context,
226:                             applicationName: 'Medicare',
227:                             applicationVersion: '1.0.0',
228:                             applicationLegalese: 'Your trusted healthcare companion.',
229:                           );
230:                         },
231:                       ),
232:                       const SizedBox(height: 8),
233:                       SizedBox(
234:                         height: 52,
235:                         width: double.infinity,
236:                         child: OutlinedButton.icon(
237:                           onPressed: _showLogoutDialog,
238:                           icon: const Icon(Icons.logout, size: 18),
239:                           label: const Text('Logout'),
240:                           style: OutlinedButton.styleFrom(
241:                             foregroundColor: AppColors.error,
242:                             side: const BorderSide(color: AppColors.error),
243:                           ),
244:                         ),
245:                       ),
246:                       if (kEnableDebugTools) ...[
247:                         const DebugAccountSwitcher(),
248:                         const SizedBox(height: 12),
249:                       ],
250:                     ],
251:                   ),
252:                 ),
253:               ),
254:       ),
255:       bottomNavigationBar: _ProfileBottomNav(
256:         currentIndex: 4,
257:         onTap: _onNavTap,
258:       ),
259:     );
260:   }
261: }
262: 
263: class _MenuItem extends StatelessWidget {
264:   final IconData icon;
265:   final String title;
266:   final VoidCallback onTap;
267: 
268:   const _MenuItem({
269:     required this.icon,
270:     required this.title,
271:     required this.onTap,
272:   });
273: 
274:   @override
275:   Widget build(BuildContext context) {
276:     return GestureDetector(
277:       onTap: onTap,
278:       child: Container(
279:         margin: const EdgeInsets.only(bottom: 10),
280:         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
281:         decoration: BoxDecoration(
282:           color: AppColors.surface,
283:           borderRadius: BorderRadius.circular(12),
284:           border: Border.all(color: AppColors.borderLight),
285:         ),
286:         child: Row(
287:           children: [
288:             Container(
289:               height: 40,
290:               width: 40,
291:               decoration: BoxDecoration(
292:                 color: AppColors.primary50,
293:                 borderRadius: BorderRadius.circular(10),
294:               ),
295:               child: Icon(icon, color: AppColors.primary, size: 20),
296:             ),
297:             const SizedBox(width: 14),
298:             Expanded(
299:               child: Text(title, style: AppTextStyles.labelLarge),
300:             ),
301:             const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
302:           ],
303:         ),
304:       ),
305:     );
306:   }
307: }
308: 
309: class _HealthCard extends StatelessWidget {
310:   final IconData icon;
311:   final String title;
312:   final String value;
313: 
314:   const _HealthCard({
315:     required this.icon,
316:     required this.title,
317:     required this.value,
318:   });
319: 
320:   @override
321:   Widget build(BuildContext context) {
322:     return Container(
323:       margin: const EdgeInsets.only(bottom: 10),
324:       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
325:       decoration: BoxDecoration(
326:         color: AppColors.surface,
327:         borderRadius: BorderRadius.circular(12),
328:         border: Border.all(color: AppColors.borderLight),
329:       ),
330:       child: Row(
331:         children: [
332:           Container(
333:             height: 40,
334:             width: 40,
335:             decoration: BoxDecoration(
336:               color: AppColors.primary50,
337:               borderRadius: BorderRadius.circular(10),
338:             ),
339:             child: Icon(icon, color: AppColors.primary, size: 20),
340:           ),
341:           const SizedBox(width: 14),
342:           Column(
343:             crossAxisAlignment: CrossAxisAlignment.start,
344:             children: [
345:               Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
346:               const SizedBox(height: 2),
347:               Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600)),
348:             ],
349:           ),
350:         ],
351:       ),
352:     );
353:   }
354: }
355: 
356: class _ProfileBottomNav extends StatelessWidget {
357:   final int currentIndex;
358:   final Function(int) onTap;
359: 
360:   const _ProfileBottomNav({
361:     required this.currentIndex,
362:     required this.onTap,
363:   });
364: 
365:   @override
366:   Widget build(BuildContext context) {
367:     const items = [
368:       _NavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
369:       _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today, label: 'Appointments'),
370:       _NavItemData(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'AI Bot'),
371:       _NavItemData(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'Nearby'),
372:       _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
373:     ];
374: 
375:     return Container(
376:       decoration: BoxDecoration(
377:         color: AppColors.surface,
378:         boxShadow: [
379:           BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, -2)),
380:         ],
381:       ),
382:       child: SafeArea(
383:         child: Padding(
384:           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
385:           child: Row(
386:             mainAxisAlignment: MainAxisAlignment.spaceAround,
387:             children: List.generate(items.length, (index) {
388:               final item = items[index];
389:               final isSelected = index == currentIndex;
390:               return Expanded(
391:                 child: GestureDetector(
392:                   onTap: () => onTap(index),
393:                   behavior: HitTestBehavior.opaque,
394:                   child: Column(
395:                     mainAxisSize: MainAxisSize.min,
396:                     children: [
397:                       Icon(
398:                         isSelected ? item.selectedIcon : item.icon,
399:                         color: isSelected ? AppColors.primary : AppColors.textTertiary,
400:                         size: 24,
401:                       ),
402:                       const SizedBox(height: 4),
403:                       Text(
404:                         item.label,
405:                         style: AppTextStyles.labelSmall.copyWith(
406:                           color: isSelected ? AppColors.primary : AppColors.textTertiary,
407:                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
408:                         ),
409:                         maxLines: 1,
410:                         overflow: TextOverflow.ellipsis,
411:                       ),
412:                     ],
413:                   ),
414:                 ),
415:               );
416:             }),
417:           ),
418:         ),
419:       ),
420:     );
421:   }
422: }
423: 
424: class _NavItemData {
425:   final IconData icon;
426:   final IconData selectedIcon;
427:   final String label;
428:   const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
429: }

(End of file - total 429 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\doctor\\screens\\doctor_appointments_screen.dart"
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\doctor\screens\doctor_appointments_screen.dart</path>
<type>file</type>
<content>
1: import 'package:flutter/material.dart';
2: import 'package:go_router/go_router.dart';
3: 
4: import '../../../core/constants/app_constants.dart';
5: import '../../../core/models/appointment_models.dart';
6: import '../../../core/theme/app_colors.dart';
7: import '../../../core/theme/app_text_styles.dart';
8: import '../../../core/widgets/app_bottom_nav.dart';
9: import '../../doctor/services/doctor_service.dart';
10: 
11: class DoctorAppointmentsScreen extends StatefulWidget {
12:   const DoctorAppointmentsScreen({super.key});
13: 
14:   @override
15:   State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
16: }
17: 
18: class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
19:   final _service = DoctorService();
20:   DateTime _selectedDate = DateTime.now();
21:   int _statusFilter = -1; // -1 = all
22:   int _navIndex = 1;
23: 
24:   void _onNavTap(int index) {
25:     setState(() => _navIndex = index);
26:     switch (index) {
27:       case 0:
28:         context.go(AppRoutes.doctorDashboard);
29:         break;
30:       case 1:
31:         context.go(AppRoutes.doctorAppointments);
32:         break;
33:       case 2:
34:         context.go(AppRoutes.doctorCommunity);
35:         break;
36:       case 3:
37:         context.go(AppRoutes.doctorProfile);
38:         break;
39:     }
40:   }
41: 
42:   List<DateTime> _getWeekDays() {
43:     final now = DateTime.now();
44:     final start = now.subtract(const Duration(days: 3));
45:     return List.generate(7, (i) => start.add(Duration(days: i)));
46:   }
47: 
48:   String _weekdayName(int weekday) {
49:     const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
50:     return names[weekday - 1];
51:   }
52: 
53:   Color _statusColor(int status) {
54:     switch (status) {
55:       case 0:
56:         return AppColors.warning;
57:       case 1:
58:         return AppColors.primary;
59:       case 2:
60:         return AppColors.info;
61:       case 3:
62:         return AppColors.success;
63:       case 4:
64:         return AppColors.error;
65:       default:
66:         return AppColors.textTertiary;
67:     }
68:   }
69: 
70:   Color _statusBgColor(int status) {
71:     switch (status) {
72:       case 0:
73:         return AppColors.warningBg;
74:       case 1:
75:         return AppColors.primary50;
76:       case 2:
77:         return AppColors.infoBg;
78:       case 3:
79:         return AppColors.successBg;
80:       case 4:
81:         return AppColors.errorBg;
82:       default:
83:         return AppColors.surfaceVariant;
84:     }
85:   }
86: 
87:   @override
88:   Widget build(BuildContext context) {
89:     final weekDays = _getWeekDays();
90: 
91:     return Scaffold(
92:       backgroundColor: AppColors.background,
93:       appBar: AppBar(
94:         title: const Text('Appointments'),
95:         actions: [
96:           IconButton(
97:             icon: const Icon(Icons.filter_list),
98:             onPressed: () {
99:               showModalBottomSheet(
100:                 context: context,
101:                 builder: (context) => _FilterSheet(
102:                   selectedFilter: _statusFilter,
103:                   onSelect: (filter) {
104:                     setState(() => _statusFilter = filter);
105:                     Navigator.pop(context);
106:                   },
107:                 ),
108:               );
109:             },
110:           ),
111:         ],
112:       ),
113:       body: SafeArea(
114:         child: Column(
115:           children: [
116:             // Calendar strip
117:             Container(
118:               color: AppColors.surface,
119:               padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
120:               child: Row(
121:                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
122:                 children: weekDays.map((date) {
123:                   final isSelected = date.day == _selectedDate.day &&
124:                       date.month == _selectedDate.month &&
125:                       date.year == _selectedDate.year;
126:                   final isToday = date.day == DateTime.now().day &&
127:                       date.month == DateTime.now().month &&
128:                       date.year == DateTime.now().year;
129:                   return GestureDetector(
130:                     onTap: () => setState(() => _selectedDate = date),
131:                     child: Container(
132:                       width: 44,
133:                       padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
134:                       decoration: BoxDecoration(
135:                         color: isSelected ? AppColors.primary : Colors.transparent,
136:                         borderRadius: BorderRadius.circular(12),
137:                       ),
138:                       child: Column(
139:                         children: [
140:                           Text(
141:                             _weekdayName(date.weekday),
142:                             style: AppTextStyles.labelSmall.copyWith(
143:                               color: isSelected
144:                                   ? AppColors.textOnPrimary
145:                                   : AppColors.textTertiary,
146:                             ),
147:                           ),
148:                           const SizedBox(height: 4),
149:                           Text(
150:                             date.day.toString(),
151:                             style: AppTextStyles.labelLarge.copyWith(
152:                               color: isSelected
153:                                   ? AppColors.textOnPrimary
154:                                   : (isToday ? AppColors.primary : AppColors.textPrimary),
155:                               fontWeight: FontWeight.w700,
156:                             ),
157:                           ),
158:                         ],
159:                       ),
160:                     ),
161:                   );
162:                 }).toList(),
163:               ),
164:             ),
165:             const SizedBox(height: 8),
166:             // Appointment list
167:             Expanded(
168:               child: FutureBuilder(
169:                 future: _service.getAppointments(date: _selectedDate),
170:                 builder: (context, snapshot) {
171:                   if (snapshot.connectionState == ConnectionState.waiting) {
172:                     return const Center(child: CircularProgressIndicator());
173:                   }
174: 
175:                   if (snapshot.hasError) {
176:                     return Center(
177:                       child: Column(
178:                         mainAxisAlignment: MainAxisAlignment.center,
179:                         children: [
180:                           const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
181:                           const SizedBox(height: 12),
182:                           Text(
183:                             snapshot.error?.toString() ?? 'Failed to load appointments',
184:                             style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
185:                             textAlign: TextAlign.center,
186:                           ),
187:                         ],
188:                       ),
189:                     );
190:                   }
191: 
192:                   final allAppointments = snapshot.data ?? [];
193:                   final appointments = _statusFilter == -1
194:                       ? allAppointments
195:                       : allAppointments
196:                           .where((a) => a.status == _statusFilter)
197:                           .toList();
198: 
199:                   if (appointments.isEmpty) {
200:                     return Center(
201:                       child: Column(
202:                         mainAxisAlignment: MainAxisAlignment.center,
203:                         children: [
204:                           Icon(
205:                             Icons.calendar_today,
206:                             size: 64,
207:                             color: AppColors.textTertiary,
208:                           ),
209:                           const SizedBox(height: 16),
210:                           Text(
211:                             'No appointments for this day',
212:                             style: AppTextStyles.bodyLarge.copyWith(
213:                               color: AppColors.textSecondary,
214:                             ),
215:                           ),
216:                         ],
217:                       ),
218:                     );
219:                   }
220: 
221:                   return ListView.separated(
222:                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
223:                     itemCount: appointments.length,
224:                     separatorBuilder: (_, __) => const SizedBox(height: 10),
225:                     itemBuilder: (context, index) {
226:                       final appt = appointments[index];
227:                       return _AppointmentCard(
228:                         appointment: appt,
229:                         statusColor: _statusColor(appt.status),
230:                         statusBgColor: _statusBgColor(appt.status),
231:                         onTap: () {
232:                           if (appt.status == AppEnums.confirmed ||
233:                               appt.status == AppEnums.inProgress) {
234:                             context.push(
235:                               '${AppRoutes.doctorConsultation}/${appt.id}',
236:                             );
237:                           }
238:                         },
239:                       );
240:                     },
241:                   );
242:                 },
243:               ),
244:             ),
245:           ],
246:         ),
247:       ),
248:       bottomNavigationBar: AppBottomNav(
249:         currentIndex: _navIndex,
250:         items: DoctorNavItems.items,
251:         onTap: _onNavTap,
252:       ),
253:     );
254:   }
255: }
256: 
257: class _AppointmentCard extends StatelessWidget {
258:   final Appointment appointment;
259:   final Color statusColor;
260:   final Color statusBgColor;
261:   final VoidCallback? onTap;
262: 
263:   const _AppointmentCard({
264:     required this.appointment,
265:     required this.statusColor,
266:     required this.statusBgColor,
267:     this.onTap,
268:   });
269: 
270:   @override
271:   Widget build(BuildContext context) {
272:     return GestureDetector(
273:       onTap: onTap,
274:       child: Container(
275:         padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
276:         decoration: BoxDecoration(
277:           color: AppColors.surface,
278:           borderRadius: BorderRadius.circular(16),
279:           border: Border.all(color: AppColors.borderLight),
280:         ),
281:         child: Row(
282:           children: [
283:             CircleAvatar(
284:               radius: 24,
285:               backgroundImage: appointment.doctorProfileImageUrl != null
286:                   ? NetworkImage(appointment.doctorProfileImageUrl!)
287:                   : const AssetImage(AssetPaths.patientProfile1) as ImageProvider,
288:               onBackgroundImageError: (_, __) {},
289:             ),
290:             const SizedBox(width: 12),
291:             Expanded(
292:               child: Column(
293:                 crossAxisAlignment: CrossAxisAlignment.start,
294:                 children: [
295:                   Text(
296:                     appointment.patientName,
297:                     style: AppTextStyles.labelLarge,
298:                   ),
299:                   const SizedBox(height: 2),
300:                   Text(
301:                     '${appointment.startTime} - ${appointment.specialization}',
302:                     style: AppTextStyles.bodySmall,
303:                   ),
304:                 ],
305:               ),
306:             ),
307:             Container(
308:               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
309:               decoration: BoxDecoration(
310:                 color: statusBgColor,
311:                 borderRadius: BorderRadius.circular(20),
312:               ),
313:               child: Text(
314:                 appointment.statusText,
315:                 style: AppTextStyles.labelSmall.copyWith(
316:                   color: statusColor,
317:                   fontWeight: FontWeight.w600,
318:                 ),
319:               ),
320:             ),
321:           ],
322:         ),
323:       ),
324:     );
325:   }
326: }
327: 
328: class _FilterSheet extends StatelessWidget {
329:   final int selectedFilter;
330:   final Function(int) onSelect;
331: 
332:   const _FilterSheet({
333:     required this.selectedFilter,
334:     required this.onSelect,
335:   });
336: 
337:   @override
338:   Widget build(BuildContext context) {
339:     final filters = [
340:       (-1, 'All'),
341:       (AppEnums.pending, 'Pending'),
342:       (AppEnums.confirmed, 'Confirmed'),
343:       (AppEnums.inProgress, 'In Progress'),
344:       (AppEnums.completed, 'Completed'),
345:       (AppEnums.cancelled, 'Cancelled'),
346:     ];
347: 
348:     return Container(
349:       padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
350:       decoration: const BoxDecoration(
351:         color: AppColors.surface,
352:         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
353:       ),
354:       child: Column(
355:         mainAxisSize: MainAxisSize.min,
356:         crossAxisAlignment: CrossAxisAlignment.start,
357:         children: [
358:           Center(
359:             child: Container(
360:               width: 40,
361:               height: 4,
362:               decoration: BoxDecoration(
363:                 color: AppColors.border,
364:                 borderRadius: BorderRadius.circular(2),
365:               ),
366:             ),
367:           ),
368:           const SizedBox(height: 16),
369:           Text('Filter by Status', style: AppTextStyles.heading2),
370:           const SizedBox(height: 12),
371:           Wrap(
372:             spacing: 8,
373:             runSpacing: 8,
374:             children: filters.map((filter) {
375:               final isSelected = filter.$1 == selectedFilter;
376:               return ChoiceChip(
377:                 label: Text(filter.$2),
378:                 selected: isSelected,
379:                 onSelected: (_) => onSelect(filter.$1),
380:                 selectedColor: AppColors.primary,
381:                 backgroundColor: AppColors.surfaceVariant,
382:                 labelStyle: AppTextStyles.labelMedium.copyWith(
383:                   color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
384:                 ),
385:               );
386:             }).toList(),
387:           ),
388:         ],
389:       ),
390:     );
391:   }
392: }

(End of file - total 392 lines)
</content>
```

---

## Assistant (Sisyphus - Ultraworker · Kimi K2.6 · 18.9s)

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\community\\community_feed_screen.dart",
  "offset": 230,
  "limit": 100
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\community_feed_screen.dart</path>
<type>file</type>
<content>
230:                             itemBuilder: (context, index) {
231:                               final post = _posts[index];
232:                               return _PostCard(
233:                                 post: post,
234:                                 onTap: () => context.push('${AppRoutes.patientPostDetail}/${post.id}'),
235:                                 onDelete: () => _deletePost(post),
236:                               );
237:                             },
238:                           ),
239:                   ),
240:           ),
241:         ],
242:       ),
243:       floatingActionButton: FloatingActionButton(
244:         onPressed: () => context.push(AppRoutes.patientCreatePost),
245:         child: const Icon(Icons.add),
246:       ),
247:       bottomNavigationBar: _CommunityBottomNav(
248:         currentIndex: 2,
249:         onTap: _onNavTap,
250:       ),
251:     );
252:   }
253: }
254: 
255: class _PostCard extends StatelessWidget {
256:   final CommunityPost post;
257:   final VoidCallback? onTap;
258:   final VoidCallback? onDelete;
259: 
260:   const _PostCard({required this.post, this.onTap, this.onDelete});
261: 
262:   @override
263:   Widget build(BuildContext context) {
264:     return GestureDetector(
265:       onTap: onTap,
266:       child: Container(
267:         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
268:         decoration: BoxDecoration(
269:           color: AppColors.surface,
270:           borderRadius: BorderRadius.circular(16),
271:           border: Border.all(color: AppColors.borderLight),
272:         ),
273:         child: Column(
274:           crossAxisAlignment: CrossAxisAlignment.start,
275:           children: [
276:             Row(
277:               children: [
278:                 CircleAvatar(
279:                   radius: 20,
280:                   backgroundColor: AppColors.primary100,
281:                   backgroundImage: AssetImage(
282:                     [
283:                       AssetPaths.familyMember1,
284:                       AssetPaths.familyMember2,
285:                       AssetPaths.familyMember3,
286:                     ][(post.id - 1) % 3],
287:                   ),
288:                 ),
289:                 const SizedBox(width: 12),
290:                 Expanded(
291:                   child: Column(
292:                     crossAxisAlignment: CrossAxisAlignment.start,
293:                     children: [
294:                       Text(
295:                         post.authorName,
296:                         style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
297:                         maxLines: 1,
298:                         overflow: TextOverflow.ellipsis,
299:                       ),
300:                       const SizedBox(height: 2),
301:                       Row(
302:                         children: [
303:                           Text(
304:                             post.authorRoleText,
305:                             style: AppTextStyles.bodySmall,
306:                           ),
307:                           if (post.authorSpecialization != null) ...[
308:                             const SizedBox(width: 6),
309:                             Container(
310:                               height: 4,
311:                               width: 4,
312:                               decoration: const BoxDecoration(
313:                                 color: AppColors.textTertiary,
314:                                 shape: BoxShape.circle,
315:                               ),
316:                             ),
317:                             const SizedBox(width: 6),
318:                             Text(
319:                               post.authorSpecialization!,
320:                               style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
321:                             ),
322:                           ],
323:                         ],
324:                       ),
325:                     ],
326:                   ),
327:                 ),
328:                 Text(
329:                   _timeAgo(post.createdAt),

(Showing lines 230-329 of 538. Use offset=330 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\nearby\\nearby_screen.dart",
  "offset": 330,
  "limit": 100
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\nearby\nearby_screen.dart</path>
<type>file</type>
<content>
330:             ),
331:           ),
332: 
333:           // Bottom sheet: list of nearby items
334:           Positioned(
335:             left: 0,
336:             right: 0,
337:             bottom: 0,
338:             child: _buildBottomSheet(),
339:           ),
340: 
341:           // Loading overlay
342:           if (_loadingLocation || _loadingData)
343:             Positioned.fill(
344:               child: Container(
345:                 color: AppColors.background.withValues(alpha: 0.5),
346:                 child: const Center(child: CircularProgressIndicator()),
347:               ),
348:             ),
349:         ],
350:       ),
351:       bottomNavigationBar: _NearbyBottomNav(
352:         currentIndex: 3,
353:         onTap: _onNavTap,
354:       ),
355:     );
356:   }
357: 
358:   Widget _buildMap() {
359:     if (_loadingLocation && _userLocation == null) {
360:       return const Center(child: CircularProgressIndicator());
361:     }
362: 
363:     if (_locationError != null && _userLocation == null) {
364:       return Center(
365:         child: Padding(
366:           padding: const EdgeInsets.all(24),
367:           child: Column(
368:             mainAxisSize: MainAxisSize.min,
369:             children: [
370:               const Icon(Icons.location_off, size: 48, color: AppColors.textTertiary),
371:               const SizedBox(height: 12),
372:               Text(
373:                 _locationError!,
374:                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
375:                 textAlign: TextAlign.center,
376:               ),
377:               const SizedBox(height: 16),
378:               ElevatedButton(
379:                 onPressed: _initLocation,
380:                 child: const Text('Retry'),
381:               ),
382:             ],
383:           ),
384:         ),
385:       );
386:     }
387: 
388:     final center = _userLocation ?? const LatLng(30.0444, 31.2357); // Default: Cairo
389: 
390:     return FlutterMap(
391:       mapController: _mapController,
392:       options: MapOptions(
393:         initialCenter: center,
394:         initialZoom: 14,
395:         minZoom: 3,
396:         maxZoom: 18,
397:       ),
398:       children: [
399:         TileLayer(
400:           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
401:           userAgentPackageName: 'com.medicare.app',
402:         ),
403:         MarkerLayer(markers: _markers),
404:       ],
405:     );
406:   }
407: 
408:   Widget _buildSearchBar() {
409:     return Container(
410:       decoration: BoxDecoration(
411:         color: AppColors.surface,
412:         borderRadius: BorderRadius.circular(18),
413:         boxShadow: [
414:           BoxShadow(
415:             color: AppColors.shadow,
416:             blurRadius: 12,
417:             offset: const Offset(0, 4),
418:           ),
419:         ],
420:       ),
421:       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
422:       child: Row(
423:         children: [
424:           const Icon(Icons.search, color: AppColors.textTertiary, size: 22),
425:           const SizedBox(width: 8),
426:           Expanded(
427:             child: TextField(
428:               controller: _searchController,
429:               textInputAction: TextInputAction.search,

(Showing lines 330-429 of 788. Use offset=430 to continue.)
</content>
```

---

## Assistant (Sisyphus - Ultraworker · Kimi K2.6 · 59.3s)

**Tool: grep**

**Input:**
```json
{
  "pattern": "class _CommunityBottomNav|class _NearbyBottomNav",
  "path": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient",
  "output_mode": "content",
  "include": "*.dart"
}
```

**Output:**
```
Found 2 match(es) in 2 file(s)

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\community_feed_screen.dart
  465: class _CommunityBottomNav extends StatelessWidget {

C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\nearby\nearby_screen.dart
  718: class _NearbyBottomNav extends StatelessWidget {

```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\community\\community_feed_screen.dart",
  "offset": 480,
  "limit": 60
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\community\community_feed_screen.dart</path>
<type>file</type>
<content>
480:       _NavItemData(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'Nearby'),
481:       _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
482:     ];
483: 
484:     return Container(
485:       decoration: BoxDecoration(
486:         color: AppColors.surface,
487:         boxShadow: [
488:           BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, -2)),
489:         ],
490:       ),
491:       child: SafeArea(
492:         child: Padding(
493:           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
494:           child: Row(
495:             mainAxisAlignment: MainAxisAlignment.spaceAround,
496:             children: List.generate(items.length, (index) {
497:               final item = items[index];
498:               final isSelected = index == currentIndex;
499:               return Expanded(
500:                 child: GestureDetector(
501:                   onTap: () => onTap(index),
502:                   behavior: HitTestBehavior.opaque,
503:                   child: Column(
504:                     mainAxisSize: MainAxisSize.min,
505:                     children: [
506:                       Icon(
507:                         isSelected ? item.selectedIcon : item.icon,
508:                         color: isSelected ? AppColors.primary : AppColors.textTertiary,
509:                         size: 24,
510:                       ),
511:                       const SizedBox(height: 4),
512:                       Text(
513:                         item.label,
514:                         style: AppTextStyles.labelSmall.copyWith(
515:                           color: isSelected ? AppColors.primary : AppColors.textTertiary,
516:                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
517:                         ),
518:                         maxLines: 1,
519:                         overflow: TextOverflow.ellipsis,
520:                       ),
521:                     ],
522:                   ),
523:                 ),
524:               );
525:             }),
526:           ),
527:         ),
528:       ),
529:     );
530:   }
531: }
532: 
533: class _NavItemData {
534:   final IconData icon;
535:   final IconData selectedIcon;
536:   final String label;
537:   const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
538: }

(End of file - total 538 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "C:\\Users\\Zowail\\StudioProjects\\medicare\\lib\\features\\patient\\nearby\\nearby_screen.dart",
  "offset": 740,
  "limit": 60
}
```

**Output:**
```
<path>C:\Users\Zowail\StudioProjects\medicare\lib\features\patient\nearby\nearby_screen.dart</path>
<type>file</type>
<content>
740:       ),
741:       child: SafeArea(
742:         child: Padding(
743:           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
744:           child: Row(
745:             mainAxisAlignment: MainAxisAlignment.spaceAround,
746:             children: List.generate(items.length, (index) {
747:               final item = items[index];
748:               final isSelected = index == currentIndex;
749:               return Expanded(
750:                 child: GestureDetector(
751:                   onTap: () => onTap(index),
752:                   behavior: HitTestBehavior.opaque,
753:                   child: Column(
754:                     mainAxisSize: MainAxisSize.min,
755:                     children: [
756:                       Icon(
757:                         isSelected ? item.selectedIcon : item.icon,
758:                         color: isSelected ? AppColors.primary : AppColors.textTertiary,
759:                         size: 24,
760:                       ),
761:                       const SizedBox(height: 4),
762:                       Text(
763:                         item.label,
764:                         style: AppTextStyles.labelSmall.copyWith(
765:                           color: isSelected ? AppColors.primary : AppColors.textTertiary,
766:                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
767:                         ),
768:                         maxLines: 1,
769:                         overflow: TextOverflow.ellipsis,
770:                       ),
771:                     ],
772:                   ),
773:                 ),
774:               );
775:             }),
776:           ),
777:         ),
778:       ),
779:     );
780:   }
781: }
782: 
783: class _NavItemData {
784:   final IconData icon;
785:   final IconData selectedIcon;
786:   final String label;
787:   const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
788: }

(End of file - total 788 lines)
</content>
```

---

## Assistant (Sisyphus - Ultraworker · Kimi K2.6)

---

