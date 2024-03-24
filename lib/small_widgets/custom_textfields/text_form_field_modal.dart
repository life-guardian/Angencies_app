import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFormFieldModal extends StatelessWidget {
  const TextFormFieldModal({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.name,
    required this.checkValidation,
  });

  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?) checkValidation;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: checkValidation,
      cursorColor: Theme.of(context).colorScheme.onBackground,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(156, 158, 158, 158)),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.mulish(
          fontSize: 16,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
