import 'package:flutter/material.dart';

class ConfirmExitWrapper extends StatelessWidget {
  final Widget child;

  const ConfirmExitWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _showExitConfirmationDialog(context);
        if (shouldPop == true) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quitter ?"),
        content: const Text("Tu vas perdre ta progression..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }
}
