import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oturum Kapat'),
          content: const Text('Oturumunuzu kapatmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login_page',
                      (Route<dynamic> route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Oturum kapatıldı')),
                );
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;


    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        String name = '';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'];
        }

        return Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                accountName: Text(name),
                accountEmail: Text(user?.email ?? 'E-posta Bulunamadı'),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('assets/time.png'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Ana Sayfa'),
                onTap: () => _navigate(context, '/home_page'),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Yeni Sayaç Ekle'),
                onTap: () => _navigate(context, '/add_counter'),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Geçmiş Sayaçlar'),
                onTap: () => _navigate(context, '/Past_Counters'),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Profilim'),
                onTap: () => _navigate(context, '/profile_page'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Çıkış'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
