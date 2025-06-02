import 'package:flutter/material.dart';
import 'package:countdown_timer/widget/text_field.dart';
import 'package:countdown_timer/widget/button.dart';
import 'package:countdown_timer/widget/date_picker.dart';
import 'package:countdown_timer/repository/auth_repository.dart';
import 'package:countdown_timer/bloc/auth_cubit.dart';
import 'package:countdown_timer/bloc/auth_state.dart'  as my_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:countdown_timer/service/shared_preferences.dart';
import 'package:countdown_timer/db/local_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _ilController = TextEditingController();
  final TextEditingController _plakaController = TextEditingController();

  final TextEditingController _dogumYeriController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository(auth: fb.FirebaseAuth.instance)),
      child: BlocConsumer<AuthCubit, my_auth.AuthState>(
        listener: (context, state) async {
          if (state is my_auth.SignedUp) {
            final user = state.userCredential.user;
            if (user != null) {
              final uid = user.uid;
              final email = user.email ?? '';
              final name = _adController.text;
              final province = _ilController.text;
              final birthPlace = _dogumYeriController.text;
              final numberplate=_plakaController.text;
              final birthDate = selectedDate.toIso8601String();

              await SharedPreferencesHelper.saveUserInfo(
                uid: uid,
                email: email,
                name: name,
              );

              await LocalDb().insertUser(
                id: uid,
                name: name,
                email: email,
                province: province,
                birthPlace: birthPlace,
                birthDate: birthDate,
                  numberplate:numberplate
              );

              try {
                await Supabase.instance.client.from('users').insert({
                  'id': uid,
                  'email': email,
                  'name': name,
                  'province': province,
                  'birthPlace': birthPlace,
                  'birthDate': birthDate,
                  'numberplate':numberplate

                });
                print('Supabase kayıt başarılı');
              } catch (e) {
                print('Supabase kayıt hatası: $e');
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kayıt başarılı')),
              );

              Navigator.pushReplacementNamed(context, '/login_page');
            }
          } else if (state is my_auth.AuthError) {
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
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _adController,
                                    textt: "Adınız - Soyadınız",
                                  ),
                                ),
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
                                        )

                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _ilController,
                                    textt: "Yaşadığınız İl",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _plakaController,
                                    textt: "Yaşadığınız İl Plaka Kodu",
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyTextField(
                                    onchanged: (_) {},
                                    controller: _dogumYeriController,
                                    textt: "Doğum Yeri",
                                  ),
                                ),
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
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: MyButton(
                                    buttonclick: () {
                                      final email = _emailController.text;
                                      final password = _passwordController.text;
                                      final name = _adController.text;
                                      final province = _ilController.text;
                                      final birthPlace = _dogumYeriController.text;
                                      final numberplate=_plakaController.text;

                                      if (!RegExp(r'^[\w.-]+@gmail\.com$').hasMatch(email)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('@gmail.com uzantılı e-posta giriniz')),
                                        );
                                        return;
                                      }

                                      if ([email, password, name, province, birthPlace,numberplate].any((e) => e.isEmpty)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Tüm alanları doldurun!')),
                                        );
                                        return;
                                      }

                                      context.read<AuthCubit>().signUp(
                                        name: name,
                                        email: email,
                                        password: password,
                                        date: selectedDate.toIso8601String(),
                                        province: province,
                                        birthplace: birthPlace,
                                          numberplate:numberplate
                                      );
                                    },
                                    buttontext: "Kayıt Ol",
                                    textcolor: Colors.white,
                                    backcolor: Colors.red,
                                    width: 370,
                                    height: 60,
                                  ),
                                ),
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
