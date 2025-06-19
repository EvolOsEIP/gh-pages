import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/assistant.dart';

PreferredSizeWidget buildAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    elevation: 0,
    title: Text(
      title,
      style: const TextStyle(color: Colors.black, fontSize: 20),
    ),
    actions: actions,
  );
}

Widget buildContent({
    required Widget stepColumn,
    required List<dynamic>? dialogs,
    required VoidCallback onAssistantComplete,
  }) {
  return SafeArea(
    child: Stack(
      children: [
        stepColumn,
        if (dialogs != null && dialogs.isNotEmpty)
          buildAssistantOverlay(dialogs, onAssistantComplete),
      ],
    ),
  );
}

Widget buildAssistantOverlay(List<dynamic> dialogs, VoidCallback onComplete) {
  return Positioned.fill(
    child: Assistant(
      dialogs: dialogs,
      onComplete: onComplete,
    ),
  );
}