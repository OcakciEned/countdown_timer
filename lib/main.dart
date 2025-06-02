import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:countdown_timer/pages/home_screen.dart';
import 'package:countdown_timer/pages/add_counter.dart';
import 'package:countdown_timer/pages/past_counters_page.dart';
import 'package:countdown_timer/pages/profile_page.dart';
import 'package:countdown_timer/pages/auth/login_page.dart';
import 'package:countdown_timer/pages/auth/register_page.dart';
import 'firebase_options.dart';
import 'package:countdown_timer/pages/missing_information.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://wjpunevvevxnafgatkvd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqcHVuZXZ2ZXZ4bmFmZ2F0a3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2ODI5OTksImV4cCI6MjA2NDI1ODk5OX0.IsaIPFF2JnFjsX_r9f7EJqIkXg4yrKZ7ZRnqFnmnpE0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Countdown Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<fb.User?>(
        stream: fb.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
      routes: {
        '/home_page': (context) => const HomePage(),
        '/login_page': (context) => LoginPage(),
        '/register_page': (context) => const RegisterPage(),
        '/add_counter': (context) => const AddCounter(),
        '/Past_Counters': (context) => const PastCounters(),
        '/missing_info': (context) => const missinginfo(),
        '/profile_page': (context) => const ProfilePage(),
      },
    );
  }
}
