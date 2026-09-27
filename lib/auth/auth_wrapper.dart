import 'package:doofy/auth/login.dart';
import 'package:doofy/dashboard.dart';
import 'package:doofy/models/allergy_profile.dart';
import 'package:doofy/screens/allergy_setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // still waiting for Firebase
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        // not logged in
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginPage();
        }

        // logged in — check allergy profile
        return const _ProfileChecker();
      },
    );
  }
}

class _ProfileChecker extends StatefulWidget {
  const _ProfileChecker();

  @override
  State<_ProfileChecker> createState() => _ProfileCheckerState();
}

class _ProfileCheckerState extends State<_ProfileChecker> {
  bool _checking = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final box = Hive.box<AllergyProfile>('profile');
      final profile = box.get('currentUser');

      setState(() {
        _hasProfile = profile != null;
        _checking = false;
      });
    } catch (e) {
      // If anything goes wrong send to setup screen
      setState(() {
        _hasProfile = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const _SplashLoader();

    return _hasProfile ? const Dashboard() : const AllergySetupScreen();
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E2),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AllergyAlert',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF388E3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
