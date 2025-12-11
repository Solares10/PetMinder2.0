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
import 'screens/calendar_filter_screen.dart';
import 'screens/calendar_minimized_screen.dart';

// PET SCREENS
import 'screens/pets_home_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/edit_pet_screen.dart';

// SETTINGS
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint('FIREBASE INIT ERROR: $e');
    debugPrintStack(stackTrace: st);
  }

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

      // START OF APP
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
        "/calendarFilter": (context) => const CalendarFilterScreen(),
        "/calendarMini": (context) => const CalendarMinimizedScreen(),

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

