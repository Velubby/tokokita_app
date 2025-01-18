import 'package:flutter/material.dart';

class PartnerInfoPage extends StatelessWidget {
  final String partnerId;
  final String partnerName;
  final String partnerPhone;
  final String partnerEmail;
  final String
      partnerType; // Add a type to distinguish between customer and supplier
  final Function(String) onEdit;
  final Function(String) onDelete;

  const PartnerInfoPage({
    Key? key,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.partnerEmail,
    required this.partnerType, // Accept partner type
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$partnerName'), // Use partner name in the title
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => onEdit(partnerId),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Confirm deletion
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete $partnerType'),
                    content: Text(
                        'Are you sure you want to delete this $partnerType?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete(partnerId); // Call the delete function
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context)
                              .pop(); // Redirect to the previous page
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partner Info',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Name:',
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                Text(partnerName, style: TextStyle(fontSize: 15)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone:',
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                Text(partnerPhone, style: TextStyle(fontSize: 15)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email:',
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
                Text(partnerEmail, style: TextStyle(fontSize: 15)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
