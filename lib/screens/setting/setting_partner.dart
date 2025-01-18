import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tokokita_app/screens/setting/partner/customer_page.dart';
import 'package:tokokita_app/screens/setting/setting_partner_row.dart';
import 'package:tokokita_app/screens/setting/partner/supplier_page.dart';

class PartnerSettingsSection extends StatelessWidget {
  final String teamId;

  const PartnerSettingsSection({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('suppliers')
          .where('teamId', isEqualTo: teamId)
          .snapshots(),
      builder: (context, suppliersSnapshot) {
        if (suppliersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (suppliersSnapshot.hasError) {
          return Center(child: Text('Error: ${suppliersSnapshot.error}'));
        }

        final supplierCount = suppliersSnapshot.data!.docs.length;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('customers')
              .where('teamId', isEqualTo: teamId)
              .snapshots(),
          builder: (context, customersSnapshot) {
            if (customersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (customersSnapshot.hasError) {
              return Center(child: Text('Error: ${customersSnapshot.error}'));
            }

            final customerCount = customersSnapshot.data!.docs.length;

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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupplierPage(
                            teamId: teamId,
                            userId:
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                        ),
                      );
                    },
                    child: PartnerRow(
                      title: 'Suppliers',
                      value: '$supplierCount suppliers',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerPage(
                            teamId: teamId,
                            userId:
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                        ),
                      );
                    },
                    child: PartnerRow(
                      title: 'Customers',
                      value: '$customerCount customers',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
