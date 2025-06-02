import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_timer/db/local_db.dart';
import 'package:countdown_timer/pages/base_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;

          final email = user.email ?? '';
          final isGmail = email.endsWith('@gmail.com');

          final isMissingInfo = (data['name'] ?? '').isEmpty ||
              (data['province'] ?? '').isEmpty ||
              (data['birthplace'] ?? '').isEmpty ||
              (data['date'] ?? '').isEmpty||
              (data['numberplate']??'').isEmpty;


          if (isGmail && isMissingInfo) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/missing_info');
            });
            return;
          }

          await LocalDb().insertUser(
            id: user.uid,
            name: data['name'] ?? '',
            email: email,
            province: data['province'] ?? '',
            birthPlace: data['birthplace'] ?? '',
            birthDate: data['date'] ?? '',
            numberplate:data['numberplate']??''
          );

          setState(() {
            userData = data;
            isLoading = false;
          });
        } else {
          final localUser = await LocalDb().getUser(user.uid);
          if (localUser != null) {
            setState(() {
              userData = {
                'name': localUser['name'],
                'email': localUser['email'],
                'province': localUser['province'],
                'birthplace': localUser['birthPlace'],
                'date': localUser['birthDate'],
    'numberplate':localUser['numberplate']
              };
              isLoading = false;
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/missing_info');
            });
          }
        }
      } catch (e) {
        print("Kullanıcı verisi yüklenirken hata oluştu: $e");

        final localUser = await LocalDb().getUser(user.uid);
        if (localUser != null) {
          setState(() {
            userData = {
              'name': localUser['name'],
              'email': localUser['email'],
              'province': localUser['province'],
              'birthplace': localUser['birthPlace'],
              'date': localUser['birthDate'],
    'numberplate':localUser['numberplate']
            };
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Profilim',
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null || (userData!['name'] ?? '').isEmpty
          ? const Center(child: Text("Profil bilgileri bulunamadı veya eksik."))
          : Card(
        color: const Color(0xFFEBEBEB),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow("Ad-Soyad", userData!['name'] ?? ''),
            _infoRow("E-Posta", FirebaseAuth.instance.currentUser?.email ?? 'Yok'),
            _infoRow("Yaşadığı İl", userData!['province'] ?? ''),
            _infoRow("İl Plaka Kodu",userData!['numberplate']??''),
            _infoRow("Doğum Yeri", userData!['birthplace'] ?? ''),
            _infoRow(
              "Doğum Tarihi",
              (userData!['date'] ?? '').toString().isNotEmpty
                  ? (userData!['date'] ?? '').toString().substring(0, 10)
                  : '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
