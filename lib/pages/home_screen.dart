import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_timer/pages/base_page.dart';
import 'package:countdown_timer/widget/counter_card.dart';
import 'package:countdown_timer/widget/show_dialog.dart';
import 'package:countdown_timer/widget/button.dart';
import 'package:countdown_timer/widget/text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final User? user;
  late final Stream<QuerySnapshot> counterStream;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      counterStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('counters')
          .orderBy('created_at', descending: true)
          .snapshots();
    }
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() {});
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const BasePage(
        title: 'Countdown Timer',
        content: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    return BasePage(
      title: 'Countdown Timer',
      content: StreamBuilder<QuerySnapshot>(
        stream: counterStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final counters = snapshot.data!.docs.where((doc) {
            final datetimeStr = doc['datetime'];
            final datetime = DateTime.tryParse(datetimeStr);
            return datetime != null && datetime.isAfter(now);
          }).toList();

          if (counters.isEmpty) {
            return const Center(
              child: Text(
                'Henüz hiç sayaç eklemedin. Sayaç eklemek için sol üst menüden ekleyebilirsin.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              MyTextField(
                controller: _searchController,
                onchanged: (value) {

                },
                textt: "Ara",
              ),
              const SizedBox(height: 16),
              ...counters.where((counter) {
                final title = (counter['title'] ?? '').toLowerCase();
                final search = _searchController.text.toLowerCase();
                return title.contains(search);
              }).map((counter) {
                final title = counter['title'] ?? '';
                final datetimeStr = counter['datetime'] ?? '';
                final datetime = DateTime.tryParse(datetimeStr);

                if (datetime == null) return const SizedBox.shrink();

                final diff = datetime.difference(DateTime.now());
                final day = diff.inDays.toString().padLeft(2, '0');
                final hour = (diff.inHours % 24).toString().padLeft(2, '0');
                final minute = (diff.inMinutes % 60).toString().padLeft(2, '0');
                final second = (diff.inSeconds % 60).toString().padLeft(2, '0');

                final formattedDate = "${datetime.day.toString().padLeft(2, '0')}.${datetime.month.toString().padLeft(2, '0')}.${datetime.year}";
                final formattedTime = "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
                final fullDateTime = "$formattedDate - $formattedTime";

                return CounterCard(
                  title: title,
                  day: day,
                  hour: hour,
                  minute: minute,
                  second: second,
                  date: fullDateTime,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ShowDialog(
                        title: title,

                        onDelete: () async {
                          await counter.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sayaç silindi')),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
