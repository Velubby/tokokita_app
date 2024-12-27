import 'package:tokokita_app/screens/navbar/home.dart';
import 'package:tokokita_app/screens/navbar/in_and_out.dart';
import 'package:tokokita_app/screens/navbar/product.dart';
import 'package:tokokita_app/screens/navbar/setting.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required String userId, required String teamId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const ProductScreen(),
    const InAndOutScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Barang'),
          BottomNavigationBarItem(
              icon: Transform.rotate(
                  angle: 3.14159 / 2, // Rotate 90 degrees (π/2 radians)
                  child: Icon(Icons.compare_arrows_rounded)),
              label: 'Keluar/Masuk'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
