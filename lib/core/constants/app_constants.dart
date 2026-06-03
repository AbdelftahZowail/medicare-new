/// Global toggle for mock data fallback in service layer.
/// Set to `true` to return hardcoded mock data when API calls fail.
/// Set to `false` (default) to let exceptions propagate.
bool useMockDataFallback = false;

class ApiEndpoints {
  static const String baseUrl = 'https://medicare.shortformfunnels.com';
  static const String apiBase = '$baseUrl/api';

  // Auth
  static const String login = '$apiBase/auth/login';
  static const String registerPatient = '$apiBase/auth/register/patient';
  static const String registerDoctor = '$apiBase/auth/register/doctor';
  static const String registerClinic = '$apiBase/auth/register/clinic';
  static const String refreshToken = '$apiBase/auth/refresh-token';
  static const String logout = '$apiBase/auth/logout';
  static const String forgotPassword = '$apiBase/auth/forgot-password';
  static const String verifyOtp = '$apiBase/auth/verify-otp';
  static const String resetPassword = '$apiBase/auth/reset-password';
  static const String socialLogin = '$apiBase/auth/social-login';
  static const String telegramRegister = '$apiBase/auth/telegram-register';

  // Patient
  static const String patientProfile = '$apiBase/patient/profile';
  static const String patientFavorites = '$apiBase/patient/favorites';
  static String patientFavorite(int doctorId) => '$apiBase/patient/favorite/$doctorId';
  static const String patientFamilyMembers = '$apiBase/patient/family-members';
  static String deleteFamilyMember(int memberId) => '$apiBase/patient/family-members/$memberId';
  static const String patientSearch = '$apiBase/patient/search';

  // Doctor (public)
  static const String doctors = '$apiBase/doctor';
  static const String doctorSpecializations = '$apiBase/doctor/specializations';
  static const String popularDoctors = '$apiBase/doctor/popular';
  static String doctorDetail(int id) => '$apiBase/doctor/$id';
  static String doctorSchedules(int id) => '$apiBase/doctor/$id/schedules';
  static String doctorAvailableSlots(int id) => '$apiBase/doctor/$id/available-slots';

  // Doctor (authenticated)
  static const String doctorProfile = '$apiBase/doctor/profile';
  static const String doctorDashboard = '$apiBase/doctor/dashboard';
  static const String doctorLiveQueue = '$apiBase/doctor/live-queue';
  static const String doctorQrCode = '$apiBase/doctor/qr-code';
  static String doctorPatientHistory(int patientId) => '$apiBase/doctor/patients/$patientId/history';
  static String doctorSession(int appointmentId) => '$apiBase/doctor/session/$appointmentId';

  // Clinic (public)
  static const String clinics = '$apiBase/clinic';
  static String clinicDetail(int id) => '$apiBase/clinic/$id';

  // Clinic (authenticated)
  static const String clinicProfile = '$apiBase/clinic/profile';
  static const String clinicDoctors = '$apiBase/clinic/doctors';
  static String clinicDoctorDetail(int doctorId) => '$apiBase/clinic/doctors/$doctorId';
  static String clinicDoctorUpdate(int doctorId) => '$apiBase/clinic/doctors/$doctorId';
  static String clinicDoctorDelete(int doctorId) => '$apiBase/clinic/doctors/$doctorId';
  static String clinicDoctorScan(String qrCodeKey) => '$apiBase/clinic/doctors/scan/$qrCodeKey';
  static const String clinicDoctorRegister = '$apiBase/clinic/doctors/register';
  static String clinicAddSchedule(int doctorId) => '$apiBase/doctor/$doctorId/schedules';

  // Appointment
  static const String appointments = '$apiBase/appointment';
  static String appointmentDetail(int id) => '$apiBase/appointment/$id';
  static String appointmentCancel(int id) => '$apiBase/appointment/$id/cancel';
  static String appointmentReschedule(int id) => '$apiBase/appointment/$id/reschedule';
  static String appointmentStatus(int id) => '$apiBase/appointment/$id/status';
  static String appointmentStartCheckup(int id) => '$apiBase/appointment/$id/start-checkup';
  static String appointmentQueueTracker(int id) => '$apiBase/appointment/queue/tracker/$id';
  static const String appointmentQueueToday = '$apiBase/appointment/queue/today';
  static const String appointmentCallNext = '$apiBase/appointment/queue/call-next';
  static const String appointmentClinicBooking = '$apiBase/appointment/clinic-booking';
  static const String appointmentClinicDashboard = '$apiBase/appointment/clinic/dashboard';
  static const String appointmentClinicQueue = '$apiBase/appointment/clinic/queue';
  static const String appointmentClinicPayments = '$apiBase/appointment/clinic/payments-dashboard';

