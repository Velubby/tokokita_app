import 'package:flutter/material.dart';
import 'package:tokokita_app/services/notification_service.dart';
import 'notification/notification_page.dart';

class HomeNotification extends StatefulWidget {
  const HomeNotification({super.key});

  @override
  _HomeNotificationState createState() => _HomeNotificationState();
}

class _HomeNotificationState extends State<HomeNotification> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, String>>>(
          stream: _notificationService.getUpdates(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching updates'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No updates available.'));
            }

            var updates = snapshot.data!;

            return ListView.builder(
              itemCount: updates.length,
              itemBuilder: (context, index) {
                return _buildUpdateCard(context, updates[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // _buildUpdateCard now accepts a Map<String, String> as argument
  Widget _buildUpdateCard(BuildContext context, Map<String, String> update) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              update['title']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              update['subtitle']!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              update['msg']!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to NotificationPage when tapping on the card
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(
                      update:
                          update, // Pass the selected update to NotificationPage
                    ),
                  ),
                );
              },
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
