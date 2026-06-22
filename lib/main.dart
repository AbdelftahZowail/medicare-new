import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'core/bloc/auth_bloc.dart';
import 'core/navigation/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/fcm_background_handler.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  ApiService().initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler before runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize FCM (token registration, permission request, handlers)
  await FcmService().init();

  runApp(const MedicareApp());
}

class MedicareApp extends StatefulWidget {
  const MedicareApp({super.key});

  @override
  State<MedicareApp> createState() => _MedicareAppState();
}

class _MedicareAppState extends State<MedicareApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authService: AuthService());
    _router = AppRouter.createRouter(_authBloc);
    _authBloc.add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _authBloc,
      child: MaterialApp.router(
        title: 'Medicare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('en', 'US'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ar', 'EG'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router,
      ),
    );
  }
}
