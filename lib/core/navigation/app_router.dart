import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../models/appointment_models.dart';
import '../models/shared_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/register_patient_screen.dart';
import '../../features/auth/screens/register_doctor_screen.dart';
import '../../features/auth/screens/register_clinic_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';

import '../../features/patient/browse_doctors/browse_doctors_screen.dart';
import '../../features/patient/doctor_profile/doctor_profile_screen.dart';
import '../../features/patient/home/patient_home_screen.dart';
import '../../features/patient/nearby/nearby_screen.dart';
import '../../features/patient/specializations/specializations_screen.dart';

import '../../features/patient/appointments/book_appointment_screen.dart';
import '../../features/patient/appointments/appointment_confirmation_screen.dart';
import '../../features/patient/appointments/my_appointments_screen.dart';
import '../../features/patient/appointments/appointment_detail_screen.dart';
import '../../features/patient/appointments/queue_tracker_screen.dart';

import '../../features/patient/community/community_feed_screen.dart';
import '../../features/patient/community/create_post_screen.dart';
import '../../features/patient/community/post_detail_screen.dart';

import '../../features/patient/profile/patient_profile_screen.dart';
import '../../features/patient/profile/edit_patient_profile_screen.dart';
import '../../features/patient/profile/medical_history_screen.dart';
import '../../features/patient/profile/family_members_screen.dart';
import '../../features/patient/profile/add_family_member_screen.dart';
import '../../features/patient/profile/favorites_screen.dart';
import '../../features/patient/profile/notifications_screen.dart';
import '../../features/patient/profile/submit_review_screen.dart';

import '../../features/doctor/screens/doctor_dashboard_screen.dart';
import '../../features/doctor/screens/doctor_appointments_screen.dart';
import '../../features/doctor/screens/doctor_queue_screen.dart';
import '../../features/doctor/screens/doctor_patient_history_screen.dart';
import '../../features/doctor/screens/consultation_screen.dart';
import '../../features/doctor/screens/doctor_profile_screen.dart' as doctor_screens;
import '../../features/doctor/screens/edit_doctor_profile_screen.dart';
import '../../features/doctor/screens/doctor_qr_code_screen.dart';
import '../../features/doctor/screens/doctor_community_screen.dart';
import '../../features/doctor/screens/doctor_notifications_screen.dart';

