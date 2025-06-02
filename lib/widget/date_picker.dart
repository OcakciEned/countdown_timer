import 'package:flutter/material.dart';
import 'package:countdown_timer/widget/button.dart';

class DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
          style: const TextStyle(color: Colors.black),
        ),
        MyButton(
          buttonclick: () async {
            DateTime? dateTime = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2500),
            );
            if (dateTime != null) {
              onDateSelected(dateTime);
            }
          },
          buttontext: "Tarih Seç",
          textcolor: Colors.white,
          backcolor: Colors.transparent,
          width: 130,
          height: 30,
        ),
      ],
    );
  }
}
