import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_timer/pages/base_page.dart';
import 'package:countdown_timer/widget/counter_card.dart';
import 'package:countdown_timer/widget/show_dialog.dart';
import 'package:countdown_timer/widget/button.dart';
import 'package:countdown_timer/widget/text_field.dart';

// Ana sayfa widget'ı
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Giriş yapan kullanıcıyı tutar
  late final User? user;

  // Sayaç verilerini dinlemek için stream
  late final Stream<QuerySnapshot> counterStream;

  // Arama kutusu için kontrolcü
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Giriş yapan kullanıcıyı al
    user = FirebaseAuth.instance.currentUser;

    // Eğer kullanıcı varsa, o kullanıcıya ait sayaçları dinle
    if (user != null) {
      counterStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('counters')
          .orderBy('created_at', descending: true)
          .snapshots();
    }

    // Sayaçların canlı güncellenmesi için her saniye sayfa yeniden çizilir
    _startTimer();
  }

  // Her saniyede bir sayfanın yenilenmesini sağlar (canlı sayaç için)
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() {});
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Eğer kullanıcı yoksa bilgi mesajı göster
    if (user == null) {
      return const BasePage(
        title: 'Countdown Timer',
        content: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    // Kullanıcı varsa sayaçları gösteren arayüz
    return BasePage(
      title: 'Countdown Timer',
      content: StreamBuilder<QuerySnapshot>(
        stream: counterStream, // Firestore'dan gelen sayaç verilerini dinler
        builder: (context, snapshot) {
          // Veri bekleniyor, yükleniyor animasyonu göster
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();

          // Geçmişteki sayaçları filtrele, sadece gelecekte olanları al
          final counters = snapshot.data!.docs.where((doc) {
            final datetimeStr = doc['datetime'];
            final datetime = DateTime.tryParse(datetimeStr);
            return datetime != null && datetime.isAfter(now);
          }).toList();

          // Sayaç yoksa bilgi mesajı göster
          if (counters.isEmpty) {
            return const Center(
              child: Text(
                'Henüz hiç sayaç eklemedin. Sayaç eklemek için sol üst menüden ekleyebilirsin.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Sayaçlar varsa, liste halinde göster
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Arama kutusu
              MyTextField(
                controller: _searchController,
                onchanged: (value) {
                  // Arama filtreleme için onchanged tetiklenebilir
                },
                textt: "Ara",
              ),
              const SizedBox(height: 16),

              // Sayaçları listeleyen widget'lar
              ...counters.where((counter) {
                final title = (counter['title'] ?? '').toLowerCase();
                final search = _searchController.text.toLowerCase();
                return title.contains(search); // Arama kelimesini içeren sayaçlar gösterilir
              }).map((counter) {
                final title = counter['title'] ?? '';
                final datetimeStr = counter['datetime'] ?? '';
                final datetime = DateTime.tryParse(datetimeStr);

                // Geçersiz tarih varsa boş widget döndür
                if (datetime == null) return const SizedBox.shrink();

                // Sayaç için kalan zamanı hesapla
                final diff = datetime.difference(DateTime.now());
                final day = diff.inDays.toString().padLeft(2, '0');
                final hour = (diff.inHours % 24).toString().padLeft(2, '0');
                final minute = (diff.inMinutes % 60).toString().padLeft(2, '0');
                final second = (diff.inSeconds % 60).toString().padLeft(2, '0');

                // Tarihi okunabilir formatta düzenle
                final formattedDate = "${datetime.day.toString().padLeft(2, '0')}.${datetime.month.toString().padLeft(2, '0')}.${datetime.year}";
                final formattedTime = "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}";
                final fullDateTime = "$formattedDate - $formattedTime";

                // Sayaç kartı oluştur
                return CounterCard(
                  title: title,
                  day: day,
                  hour: hour,
                  minute: minute,
                  second: second,
                  date: fullDateTime,

                  // Sayaç kartına tıklanınca silme diyaloğu açılır
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ShowDialog(
                        title: title,
                        onDelete: () async {
                          // Sayaç Firestore'dan silinir
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
