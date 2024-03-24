import 'package:flutter/material.dart';

class ModalBottomSheet {
  Future<void> openModal(
      {required BuildContext context,
      required Widget widget,
      isDismissible = true}) async {
    await showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      builder: (ctx) => widget,
    );
  }
}
