import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/user/user_home_page.dart';
import 'pages/admin/admin_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_settings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Bharathi Store',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF094D22),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF094D22)),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF094D22),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data() as Map<String, dynamic>;
                final bool isActive = data['isActive'] ?? true;
                
                if (!isActive) {
                  // Account deactivated by admin
                  FirebaseAuth.instance.signOut();
                  return const LoginPage(showAccountDeletedPopup: true);
                }

                final role = data['role'] ?? 'user';
                if (role == 'admin') {
                  return const AdminHomePage();
                }
                return const UserHomePage();
              } else if (userSnapshot.hasData && !userSnapshot.data!.exists) {
                // Account deleted by admin from Firestore but still logged into Auth
                FirebaseAuth.instance.signOut();
                return const LoginPage(showAccountDeletedPopup: true);
              }
              
              // Handle error or unexpected state
              return const LoginPage();
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}
