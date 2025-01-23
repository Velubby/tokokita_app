import 'package:flutter/material.dart';
import 'package:tokokita_app/screens/onboard/team_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login/auth_screen.dart';
import '/screens/home_screen.dart';

void main() async {
  initializeDateFormatting('id_ID');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Kita',
      theme: ThemeData(
        fontFamily: 'CookieRun',
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/home': (context) => const HomeScreen(
              userId: '',
              teamId: '',
            ),
        '/team': (context) => const TeamPage(
              userId: '',
              teamId: '',
            ),
      },
    );
  }
}
