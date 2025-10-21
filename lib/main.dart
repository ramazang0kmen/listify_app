import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:listify_application/screens/auth_start_screen.dart';
import 'package:listify_application/screens/email_login_screen.dart';
import 'package:listify_application/screens/email_register_screen.dart';
import 'package:listify_application/screens/onboarding_screen.dart';
import 'package:listify_application/screens/splash_screen.dart';
import 'package:listify_application/stores/user_store.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ListifyApp());
}

class ListifyApp extends StatelessWidget {
  const ListifyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserStore()),
        // ... diğer store'ların
      ],
      child: MaterialApp(
        title: 'Listify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          OnboardingScreen.route: (_) => const OnboardingScreen(),
          AuthStartScreen.route: (_) => const AuthStartScreen(),
          EmailLoginScreen.route: (_) => const EmailLoginScreen(),
          EmailRegisterScreen.route: (_) => const EmailRegisterScreen(),
          // UsernameScreen.route: (_) => const UsernameScreen(),
          // ProfilePhotoScreen.route: (_) => const ProfilePhotoScreen(),
          // HomeScreen.route: (_) => const HomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}