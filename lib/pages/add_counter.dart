import 'package:flutter/material.dart';
import 'package:countdown_timer/pages/base_page.dart';
import 'package:countdown_timer/widget/text_field.dart';
import 'package:countdown_timer/widget/button.dart';
import 'package:countdown_timer/widget/date_picker.dart';
import 'package:countdown_timer/widget/time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Sayaç ekleme ekranını temsil eden StatefulWidget
class AddCounter extends StatefulWidget {
  const AddCounter({super.key});

  @override
  State<AddCounter> createState() => _AddCounterState();
}

class _AddCounterState extends State<AddCounter> {
  // Sayaç adı için kontrolcü
  final TextEditingController _titleController = TextEditingController();

  // Seçilen tarih ve saat
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Tarih seçildiğinde çağrılır
  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  // Saat seçildiğinde çağrılır
  void onTimeSelected(TimeOfDay time) {
    setState(() {
      selectedTime = time;
    });
  }

  // Sayaç bilgilerini Firestore'a kaydeden fonksiyon
  Future<void> saveCounter(String title, DateTime dateTime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('counters')
        .add({
      'title': title,
      'datetime': dateTime.toIso8601String(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Yeni Sayaç',
      content: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 350,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, top: 100),
                    child: Card(
                      color: const Color(0xFFEBEBEB),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Sayaç adı giriş alanı
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: MyTextField(
                                onchanged: (value) {},
                                controller: _titleController,
                                textt: "Sayaç Adı",
                              ),
                            ),

                            // Tarih seçici bileşeni
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
                                    const Text("Tarih:", style: TextStyle(fontSize: 16)),
                                    DatePicker(
                                      selectedDate: selectedDate,
                                      onDateSelected: onDateSelected,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Saat seçici bileşeni
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
                                    const Text("Saat:", style: TextStyle(fontSize: 16)),
                                    TimePickerWidget(
                                      selectedTime: selectedTime,
                                      onTimeSelected: onTimeSelected,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Kaydet butonu
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: MyButton(
                                buttonclick: () async {
                                  final title = _titleController.text.trim();

                                  // Seçilen tarih ve saat birleştiriliyor
                                  final dateTime = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );

                                  // Sayaç adı boşsa uyarı göster
                                  if (title.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Sayaç adı giriniz')),
                                    );
                                    return;
                                  }

                                  // Firestore'a kaydet
                                  await saveCounter(title, dateTime);

                                  // Başarı mesajı göster
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Sayaç kaydedildi!')),
                                  );
                                },
                                buttontext: "Kaydet",
                                textcolor: Colors.white,
                                backcolor: Colors.blue,
                                width: 370,
                                height: 60,
                              ),
                            ),
                          ],
                        ),
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
