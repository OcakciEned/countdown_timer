import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:countdown_timer/widget/text_field.dart';
import 'package:countdown_timer/widget/button.dart';
import 'package:countdown_timer/widget/date_picker.dart';
import 'package:countdown_timer/pages/base_page.dart';
import 'package:countdown_timer/db/local_db.dart';
import 'package:countdown_timer/pages/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Kullanıcının eksik bilgilerini doldurması için sayfa
class missinginfo extends StatefulWidget {
  const missinginfo({super.key});

  @override
  State<missinginfo> createState() => _missinginfoState();
}

class _missinginfoState extends State<missinginfo> {
  // Kullanıcıdan alınacak veriler için controller'lar
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _ilController = TextEditingController();
  final TextEditingController _dogumYeriController = TextEditingController();
  final TextEditingController _plakaController = TextEditingController();

  // Seçilen doğum tarihi
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExistingData(); // Firestore'dan mevcut verileri yükle
  }

  // Firestore'dan mevcut kullanıcı verilerini alır
  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        _adController.text = data['name'] ?? '';
        _ilController.text = data['province'] ?? '';
        _dogumYeriController.text = data['birthplace'] ?? '';
        _plakaController.text = data['numberplate'] ?? '';
        if (data['date'] != null) {
          try {
            selectedDate = DateTime.parse(data['date']);
          } catch (e) {
            print("Doğum tarihi formatı hatası: $e");
          }
        }
        setState(() {}); // UI'yi güncelle
      }
    }
  }

  // Tarih seçildiğinde çağrılır
  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  // Kaydet butonuna basıldığında çağrılır
  void _saveInfo() async {
    final name = _adController.text;
    final province = _ilController.text;
    final birthplace = _dogumYeriController.text;
    final numberplate = _plakaController.text;
    final birthDate = selectedDate.toIso8601String();

    // Tüm alanların dolu olup olmadığını kontrol et
    if (name.isEmpty || province.isEmpty || birthplace.isEmpty || numberplate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Firestore'a verileri kaydet
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'province': province,
        'birthplace': birthplace,
        'date': birthDate,
        'numberplate': numberplate,
        'email': user.email ?? '',
      }, SetOptions(merge: true)); // Var olan verileri ezmeden günceller

      // Verileri yerel veritabanına kaydet (offline kullanım için)
      await LocalDb().insertUser(
        id: user.uid,
        name: name,
        email: user.email ?? '',
        province: province,
        birthPlace: birthplace,
        birthDate: birthDate,
        numberplate: numberplate,
      );

      // Supabase'e aynı verileri gönder
      final supabase = Supabase.instance.client;
      await supabase.from('users').insert({
        'id': user.uid,
        'email': user.email,
        'name': name,
        'province': province,
        'birthPlace': birthplace,
        'birthDate': birthDate,
        'numberplate': numberplate,
      });

      if (!mounted) return;

      // Profil sayfasına yönlendir
      Navigator.pushNamedAndRemoveUntil(context, '/profile_page', (route) => false);
    } catch (e) {
      // Hata olursa kullanıcıya bildir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Eksik Bilgileri Tamamla',
      content: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              height: 700,
              width: 350,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, top: 80),
                    child: Card(
                      color: const Color(0xFFEBEBEB),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ad soyad
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: MyTextField(
                              onchanged: (_) {},
                              controller: _adController,
                              textt: "Adınız-Soyadınız",
                            ),
                          ),
                          // İl
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: MyTextField(
                              onchanged: (_) {},
                              controller: _ilController,
                              textt: "Yaşadığınız İl",
                            ),
                          ),
                          // Plaka
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: MyTextField(
                              onchanged: (_) {},
                              controller: _plakaController,
                              textt: "Yaşadığınız İl Plaka Kodu",
                            ),
                          ),
                          // Doğum yeri
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: MyTextField(
                              onchanged: (_) {},
                              controller: _dogumYeriController,
                              textt: "Doğum Yeri",
                            ),
                          ),
                          // Doğum tarihi seçimi
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Doğum Tarihi:", style: TextStyle(fontSize: 16)),
                                  DatePicker(
                                    selectedDate: selectedDate,
                                    onDateSelected: onDateSelected,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Kaydet butonu
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: MyButton(
                              buttonclick: _saveInfo,
                              buttontext: "Kaydet",
                              textcolor: Colors.white,
                              backcolor: Colors.teal,
                              width: 370,
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
