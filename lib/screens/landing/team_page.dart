import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokokita_app/screens/home_screen.dart';

class TeamPage extends StatefulWidget {
  final String userId;

  TeamPage({required this.userId});

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  bool _isDialogVisible = false; // To control whether the dialog is visible

  // Controller for the team name input field
  final TextEditingController _teamNameController = TextEditingController();

  Future<int> _getItemCount(String teamId) async {
    final QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .collection('items')
        .get();
    return itemsSnapshot.docs.length;
  }

  // Show the Create Team dialog and grey out the background
  void _showCreateTeamDialog() {
    setState(() {
      _isDialogVisible = true;
    });
  }

  // Close the dialog
  void _closeCreateTeamDialog() {
    setState(() {
      _isDialogVisible = false;
    });
  }

  // Save the team to Firestore
  void _createTeam(BuildContext context) async {
    final teamName = _teamNameController.text.trim();

    if (teamName.isNotEmpty) {
      // Add the team to Firestore
      await FirebaseFirestore.instance.collection('teams').add({
        'userId': widget.userId,
        'teamName': teamName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear the text field after adding the team
      _teamNameController.clear();

      // Close the dialog after saving
      _closeCreateTeamDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team name cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Team"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          TextButton(
            onPressed: _showCreateTeamDialog, // Show the Create Team dialog
            child: Text(
              "Create Team",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content (teams list)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .where('userId', isEqualTo: widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No teams found. Create a new team!",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              final teams = snapshot.data!.docs;

              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final teamId = team.id;
                  final teamName = team['teamName'];

                  return FutureBuilder<int>(
                    future: _getItemCount(teamId),
                    builder: (context, itemSnapshot) {
                      final itemCount = itemSnapshot.data ?? 0;

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            teamName,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("$itemCount items"),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to the home screen with the selected team
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                      userId: widget.userId, teamId: teamId),
                                ),
                              );
                            },
                            child: Text("Select"),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          // If the dialog is visible, show a greyed-out overlay on the background
          if (_isDialogVisible)
            GestureDetector(
              onTap:
                  _closeCreateTeamDialog, // Close the dialog if tapping outside
              child: Container(
                color: Colors.black.withOpacity(0.5), // Grey overlay
              ),
            ),

          // Create Team dialog
          if (_isDialogVisible)
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row to align "Create New Team" and the X button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create New Team',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _teamNameController.clear();
                              _closeCreateTeamDialog();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _teamNameController,
                        decoration: InputDecoration(
                          labelText: 'Team Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _createTeam(context),
                        child: Text("Create Team"),
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
