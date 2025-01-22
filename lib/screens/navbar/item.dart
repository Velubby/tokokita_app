import 'package:flutter/material.dart';
import 'package:tokokita_app/screens/product/item_page.dart';
import 'package:tokokita_app/services/team_selection_service.dart';
import 'dart:async';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TeamSelectionService _teamSelectionService = TeamSelectionService();
  String? _teamId;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSelectedTeam();

    // Menambahkan periodic timer untuk mengecek perubahan tim
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      try {
        final teamDetails = await _teamSelectionService.getSelectedTeam();
        final newTeamId = teamDetails['teamId'];

        if (newTeamId != _teamId) {
          // Hanya update state jika teamId berubah
          if (mounted) {
            setState(() {
              _teamId = newTeamId;
            });
          }
        }
      } catch (e) {
        print('Error checking team updates: $e');
      }
    });
  }

  Future<void> _loadSelectedTeam() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final teamDetails = await _teamSelectionService.getSelectedTeam();
      final teamId = teamDetails['teamId'];

      if (teamId != null) {
        setState(() {
          _teamId = teamId;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Tidak ada tim yang dipilih';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSelectedTeam,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_teamId == null) {
      return const Center(
        child: Text('Silakan pilih tim terlebih dahulu'),
      );
    }

    return ItemsPage(teamId: _teamId!);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Membersihkan timer saat widget di dispose
    super.dispose();
  }
}
