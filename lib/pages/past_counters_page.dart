import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_timer/pages/base_page.dart';
import 'package:countdown_timer/widget/show_dialog.dart';
import 'package:countdown_timer/widget/counter_card.dart';

// Geçmiş sayaçları listeleyen sayfa (yalnızca tarihi geçmiş sayaçları gösterir)
class PastCounters extends StatelessWidget {
  const PastCounters({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return BasePage(
      title: 'Geçmiş Sayaçlar',
      content: user == null
          ? const Center(child: Text('Kullanıcı bulunamadı'))
          : StreamBuilder<QuerySnapshot>(
              // Firestore'dan kullanıcının sayaçlarını alır ve zamana göre sıralar
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('counters')
                  .orderBy('datetime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final now = DateTime.now();

                // Geçmişte kalan sayaçları filtrele
                final counters = snapshot.data!.docs.where((doc) {
                  final datetimeStr = doc['datetime'];
                  final datetime = DateTime.tryParse(datetimeStr);
                  return datetime != null && datetime.isBefore(now);
                }).toList();

                if (counters.isEmpty) {
                  return const Center(child: Text('Henüz geçmiş sayaç yok.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: counters.length,
                  itemBuilder: (context, index) {
                    final counter = counters[index];
                    final title = counter['title'] ?? '';
                    final datetimeStr = counter['datetime'] ?? '';
                    final datetime = DateTime.tryParse(datetimeStr);

                    if (datetime == null) return const SizedBox.shrink();

                    // Geçen süreyi hesapla
                    final diff = now.difference(datetime);

                    final day = diff.inDays.toString().padLeft(2, '0');
                    final hour = (diff.inHours % 24).toString().padLeft(2, '0');
                    final minute = (diff.inMinutes % 60).toString().padLeft(2, '0');
                    final second = (diff.inSeconds % 60).toString().padLeft(2, '0');

                    // Tarihi biçimlendir
                    final formattedDate =
                        "${datetime.day.toString().padLeft(2, '0')}.${datetime.month.toString().padLeft(2, '0')}.${datetime.year}";
                    final formattedTime =
                        "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
                    final fullDateTime = "$formattedDate - $formattedTime";

                    // Sayaç kartı oluştur
                    return CounterCard(
                      title: title,
                      day: day,
                      hour: hour,
                      minute: minute,
                      second: second,
                      date: fullDateTime,
                      onTap: () {
                        // Silme işlemi için onTap ile diyalog açılır
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
                  },
                );
              },
            ),
    );
  }
}
