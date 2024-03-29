import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.transparent,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.mulish(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color == Colors.transparent
            ? Theme.of(context).colorScheme.onBackground
            : color,
      ),
    );
  }
}
