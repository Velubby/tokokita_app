import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/auth_service.dart'; // Import AuthService
import '/services/firestore_service.dart'; // Import FirestoreService
import '/models/user_model.dart' as app_model; // Import UserModel

class SignupPage extends StatelessWidget {
  final AuthService _authService = AuthService(); // Use AuthService
  final FirestoreService _firestoreService =
      FirestoreService(); // Use FirestoreService

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _signUpWithEmailAndPassword(BuildContext context) async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    UserCredential? userCredential =
        await _authService.signUpWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (userCredential != null) {
      // Create UserModel instance
      app_model.User user = app_model.User(
        userId: userCredential.user?.uid ?? '',
        email: userCredential.user?.email ?? '',
        name: _fullNameController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestoreService.saveUser(user);
      Navigator.pop(context); // Go back to the login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
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
                      'Create your account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
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
                      onPressed: () => _signUpWithEmailAndPassword(context),
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
                        'Sign Up',
                        style: TextStyle(fontSize: 16),
                      ),
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
