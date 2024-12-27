import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../setting/detail_profile.dart'; // Pastikan halaman DetailProfilePage sudah dibuat

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>;
            final user = FirebaseAuth.instance.currentUser;

            return ListView(
              children: [
                // Profile Section
                _buildProfileSection(userData, user, context),
                const SizedBox(height: 20),

                // Manage Team Section
                _buildManageTeamSection(),
                const SizedBox(height: 20),

                // Partner Settings Section
                _buildPartnerSettingsSection(),
                const SizedBox(height: 20),

                // Low Stock Notification Section
                _buildLowStockNotificationSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      Map<String, dynamic> userData, User? user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: userData['photoUrl'] != null
                ? NetworkImage(userData['photoUrl'])
                : const AssetImage('assets/images/default_profile.jpg')
                    as ImageProvider,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData['name'] ?? 'No Name',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                userData['email'] ?? 'No Email',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigasi ke halaman pengeditan profil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailProfilePage(
                      userData:
                          userData), // Kirimkan data user ke halaman detail
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManageTeamSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Team',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildTeamRow('Nama Tim', 'Sparepart Otomotif'),
          _buildTeamRow('Katalog', 'blablabla'),
          _buildTeamRow('Anggota', '1 Orang'),
          _buildTeamRow('Hak Kelola', 'Admin'),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(value),
      onTap: () {
        // Tambahkan logika untuk navigasi atau aksi lainnya
      },
    );
  }

  Widget _buildPartnerSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partner Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPartnerRow('Supplier', '1 supplier'),
          _buildPartnerRow('Customer', '1 customer'),
        ],
      ),
    );
  }

  Widget _buildPartnerRow(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(value),
      onTap: () {
        // Tambahkan logika untuk navigasi atau aksi lainnya
      },
    );
  }

  Widget _buildLowStockNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Low Stock Notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Notifikasi'),
            value: true, // Misalnya, status notifikasi aktif
            onChanged: (bool value) {
              // Tambahkan logika untuk mengubah status notifikasi
            },
          ),
          _buildTimeRow('Jam', '10 AM'),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(value),
      onTap: () {
        // Tambahkan logika untuk memilih waktu
      },
    );
  }
}
