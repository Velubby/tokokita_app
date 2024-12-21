import 'package:flutter/material.dart';
import 'package:tokokita_app/screens/home/home_common/row_render_container.dart';
import 'package:tokokita_app/screens/home/invite/invite_page.dart';

class HomeInvite extends StatelessWidget {
  const HomeInvite({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambahkan anggota',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
        ),
        RowRenderContainer(
          assetsSvg: 'invite.svg',
          title: 'Tambahkan anggota ke tim',
          msg: 'Tambahkan anggota ke tim',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const InvitePage()), // Navigate to Invite Page
            );
          },
        )
      ],
    );
  }
}
