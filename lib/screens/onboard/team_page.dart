import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokokita_app/screens/home_screen.dart';
import 'package:tokokita_app/services/team_selection_service.dart';

class TeamPage extends StatefulWidget {
  final String userId;
  final String? teamId;
  final bool isFromLogin;

  const TeamPage({
    Key? key,
    required this.userId,
    this.teamId,
    this.isFromLogin = false,
  }) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TeamSelectionService _teamSelectionService = TeamSelectionService();

  // Create Team Method
  Future<void> _createTeam() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Create team document
        final teamRef =
            await FirebaseFirestore.instance.collection('teams').add({
          'userId': user.uid,
          'teamName': _teamNameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Save the newly created team as selected
        await _teamSelectionService.saveSelectedTeam(
            teamId: teamRef.id,
            teamName: _teamNameController.text.trim(),
            userId: user.uid);

        _teamNameController.clear();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating team: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show Create Team Bottom Sheet
  void _showCreateTeamBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create New Team',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a team name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createTeam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Create Team'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isFromLogin,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (widget.isFromLogin) {
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing
            builder: (context) => AlertDialog(
              title: const Text('Select a Team'),
              content: const Text('You must select a team to proceed.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Your Team'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showCreateTeamBottomSheet,
              tooltip: 'Create Team',
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .where('userId', isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      'Error loading teams',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('${snapshot.error}'),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final teams = snapshot.data?.docs ?? [];
            if (teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_add, size: 100, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      'No Teams Yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Create your first team to get started',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showCreateTeamBottomSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Team'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final teamId = team.id;
                final teamName = team['teamName'] ?? 'Unnamed Team';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      teamName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    // Menggunakan StreamBuilder untuk menghitung items dari collection items
                    subtitle: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('items') // Collection items terpisah
                          .where('teamId',
                              isEqualTo: teamId) // Filter berdasarkan teamId
                          .snapshots(),
                      builder: (context, itemSnapshot) {
                        if (itemSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[400]!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Menghitung barang...'),
                            ],
                          );
                        }

                        if (itemSnapshot.hasError) {
                          return Text(
                            'Error: ${itemSnapshot.error}',
                            style: TextStyle(color: Colors.red[400]),
                          );
                        }

                        final itemCount = itemSnapshot.data?.docs.length ?? 0;
                        return Text(
                          '$itemCount barang',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _teamSelectionService.saveSelectedTeam(
                            teamId: teamId,
                            teamName: teamName,
                            userId: widget.userId,
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                userId: widget.userId,
                                teamId: teamId,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error selecting team: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
