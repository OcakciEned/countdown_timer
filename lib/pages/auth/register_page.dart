import 'package:flutter/material.dart';
import 'package:countdown_timer/widget/text_field.dart'; // Özel text field bileşeni
import 'package:countdown_timer/widget/button.dart'; // Özel buton bileşeni
import 'package:countdown_timer/widget/date_picker.dart'; // Tarih seçici bileşeni
import 'package:countdown_timer/repository/auth_repository.dart'; // Yetkilendirme işlemlerini yöneten sınıf
import 'package:countdown_timer/bloc/auth_cubit.dart'; // BLoC Cubit sınıfı (durum yönetimi)
import 'package:countdown_timer/bloc/auth_state.dart' as my_auth; // AuthState alias'ı
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb; // Firebase auth
import 'package:countdown_timer/service/shared_preferences.dart'; // SharedPreferences servisi
import 'package:countdown_timer/db/local_db.dart'; // Lokal SQLite veritabanı
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase veritabanı

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  // Kullanıcıdan veri almak için controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _ilController = TextEditingController();
  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _dogumYeriController = TextEditingController();

  // Seçilen doğum tarihi
  DateTime selectedDate = DateTime.now();

  // Tarih seçimi değiştiğinde çağrılır
  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // AuthCubit ile BLoC sağlayıcı başlatılıyor
      create: (context) => AuthCubit(AuthRepository(auth: fb.FirebaseAuth.instance)),
      child: BlocConsumer<AuthCubit, my_auth.AuthState>(
        // Durum dinleyici
        listener: (context, state) async {
          if (state is my_auth.SignedUp) {
            // Kayıt başarılı ise kullanıcı bilgileri işleniyor
            final user = state.userCredential.user;
            if (user != null) {
              final uid = user.uid;
              final email = user.email ?? '';
              final name = _adController.text;
              final province = _ilController.text;
              final birthPlace = _dogumYeriController.text;
              final numberplate = _plakaController.text;
              final birthDate = selectedDate.toIso8601String();

              // SharedPreferences'a kaydet
              await SharedPreferencesHelper.saveUserInfo(
                uid: uid,
                email: email,
                name: name,
              );

              // SQLite'e kaydet
              await LocalDb().insertUser(
                id: uid,
                name: name,
                email: email,
                province: province,
                birthPlace: birthPlace,
                birthDate: birthDate,
                numberplate: numberplate,
              );

              // Supabase'e kaydet
              try {
                await Supabase.instance.client.from('users').insert({
                  'id': uid,
                  'email': email,
                  'name': name,
                  'province': province,
                  'birthPlace': birthPlace,
                  'birthDate': birthDate,
                  'numberplate': numberplate,
                });
                print('Supabase kayıt başarılı');
              } catch (e) {
                print('Supabase kayıt hatası: $e');
              }

              // Kullanıcıya bilgi verilir ve giriş ekranına yönlendirilir
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kayıt başarılı')),
              );

              Navigator.pushReplacementNamed(context, '/login_page');
            }
          } else if (state is my_auth.AuthError) {
            // Hata durumunda kullanıcıya mesaj gösterilir
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    height: 750,
                    width: 350,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30, top: 100),
                          child: Card(
                            color: const Color(0xFFEBEBEB),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Ad-Soyad alanı
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _adController,
                                    textt: "Adınız - Soyadınız",
                                  ),
                                ),
                                // E-posta ve şifre yan yana
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                        child: MyTextField(
                                          onchanged: (_) {},
                                          controller: _emailController,
                                          textt: "E-posta",
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 10, left: 10),
                                        child: MyTextField(
                                          textt: "Şifre",
                                          controller: _passwordController,
                                          onchanged: (value) {},
                                          isPassword: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // İl alanı
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _ilController,
                                    textt: "Yaşadığınız İl",
                                  ),
                                ),
                                // Plaka kodu
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _plakaController,
                                    textt: "Yaşadığınız İl Plaka Kodu",
                                  ),
                                ),
                                // Doğum yeri
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _dogumYeriController,
                                    textt: "Doğum Yeri",
                                  ),
                                ),
                                // Doğum tarihi seçici
                                Padding(
                                  padding: const EdgeInsets.all(10),
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
                                // Kayıt ol butonu
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyButton(
                                    buttonclick: () {
                                      final email = _emailController.text;
                                      final password = _passwordController.text;
                                      final name = _adController.text;
                                      final province = _ilController.text;
                                      final birthPlace = _dogumYeriController.text;
                                      final numberplate = _plakaController.text;

                                      // E-posta doğrulama
                                      if (!RegExp(r'^[\w.-]+@gmail\.com$').hasMatch(email)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('@gmail.com uzantılı e-posta giriniz')),
                                        );
                                        return;
                                      }

                                      // Boş alan kontrolü
                                      if ([email, password, name, province, birthPlace, numberplate].any((e) => e.isEmpty)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Tüm alanları doldurun!')),
                                        );
                                        return;
                                      }

                                      // BLoC cubit ile kayıt işlemi başlatılır
                                      context.read<AuthCubit>().signUp(
                                        name: name,
                                        email: email,
                                        password: password,
                                        date: selectedDate.toIso8601String(),
                                        province: province,
                                        birthplace: birthPlace,
                                        numberplate: numberplate,
                                      );
                                    },
                                    buttontext: "Kayıt Ol",
                                    textcolor: Colors.white,
                                    backcolor: Colors.red,
                                    width: 370,
                                    height: 60,
                                  ),
                                ),
                                // Giriş yap butonu
                                const Text("Hesabınız Var Mı? ↓", style: TextStyle(color: Color(0xFF666666))),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyButton(
                                    buttonclick: () {
                                      Navigator.pushNamed(context, '/login_page');
                                    },
                                    buttontext: "Giriş Yap",
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
