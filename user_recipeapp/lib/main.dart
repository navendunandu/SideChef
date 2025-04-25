import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_recipeapp/screens/homepage.dart';
import 'package:user_recipeapp/screens/login.dart';

Future<void> main() async {
await Supabase.initialize(
    url: 'https://bccvuozwzubyroravvfy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjY3Z1b3p3enVieXJvcmF2dmZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDQxMzksImV4cCI6MjA1MjY4MDEzOX0.SZawCn1apwm50RPhI-S9EDKzr218Ec34lx326P2JGB8',
  );
  runApp(const MainApp());
}
// Get a reference your Supabase client
final supabase = Supabase.instance.client;
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      
   );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final session = supabase.auth.currentSession;

    if (session != null) {
      // User is logged in, navigate to HomePage
      return HomePage();
    } else {
      // User is not logged in, navigate to LandingPage
      return Login();
    }
  }
}
