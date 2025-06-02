import 'package:flutter/material.dart';
import 'package:countdown_timer/widget/drawer_menu.dart';
import 'package:countdown_timer/widget/custom_app_bar.dart';

// Tüm sayfalarda ortak olarak kullanılabilecek bir temel sayfa yapısı
class BasePage extends StatelessWidget {
  // Sayfa başlığı ve içerik widget'ı
  final String title;
  final Widget content;

  // Constructor: başlık ve içerik parametreleri alınır
  const BasePage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uygulama çubuğu (AppBar), başlığı gösterir
      appBar: AppBar(title: Text(title)),

      // Sol üstte açılır menü (Drawer)
      drawer: DrawerMenu(),

      // Sayfa içeriği, tüm kenarlardan 16 birim padding ile gösterilir
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content, // Bu sayfaya özel olarak gönderilen içerik burada gösterilir
      ),
    );
  }
}
