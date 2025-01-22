import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/auth_service.dart';
import 'signup_screen.dart';
import '../screens/onboard/onboard.dart';
import '../screens/onboard/team_page.dart';

class AuthScreen extends StatelessWidget {
  final AuthService _authService;

  AuthScreen({Key? key, AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _checkOnboardingAndNavigate(
      BuildContext context, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
    print("Onboarding completed: $onboardingCompleted");

    // Check if user has a team
    bool hasTeam = await _checkUserHasTeam(userId);
    print("User has a team: $hasTeam");

    // For new users or users without a team, always show onboarding
    if (!hasTeam) {
      // Reset onboarding status for new users
      await prefs.setBool('onboardingCompleted', false);
      onboardingCompleted = false;
    }

    if (!onboardingCompleted) {
      // Navigate to OnboardingScreen for new users or users who haven't completed onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(userId: userId),
        ),
      );
    } else if (hasTeam) {
      // Only navigate to TeamPage if user has completed onboarding AND has a team
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TeamPage(
            userId: userId,
            teamId: '',
          ),
        ),
      );
    } else {
      // If onboarding is complete but no team exists, go to team creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TeamPage(
            userId: userId,
            teamId: '',
          ),
        ),
      );
    }
  }

  // Method to check if the user has a team
  Future<bool> _checkUserHasTeam(String userId) async {
    // Assuming there's a Firestore collection that holds teams
    var teamsCollection = FirebaseFirestore.instance.collection('teams');
    var userTeams =
        await teamsCollection.where('userId', isEqualTo: userId).get();

    // Debugging print
    print("Teams found for user: ${userTeams.docs.length}");

    return userTeams.docs.isNotEmpty; // Check if the user has any teams
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      UserCredential? userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        final userId = userCredential.user?.uid;
        if (userId != null) {
          await _checkOnboardingAndNavigate(context, userId);
        } else {
          _showError(context, 'Failed to retrieve user ID after signing in.');
        }
      }
    } catch (e) {
      _showError(context, 'Failed to sign in with Google. Please try again.');
    }
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError(context, 'Please fill in both email and password.');
      return;
    }

    try {
      UserCredential? userCredential =
          await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (userCredential != null) {
        final userId = userCredential.user?.uid;
        if (userId != null) {
          await _checkOnboardingAndNavigate(context, userId);
        } else {
          _showError(context, 'Failed to retrieve user ID after signing in.');
        }
      }
    } catch (e) {
      _showError(context, 'Failed to sign in. Please check your credentials.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Toko Kita',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Aplikasi Pencatatan Stok Barang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _signInWithEmailAndPassword(context),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _signInWithGoogle(context),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logos/google_logo.png',
                            height: 22,
                            width: 22,
                          ),
                          SizedBox(width: 10),
                          Text('Sign in with Google'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text('First time on Toko Kita? Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
