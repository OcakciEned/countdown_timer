import 'package:flutter/material.dart';

class CounterCard extends StatelessWidget {
  final String title;
  final String day;
  final String hour;
  final String minute;
  final String second;
  final VoidCallback? onTap;

  final String date;
  const CounterCard({
    super.key,
    required this.title,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:20),
      child: SizedBox(
        height: 170,
        width: 360,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCECDCD)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TimeColumn("GÜN", day),
                    _TimeColumn("SAAT", hour),
                    _TimeColumn("DAKİKA", minute),
                    _TimeColumn("SANİYE", second),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(date),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  Column _TimeColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFF08626), fontSize: 15)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFFF08626), fontSize: 30)),
      ],
    );
  }
}
