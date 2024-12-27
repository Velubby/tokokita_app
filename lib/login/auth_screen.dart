import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/auth_service.dart';
import 'signup_screen.dart';
import '/../screens/landing/team_page.dart';

class AuthScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Sign in with Google
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      UserCredential? userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        final userId = userCredential.user?.uid;
        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeamPage(userId: userId)),
          );
        } else {
          _showError(context, 'Failed to retrieve user ID after signing in.');
        }
      }
    } catch (e) {
      _showError(context, 'Failed to sign in with Google. Please try again.');
    }
  }

  // Sign in with email and password
  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential? userCredential =
          await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (userCredential != null) {
        final userId = userCredential.user?.uid;
        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeamPage(userId: userId)),
          );
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
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Login Form
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
