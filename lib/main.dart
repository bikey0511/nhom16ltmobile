import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'utils/constants.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/chat_screen.dart';
import 'screens/customer/services_screen.dart';
import 'screens/customer/cleaners_list_screen.dart';
import 'screens/customer/account_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'booking_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Guard: if an authenticated user exists and is marked disabled in Firestore, sign them out immediately.
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final disabled = doc.exists ? (doc.data()?['disabled'] ?? false) as bool : false;
      if (disabled) {
        await FirebaseAuth.instance.signOut();
        debugPrint('Auto-signed-out disabled user: ${user.uid}');
      }
    } catch (e) {
      debugPrint('Error checking disabled flag on authStateChanges: $e');
    }
  });
  // Production: no automatic dev/admin creation here.

  runApp(const MainApp());
}

// Note: dev admin creation removed to avoid creating test accounts at app start.

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoClean - Đặt dịch vụ vệ sinh',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: {
        '/chat': (_) => const ChatScreen(),
        '/history': (_) => const HomeScreen(initialIndex: 1),
        '/services': (_) => const ServicesScreen(),
        '/cleaners': (_) => const CleanersListScreen(),
        '/booking': (_) => const BookingForm(),
        '/account': (_) => const AccountScreen(),
        '/staff': (_) => const AdminDashboardScreen(), // admin replaces staff route
  // dev create-admin route removed for production
      },
    );
  }
}

// Entry tối giản: vào thẳng HomeScreen, routes khai báo ở trên