import '../../features/clinic/screens/clinic_dashboard_screen.dart';
import '../../features/clinic/screens/clinic_queue_screen.dart';
import '../../features/clinic/screens/clinic_doctors_screen.dart';
import '../../features/clinic/screens/clinic_doctor_detail_screen.dart';
import '../../features/clinic/screens/scan_doctor_qr_screen.dart';
import '../../features/clinic/screens/register_doctor_to_clinic_screen.dart';
import '../../features/clinic/screens/manage_schedule_screen.dart';
import '../../features/clinic/screens/clinic_payments_screen.dart';
import '../../features/clinic/screens/walk_in_booking_screen.dart';
import '../../features/clinic/screens/clinic_profile_screen.dart';
import '../../features/clinic/screens/edit_clinic_profile_screen.dart';
import '../../features/clinic/screens/clinic_patient_search_screen.dart';
import '../../features/clinic/screens/clinic_notifications_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute = state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/register') ||
            state.matchedLocation.startsWith('/forgot') ||
            state.matchedLocation.startsWith('/verify') ||
            state.matchedLocation.startsWith('/reset') ||
            state.matchedLocation == AppRoutes.onboarding ||
            state.matchedLocation == AppRoutes.splash ||
            state.matchedLocation == AppRoutes.roleSelection;

        if (authState is AuthLoading) return null;

        if (!isAuthenticated && !isAuthRoute) {
          return AppRoutes.login;
        }

        if (isAuthenticated && isAuthRoute && state.matchedLocation != AppRoutes.splash) {
          final role = authState.role;
          switch (role) {
            case 'Patient':
              return AppRoutes.patientHome;
            case 'Doctor':
              return AppRoutes.doctorDashboard;
            case 'ClinicAdmin':
              return AppRoutes.clinicDashboard;
            default:
              return AppRoutes.patientHome;
          }
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.roleSelection,
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerPatient,
          builder: (context, state) => const RegisterPatientScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerDoctor,
          builder: (context, state) => const RegisterDoctorScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerClinic,
          builder: (context, state) => const RegisterClinicScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.verifyOtp,
          builder: (context, state) {
            final phone = state.extra as String?;
            return VerifyOtpScreen(phone: phone ?? '');
          },
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) {
            final extra = state.extra as Map<String, String>?;
            return ResetPasswordScreen(
              phone: extra?['phone'] ?? '',
              otpCode: extra?['otpCode'] ?? '',
            );
          },
        ),

        // Patient Routes
        GoRoute(
          path: AppRoutes.patientHome,
          builder: (context, state) => const PatientHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientSpecializations,
          builder: (context, state) => const SpecializationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientBrowseDoctors,
          builder: (context, state) => const BrowseDoctorsScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientNearby,
          builder: (context, state) => const NearbyScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientDoctorProfile,
          builder: (context, state) {
            final doctorId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return DoctorProfileScreen(doctorId: doctorId);
          },
        ),
        GoRoute(
          path: AppRoutes.patientBookAppointment,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BookAppointmentScreen(
              doctorId: extra?['doctorId'] ?? 0,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.patientAppointmentConfirmation,
          builder: (context, state) {
            final appointment = state.extra;
            if (appointment is! Appointment) {
              return const _MissingAppointmentScreen();
            }
            return AppointmentConfirmationScreen(appointment: appointment);
          },
        ),
        GoRoute(
          path: AppRoutes.patientAppointments,
          builder: (context, state) => const MyAppointmentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientAppointmentDetail,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return AppointmentDetailScreen(appointmentId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.patientQueueTracker,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return QueueTrackerScreen(appointmentId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.patientCommunity,
          builder: (context, state) => const CommunityFeedScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientCreatePost,
          builder: (context, state) => const CreatePostScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientPostDetail,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return PostDetailScreen(postId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.patientProfile,
          builder: (context, state) => const PatientProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientEditProfile,
          builder: (context, state) => const EditPatientProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientMedicalHistory,
          builder: (context, state) => const MedicalHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientFamilyMembers,
          builder: (context, state) => const FamilyMembersScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientAddFamilyMember,
          builder: (context, state) {
            final member = state.extra as FamilyMember?;
            return AddFamilyMemberScreen(existingMember: member);
          },
        ),
        GoRoute(
          path: AppRoutes.patientFavorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientNotifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientSubmitReview,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SubmitReviewScreen(
              doctorId: extra?['doctorId'] ?? 0,
              appointmentId: extra?['appointmentId'] ?? 0,
            );
          },
        ),

        // Doctor Routes
        GoRoute(
          path: AppRoutes.doctorDashboard,
          builder: (context, state) => const DoctorDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorAppointments,
          builder: (context, state) => const DoctorAppointmentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorQueue,
          builder: (context, state) => const DoctorQueueScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorPatientHistory,
          builder: (context, state) {
            final patientId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return DoctorPatientHistoryScreen(patientId: patientId);
          },
        ),
        GoRoute(
          path: AppRoutes.doctorConsultation,
          builder: (context, state) {
            final appointmentId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ConsultationScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: AppRoutes.doctorProfile,
          builder: (context, state) => const doctor_screens.DoctorProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorEditProfile,
          builder: (context, state) => const EditDoctorProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorQrCode,
          builder: (context, state) => const DoctorQrCodeScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorCommunity,
          builder: (context, state) => const DoctorCommunityScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorCreatePost,
          builder: (context, state) => const CreatePostScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorNotifications,
          builder: (context, state) => const DoctorNotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.doctorSchedule,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final doctorId = extra?['doctorId'] ?? 0;
            return ManageScheduleScreen(doctorId: doctorId);
          },
        ),

        // Clinic Routes
        GoRoute(
          path: AppRoutes.clinicDashboard,
          builder: (context, state) => const ClinicDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicQueue,
          builder: (context, state) => const ClinicQueueScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicDoctors,
          builder: (context, state) => const ClinicDoctorsScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicDoctorDetail,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ClinicDoctorDetailScreen(doctorId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.clinicScanQr,
          builder: (context, state) => const ScanDoctorQrScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicRegisterDoctor,
          builder: (context, state) => const RegisterDoctorToClinicScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicManageSchedule,
          builder: (context, state) {
            final doctorId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ManageScheduleScreen(doctorId: doctorId);
          },
        ),
        GoRoute(
          path: AppRoutes.clinicPayments,
          builder: (context, state) => const ClinicPaymentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicWalkInBooking,
          builder: (context, state) => const WalkInBookingScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicProfile,
          builder: (context, state) => const ClinicProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicEditProfile,
          builder: (context, state) => const EditClinicProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicPatientSearch,
          builder: (context, state) => const ClinicPatientSearchScreen(),
        ),
        GoRoute(
          path: AppRoutes.clinicNotifications,
          builder: (context, state) => const ClinicNotificationsScreen(),
        ),
      ],
    );
  }
}

// Stream listener for router refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _MissingAppointmentScreen extends StatelessWidget {
  const _MissingAppointmentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, color: AppColors.textTertiary, size: 64),
              const SizedBox(height: 16),
              Text(
                'No appointment details found',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please book a new appointment to continue.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Browse Doctors',
                onPressed: () => context.go(AppRoutes.patientBrowseDoctors),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Back to Home',
                isOutlined: true,
                onPressed: () => context.go(AppRoutes.patientHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// All screens implemented across auth, patient, doctor, and clinic features.
