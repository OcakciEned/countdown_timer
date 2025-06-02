import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String textt;
  final TextEditingController controller;
  final Function(String)? onchanged;
  final bool isPassword;

  const MyTextField({
    super.key,
    required this.textt,
    required this.controller,
    required this.onchanged,
    this.isPassword = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onchanged,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.textt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}
