import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// AUTH SCREENS
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';

// PET ONBOARDING SCREENS
import 'screens/pet_info1_screen.dart';
import 'screens/pet_info2_screen.dart';
import 'screens/pet_summary_screen.dart';

// TASK SCREENS
import 'screens/daily_tasks_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/edit_task_screen.dart';

// CALENDAR SCREEN (⭐ NEW WORKING SCREEN)
import 'screens/calendar_screen.dart';

// PET SCREENS
import 'screens/pets_home_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/edit_pet_screen.dart';

// SETTINGS SCREEN
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ IMPORTANT: Firebase must be initialized with explicit options on Web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBSRCykcI3V4SB2ZYY8cBHezY7wUJLDlE4",
      authDomain: "petminder-app.firebaseapp.com",
      projectId: "petminder-app",
      storageBucket: "petminder-app.firebasestorage.app",
      messagingSenderId: "210515344792",
      appId: "1:210515344792:web:85e3b08b25ac610fa2ffed",
      measurementId: "G-MVBQZJE8FV",
    ),
  );

  runApp(const PetMinderApp());
}

class PetMinderApp extends StatelessWidget {
  const PetMinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pet Minder",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),

      // ⭐ STARTING SCREEN
      initialRoute: "/splash",

      routes: {
        // ---------------- AUTH ----------------
        "/splash": (context) => const SplashScreen(),
        "/signin": (context) => const SignInScreen(),
        "/signup": (context) => const SignUpScreen(),

        // ----------- PET ONBOARDING -----------
        "/petinfo1": (context) => const PetInfo1Screen(),
        "/petinfo2": (context) => const PetInfo2Screen(),
        "/summary": (context) => const PetSummaryScreen(),

        // ---------------- TASKS ----------------
        "/tasks": (context) => const DailyTasksScreen(),
        "/createTask": (context) => const CreateTaskScreen(),
        "/editTask": (context) => const EditTaskScreen(),

        // ---------------- CALENDAR ----------------
        "/calendar": (context) => const CalendarScreen(),

        // ---------------- PETS ----------------
        "/pets": (context) => const PetsHomeScreen(),
        "/petDetail": (context) => const PetDetailScreen(),
        "/editPet": (context) => const EditPetScreen(),

        // -------------- SETTINGS ---------------
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}
