import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key, required Map<String, dynamic> userData});

  @override
  _DetailProfilePageState createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Memuat data pengguna dari Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        _nameController.text = userData['name'];
        _emailController.text = userData['email'];
        setState(() {});
      }
    }
  }

  // Mengupdate data pengguna di Firestore
  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  // Fungsi untuk logout pengguna
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Redirect ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Foto Profil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(
                        'assets/images/default_profile.jpg'), // Ganti jika foto profil ada
                    backgroundColor: Colors.grey[200],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        // Logika untuk mengubah foto profil
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nama
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
              ),
            ),
            const SizedBox(height: 16),

            // Email (Masuk dengan)
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Masuk dengan (Email)',
              ),
              enabled: false, // Email hanya bisa dilihat, tidak bisa diedit
            ),
            const SizedBox(height: 16),

            // Tombol Ganti Password
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman untuk mengganti password
                Navigator.pushNamed(context,
                    '/change-password'); // Ganti dengan route yang sesuai untuk mengganti password
              },
              child: const Text('Ganti Password'),
            ),
            const SizedBox(height: 16),

            // Tombol Simpan
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 16),

            // Tombol Logout
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
