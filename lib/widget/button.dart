import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.buttonclick,
    required this.buttontext,
    required this.textcolor,
    required this.backcolor,
    required this.height,
    required this.width,

  });

  final String buttontext;
  final VoidCallback buttonclick;
  final Color textcolor;
  final Color backcolor;
  final double height;
  final double width;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: buttonclick,
        style: ElevatedButton.styleFrom(
          backgroundColor: backcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          buttontext,
          style: TextStyle(fontSize: 16, color: textcolor),
        ),
      ),
    );
  }
}
