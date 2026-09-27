import 'package:doofy/auth/auth_wrapper.dart';
import 'package:doofy/firebase_options.dart';
import 'package:doofy/helpers/hive_init.dart';
import 'package:doofy/helpers/seed_helper.dart';
import 'package:doofy/onboard.dart';
import 'package:doofy/auth/login.dart';
import 'package:doofy/auth/register.dart';
import 'package:doofy/screens/allergy_setup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  await HiveInit.initHive();

  await SeedHelper.seedAllergens();

// ths was uswd to create the allergen db in firestore
    // await FirestoreSeeder.seedAllergens();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doofy',
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboard',
      routes: {
        '/authWrapper': (_) => AuthWrapper(),
        '/onboard': (_) => const Onboard(),
        '/register': (_) => const RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/allergySetup': (_) => const AllergySetupScreen(),
      },
    );
  }
}
