import 'package:flutter/material.dart';

class ManageElevatedButton extends StatelessWidget {
  const ManageElevatedButton({
    super.key,
    required this.buttonItem,
    this.color = const Color(0xff2F80ED),
    required this.onButtonClick,
    this.enabled = true,
  });
  final Widget buttonItem;
  final void Function() onButtonClick;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: enabled ? onButtonClick : () {},
        style: ElevatedButton.styleFrom(
            fixedSize: const Size(200, 40),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
        child: buttonItem,
      ),
    );
  }
}
