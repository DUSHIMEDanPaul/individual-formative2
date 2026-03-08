import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'models/listing.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/edit_listing_screen.dart';
import 'screens/add_listing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: const RestoKigaliApp(),
    ),
  );
}

class RestoKigaliApp extends StatelessWidget {
  const RestoKigaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'resto_kigali',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/listingDetail':
            final listing = settings.arguments as Listing;
            return MaterialPageRoute(
              builder: (context) => ListingDetailScreen(listing: listing),
            );
          case '/editListing':
            final listing = settings.arguments as Listing;
            return MaterialPageRoute(
              builder: (context) => EditListingScreen(listing: listing),
            );
          case '/addListing':
            return MaterialPageRoute(
              builder: (context) => const AddListingScreen(),
            );
          default:
            return null;
        }
      },
    );
  }
}

/// The AuthWrapper listens to the Firebase Auth Stream
/// and decides which screen to show:
/// 1. Logged out -> LoginScreen
/// 2. Logged in, not verified -> EmailVerificationScreen
/// 3. Logged in, verified -> HomeScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        authProvider.loadUserProfile();
        return const HomeScreen();
      },
    );
  }
}

/// A branded splash screen shown while Firebase initializes
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 80, color: AppTheme.accentGold),
            const SizedBox(height: 24),
            const Text(
              'resto_kigali',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover Kigali',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}