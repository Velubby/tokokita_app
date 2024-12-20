import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomeCalendar extends StatelessWidget {
  HomeCalendar({super.key, required this.isNow});
  bool isNow;

  @override
  Widget build(BuildContext context) {
    String formattedDate;

    DateTime now = DateTime.now();
    if (isNow) {
      formattedDate = '${now.day} ${_getMonthAbbreviation(now.month)}';
    } else {
      formattedDate = '${now.day - 1} ${_getMonthAbbreviation(now.month)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(isNow ? 'Hari Ini' : 'Kemarin',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 10),
            Text(formattedDate, style: const TextStyle(color: Colors.white38)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _renderContainer(0, 'Total', true),
            _renderContainer(0, 'Stok Masuk', true),
            _renderContainer(0, 'Stok Keluar', false),
          ],
        ),
      ],
    );
  }

  // Get the 3-letter abbreviation for the month
  String _getMonthAbbreviation(int month) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1]; // months are 1-indexed
  }

  // Render individual container for the statistics (Total, Stok Masuk, Stok Keluar)
  Widget _renderContainer(int total, String content, bool isEnd) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$total',
                  style: const TextStyle(color: Colors.white, fontSize: 20.0)),
              const SizedBox(height: 5),
              Text(content,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 10.0)),
            ],
          ),
          const SizedBox(width: 50),
          if (isEnd) ...[
            Container(
              height: 50,
              width: 1.0,
              color: Colors.white.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ]
        ],
      ),
    );
  }
}
