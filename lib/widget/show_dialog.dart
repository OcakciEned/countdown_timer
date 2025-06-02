import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  final String title;
  final VoidCallback onDelete;

  const ShowDialog({
    super.key,
    required this.title,

    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          ListTile(
            title: const Text('Sil'),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
