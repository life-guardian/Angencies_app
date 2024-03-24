import 'package:flutter/material.dart';

class TextFormFieldLoginRegister extends StatefulWidget {
  const TextFormFieldLoginRegister({
    super.key,
    this.labelText = '',
    this.hideText = false,
    this.obsecureIcon = false,
    required this.controllerText,
    required this.checkValidation,
    this.textHint = '',
  });

  final String labelText;
  final bool obsecureIcon;
  final bool hideText;
  final String textHint;
  final String? Function(String?) checkValidation;
  final TextEditingController controllerText;

  @override
  State<TextFormFieldLoginRegister> createState() =>
      // ignore: no_logic_in_create_state
      _TextFormFieldLoginRegisterState(selectedObscure: hideText);
}

class _TextFormFieldLoginRegisterState
    extends State<TextFormFieldLoginRegister> {
  _TextFormFieldLoginRegisterState({required this.selectedObscure});
  bool selectedObscure;

  void _obscuretxt() {
    setState(() {
      selectedObscure = selectedObscure ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return TextFormField(
      obscureText: selectedObscure,
      controller: widget.controllerText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: Theme.of(context).colorScheme.onBackground,
      // cursorErrorColor: Colors.red,
      validator: (value) => widget.checkValidation(value),
      selectionControls: DesktopTextSelectionControls(),
      decoration: InputDecoration(
        suffixIcon: widget.obsecureIcon
            ? IconButton(
                onPressed: _obscuretxt,
                icon: selectedObscure
                    ? const Icon(
                        Icons.lock_rounded,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.lock_open_rounded,
                        color: Colors.grey,
                      ),
              )
            : null,
        filled: true,
        fillColor: (themeData.brightness == Brightness.light)
            ? const Color.fromARGB(162, 232, 236, 244)
            : Theme.of(context).colorScheme.primary,
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
        labelText: widget.labelText,
        labelStyle:
            TextStyle(color: Theme.of(context).colorScheme.onBackground),
        hintText: widget.textHint,
      ),
    );
  }
}
