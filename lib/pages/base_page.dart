import 'package:flutter/material.dart';
import 'package:countdown_timer/widget/drawer_menu.dart';
import 'package:countdown_timer/widget/custom_app_bar.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget content;

  const BasePage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}

