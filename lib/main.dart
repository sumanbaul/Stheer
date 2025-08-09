import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifoo/src/helper/provider/google_sign_in.dart';
import 'package:notifoo/src/helper/provider/firebase_provider.dart';
import 'package:notifoo/src/helper/routes/routes.dart';
import 'src/helper/DatabaseHelper.dart';
import 'package:provider/provider.dart';
import 'package:notifoo/src/services/firebase_service.dart';
import 'package:notifoo/src/services/push_notification_service.dart';

import 'package:firebase_core/firebase_core.dart';

Future main() async {
  //Init all required async components
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "sandbox-api-key",
        authDomain: "sandbox-project.firebaseapp.com",
        projectId: "sandbox-project",
        storageBucket: "sandbox-project.appspot.com",
        messagingSenderId: "123456789",
        appId: "1:123456789:web:sandbox-app-id",
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed (sandbox mode): $e');
    // Continue without Firebase for sandbox mode
  }
  
  await DatabaseHelper.instance.initializeDatabase();

  // Initialize Firebase service
  try {
    await FirebaseService().initialize();
    print('Firebase service initialized successfully');
  } catch (e) {
    print('Firebase service initialization failed: $e');
    // Continue without Firebase service for sandbox mode
  }

  // Initialize Push Notification service
  try {
    await PushNotificationService().initialize();
    print('Push notification service initialized successfully');
  } catch (e) {
    print('Push notification service initialization failed: $e');
    // Continue without push notifications for sandbox mode
  }

  //Initialize Hive
  await Hive.initFlutter();
  //open a box
  await Hive.openBox("Habit_Database");
  await Hive.openBox("User_Database");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => GoogleSignInProvider()),
          ChangeNotifierProvider(create: (context) => FirebaseProvider()),
        ],
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Color(0xFF1A1A1A),
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FocusFluke',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF6366F1),
                brightness: Brightness.dark,
                surface: Color(0xFF1A1A1A),
                primary: Color(0xFF6366F1),
                secondary: Color(0xFF8B5CF6),
                tertiary: Color(0xFF06B6D4),
                error: Color(0xFFEF4444),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.white,
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.dark().textTheme,
              ),
              cardTheme: CardThemeData(
                color: Color(0xFF1F1F1F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            initialRoute: '/',
            routes: Routes().getRoute(),
          ),
        ),
      );
}
