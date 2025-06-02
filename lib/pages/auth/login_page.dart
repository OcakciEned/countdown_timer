import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:countdown_timer/widget/text_field.dart';
import 'package:countdown_timer/widget/button.dart';
import 'package:countdown_timer/repository/auth_repository.dart';
import 'package:countdown_timer/bloc/auth_cubit.dart';
import 'package:countdown_timer/bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google ile giriş hatası: $e')),
      );
      return null;
    }
  }

  Future<void> signInWithGitHubAndHandle(BuildContext context) async {
    const clientId = 'Ov23liJirU2f6T387Gpu';
    const clientSecret = '3f5cc29a21a3f0170e1e6fcce73af09bf52a8670';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: 'https://github.com/login/oauth/authorize'
            '?client_id=$clientId'
            '&redirect_uri=myapp://callback'
            '&scope=read:user%20user:email',
        callbackUrlScheme: 'myapp',
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GitHub yanıtında kod alınamadı.')),
        );
        return;
      }

      final tokenResponse = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
        },
      );

      final body = json.decode(tokenResponse.body);
      final accessToken = body['access_token'];

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GitHub Access Token alınamadı')),
        );
        return;
      }

      final credential = GithubAuthProvider.credential(accessToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GitHub ile kullanıcı alınamadı.')),
        );
        return;
      }

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'province': '',
          'birthplace': '',
          'date': '',
        });
        Navigator.pushReplacementNamed(context, '/missing_info');
        return;
      }

      final data = snapshot.data()!;
      final isMissingInfo = (data['province'] ?? '').isEmpty ||
          (data['birthplace'] ?? '').isEmpty ||
          (data['date'] ?? '').isEmpty;

      if (isMissingInfo) {
        Navigator.pushReplacementNamed(context, '/missing_info');
      } else {
        Navigator.pushReplacementNamed(context, '/home_page');
      }
    } on PlatformException catch (e) {
      if (e.code == 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GitHub girişi iptal edildi')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub hatası: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GitHub login hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository(auth: FirebaseAuth.instance)),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Giriş Başarılı')),
            );
            Navigator.pushReplacementNamed(context, '/home_page');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email ve Şifre Hatalı')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Align(
              alignment: Alignment.center,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/time.png',
                          height: 220,
                          width: 220,
                        ),
                      ),
                      const SizedBox(height: 30),
                      MyTextField(
                        controller: _emailController,
                        onchanged: (value) {},
                        textt: "E-posta",
                      ),
                      const SizedBox(height: 20),
                      MyTextField(
                        controller: _passwordController,
                        onchanged: (value) {},
                        textt: "Şifre",
                        isPassword: true,
                      ),

                      const SizedBox(height: 30),
                      MyButton(
                        buttonclick: () {
                          final email = _emailController.text;
                          final password = _passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email veya Şifre alanlarını boş bırakmayın')),
                            );
                            return;
                          }

                          context.read<AuthCubit>().getSignIn(email, password);
                        },
                        buttontext: "Giriş Yap",
                        textcolor: Colors.white,
                        backcolor: Colors.blue,
                        width: double.infinity,
                        height: 60,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Hesabınız Yok Mu?',
                        textAlign: TextAlign.center,
                      ),
                      MyButton(
                        buttonclick: () {
                          Navigator.pushNamed(context, '/register_page');
                        },
                        buttontext: "Kayıt Ol",
                        textcolor: Colors.white,
                        backcolor: Colors.red,
                        height: 60,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MyButton(
                            buttonclick: () async {
                              final userCredential = await signInWithGoogle(context);
                              final user = userCredential?.user;

                              if (user != null) {
                                final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
                                final snapshot = await userDoc.get();

                                if (!snapshot.exists) {
                                  await userDoc.set({
                                    'name': user.displayName ?? '',
                                    'email': user.email ?? '',
                                    'province': '',
                                    'birthplace': '',
                                    'date': '',
                                  });
                                  Navigator.pushReplacementNamed(context, '/missing_info');
                                  return;
                                }

                                final data = snapshot.data()!;
                                final isMissingInfo = (data['province'] ?? '').isEmpty ||
                                    (data['birthplace'] ?? '').isEmpty ||
                                    (data['date'] ?? '').isEmpty;

                                if (isMissingInfo) {
                                  Navigator.pushReplacementNamed(context, '/missing_info');
                                } else {
                                  Navigator.pushReplacementNamed(context, '/home_page');
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Google ile giriş başarısız')),
                                );
                              }
                            },
                            buttontext: "Gmail",
                            textcolor: Colors.black,
                            backcolor: Colors.white,
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.35,
                          ),
                          const SizedBox(width: 70),
                          MyButton(
                            buttonclick: () async {
                              await signInWithGitHubAndHandle(context);

                            },
                            buttontext: "Github",
                            textcolor: Colors.white,
                            backcolor: Colors.black,
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.35,
                          ),
                        ],
                      ),
                    ],
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
