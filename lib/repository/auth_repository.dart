import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthRepository {
  final FirebaseAuth auth;

  AuthRepository({required this.auth});

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) print('Kullanıcı girişi başarılı');
      return userCredential;
    } catch (e) {
      if (kDebugMode) print('Giriş hatası: $e');
      throw Exception('Giriş başarısız: Email veya şifre yanlış.');
    }
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required String date,
    required String province,
    required String birthplace,
    required String numberplate,

  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'date': date,
        'province': province,
        'birthplace': birthplace,
        'numberplate':numberplate

      });

      if (kDebugMode) print('Kullanıcı oluşturuldu');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FirebaseAuthException: ${e.code}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Hata: $e');
      throw Exception('Kayıt başarısız');
    }
  }

  Future<void> loggedOut() async {
    try {
      await auth.signOut();
      if (kDebugMode) print('Çıkış yapıldı');
    } catch (e) {
      if (kDebugMode) print('Çıkış hatası: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'province': '',
            'birthplace': '',
            'date': '',
            'numberplate': ''
          });
        }
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) print('Google ile giriş hatası: $e');
      return null;
    }
  }


  Future<UserCredential?> signInWithGitHubToken(String accessToken) async {
    try {
      final credential = GithubAuthProvider.credential(accessToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      if (kDebugMode) print('GitHub giriş hatası: $e');
      return null;
    }
  }




}
