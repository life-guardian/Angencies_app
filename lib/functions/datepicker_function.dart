import 'package:flutter/material.dart';

Future<DateTime?> customDatePicker(BuildContext context) async {
  final now = DateTime.now();

  final pickedDate = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: DateTime(now.year + 100),
    confirmText: 'Select',
    cancelText: 'Cancel',
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue, // Change the outline color of the picked date
          ),
        ),
        child: child ?? const SizedBox(),
      );
    },
  );

  return pickedDate;
}