  // Patient Appointments
  static const String patientAppointments = '$apiBase/appointment/patient';

  // Doctor Appointments
  static const String doctorAppointments = '$apiBase/appointment/doctor';

  // Review
  static const String reviews = '$apiBase/review';
  static String doctorReviews(int doctorId) => '$apiBase/review/doctor/$doctorId';

  // Community
  static const String communityPosts = '$apiBase/community/posts';
  static String communityPostComments(int postId) => '$apiBase/community/posts/$postId/comments';
  static String deleteCommunityPost(int id) => '$apiBase/community/posts/$id';
  static String deleteCommunityComment(int id) => '$apiBase/community/comments/$id';

  // Medical Record
  static const String medicalRecords = '$apiBase/medicalrecord';
  static String medicalRecordDetail(int id) => '$apiBase/medicalrecord/$id';
  static String patientMedicalRecords(int patientId) => '$apiBase/medicalrecord/patient/$patientId';

  // Notification
  static const String notifications = '$apiBase/notification';
  static const String notificationUnreadCount = '$apiBase/notification/unread-count';
  static String markNotificationRead(int id) => '$apiBase/notification/$id/read';
  static String deleteNotification(int id) => '$apiBase/notification/$id';

  // Upload
  static const String uploadLicense = '$apiBase/upload/license';
  static const String uploadProfileImage = '$apiBase/upload/profile-image';
}

class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String registerPatient = '/register/patient';
  static const String registerDoctor = '/register/doctor';
  static const String registerClinic = '/register/clinic';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';

  // Patient
  static const String patientHome = '/patient/home';
  static const String patientSpecializations = '/patient/specializations';
  static const String patientBrowseDoctors = '/patient/browse-doctors';
  static const String patientDoctorProfile = '/patient/doctor-profile';
  static const String patientBookAppointment = '/patient/book-appointment';
  static const String patientAppointmentConfirmation = '/patient/appointment-confirmation';
  static const String patientAppointments = '/patient/appointments';
  static const String patientAppointmentDetail = '/patient/appointment-detail';
  static const String patientQueueTracker = '/patient/queue-tracker';
  static const String patientCommunity = '/patient/community';
  static const String patientCreatePost = '/patient/create-post';
  static const String patientPostDetail = '/patient/post-detail';
  static const String patientProfile = '/patient/profile';
  static const String patientEditProfile = '/patient/edit-profile';
  static const String patientMedicalHistory = '/patient/medical-history';
  static const String patientFamilyMembers = '/patient/family-members';
  static const String patientAddFamilyMember = '/patient/add-family-member';
  static const String patientFavorites = '/patient/favorites';
  static const String patientNotifications = '/patient/notifications';
  static const String patientSubmitReview = '/patient/submit-review';

  // Doctor
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorAppointments = '/doctor/appointments';
  static const String doctorQueue = '/doctor/queue';
  static const String doctorPatientHistory = '/doctor/patient-history';
  static const String doctorConsultation = '/doctor/consultation';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorEditProfile = '/doctor/edit-profile';
  static const String doctorQrCode = '/doctor/qr-code';
  static const String doctorCommunity = '/doctor/community';
  static const String doctorCreatePost = '/doctor/create-post';
  static const String doctorNotifications = '/doctor/notifications';
  static const String doctorSchedule = '/doctor/schedule';

  // Clinic
  static const String clinicDashboard = '/clinic/dashboard';
  static const String clinicQueue = '/clinic/queue';
  static const String clinicDoctors = '/clinic/doctors';
  static const String clinicDoctorDetail = '/clinic/doctor-detail';
  static const String clinicScanQr = '/clinic/scan-qr';
  static const String clinicRegisterDoctor = '/clinic/register-doctor';
  static const String clinicManageSchedule = '/clinic/manage-schedule';
  static const String clinicPayments = '/clinic/payments';
  static const String clinicWalkInBooking = '/clinic/walk-in-booking';
  static const String clinicProfile = '/clinic/profile';
  static const String clinicEditProfile = '/clinic/edit-profile';
  static const String clinicPatientSearch = '/clinic/patient-search';
  static const String clinicNotifications = '/clinic/notifications';
}

