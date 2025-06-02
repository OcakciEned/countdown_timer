import 'package:flutter/material.dart';
import 'package:countdown_timer/widget/button.dart';

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerWidget({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
          style: const TextStyle(color: Colors.black),
        ),
        MyButton(
          buttonclick: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (pickedTime != null) {
              onTimeSelected(pickedTime);
            }
          },
          buttontext: "Saat Seç",
          textcolor: Colors.white,
          backcolor: Colors.transparent,
          width: 130,
          height: 30,
        ),
      ],
    );
  }
}