class AssetPaths {
  static const String images = 'assets/images';
  static const String icons = 'assets/icons';
  static const String fonts = 'assets/fonts';

  // Auth / Brand
  static const String logo = '$images/app_logo.png';
  static const String onboarding1 = '$images/onboarding_1.png';
  static const String onboarding2 = '$images/onboarding_2.png';
  static const String onboarding3 = '$images/onboarding_3.png';

  // Illustrations
  static const String illustrationOnlineDoctor = '$images/illustration_online_doctor.png';
  static const String illustrationDoctorsCuate = '$images/illustration_doctors_cuate.png';
  static const String illustrationOnlineDoctor2 = '$images/illustration_online_doctor_2.png';

  // Doctor Photos
  static const String doctorPhoto1 = '$images/doctor_photo_1.png';
  static const String doctorPhoto2 = '$images/doctor_photo_2.png';
  static const String doctorPhoto3 = '$images/doctor_photo_3.png';
  static const String doctorPhoto4 = '$images/doctor_photo_4.png';
  static const String doctorPhotoFavorite = '$images/doctor_photo_favorite.png';
  static const String doctorJulian = '$images/doctor_julian.png';
  static const String doctorJulian2 = '$images/doctor_julian_2.png';
  static const String drJamesWilson = '$images/dr_james_wilson.png';
  static const String drSarahChen = '$images/dr_sarah_chen.png';
  static const String drSarahChen2 = '$images/dr_sarah_chen_2.png';
  static const String sarahJohnson = '$images/sarah_johnson.png';
  static const String emilyDavis = '$images/emily_davis.png';

  // Family Members
  static const String familyMember1 = '$images/family_member_1.png';
  static const String familyMember2 = '$images/family_member_2.png';
  static const String familyMember3 = '$images/family_member_3.png';

  // Clinic
  static const String clinicImage1 = '$images/clinic_image_1.png';
  static const String clinicImage2 = '$images/clinic_image_2.png';

  // Patients
  static const String patientProfile1 = '$images/patient_profile_1.png';
  static const String patientProfile2 = '$images/patient_profile_2.png';

  // Services
  static const String clinicBooking = '$images/illustration_online_doctor.png';

  // Empty States
  static const String emptyAppointments = '$images/illustration_online_doctor.png';
  static const String emptyCommunity = '$images/illustration_doctors_cuate.png';
  static const String emptyNotifications = '$images/illustration_online_doctor_2.png';
  static const String emptyDoctors = '$images/illustration_doctors_cuate.png';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String profileId = 'profile_id';
  static const String userName = 'user_name';
  static const String isFirstTime = 'is_first_time';
  static const String language = 'language';
}

class AppConstants {
  static const List<String> specializations = [
    'Cardiology',
    'Dentistry',
    'Dermatology',
    'ENT',
    'General Practice',
    'Internal Medicine',
    'Neurology',
    'Ophthalmology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
  ];
}

class AppEnums {
  // UserRole
  static const int patient = 0;
  static const int doctor = 1;
  static const int clinicAdmin = 2;

  // Gender
  static const int male = 0;
  static const int female = 1;

  // AppointmentStatus
  static const int pending = 0;
  static const int confirmed = 1;
  static const int inProgress = 2;
  static const int completed = 3;
  static const int cancelled = 4;
  static const int noShow = 5;

  // QueueStatus
  static const int waiting = 0;
  static const int inConsultation = 1;
  static const int queueCompleted = 2;
  static const int refunded = 3;

  // RefundStatus
  static const int none = 0;
  static const int pendingRefund = 1;
  static const int processed = 2;

  // PaymentMethod
  static const int cash = 0;
  static const int online = 1;

  // RelationType
  static const int parent = 0;
  static const int child = 1;
  static const int spouse = 2;
  static const int sibling = 3;
  static const int other = 4;
}
