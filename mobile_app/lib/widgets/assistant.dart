import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable widget that displays a dialog-style assistant.
/// The assistant sequentially types out a list of dialogs with a blinking effect at the end.
class Assistant extends StatefulWidget {
  /// The list of dialogs to be displayed sequentially.
  final List<dynamic> dialogs;

  /// A callback function triggered when all dialogs have been displayed.
  final VoidCallback? onComplete;

  const Assistant({
    super.key,
    required this.dialogs,
    this.onComplete,
  });

  @override
  _AssistantState createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> {
  /// The index of the currently displayed dialog in the list.
  int currentDialogIndex = 0;

  /// The text currently being displayed, updated incrementally for typing effect.
  String displayedText = "";

  /// Indicates if the typing animation is currently in progress.
  bool isTyping = false;

  /// Indicates if the blinking effect is currently visible.
  bool isBlinking = false;

  /// A timer used to handle the blinking effect.
  Timer blinkTimer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();

    // Start typing the first dialog if the dialog list is not empty.
    if (widget.dialogs.isNotEmpty) {
      _startTypingEffect(widget.dialogs[currentDialogIndex]);
    }
  }

  @override
  void dispose() {
    // Cancel the blinking timer to avoid memory leaks.
    blinkTimer.cancel();
    super.dispose();
  }

  /// Starts the typing animation for the provided text.
  void _startTypingEffect(String text) {
    setState(() {
      displayedText = ""; // Clear the displayed text.
      isTyping = true; // Set typing flag to true.
      isBlinking = false; // Stop blinking while typing.
    });

    // Timer to incrementally add characters to the displayed text.
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (displayedText.length < text.length) {
        setState(() {
          displayedText += text[displayedText.length];
        });
      } else {
        timer.cancel(); // Stop the timer when the text is fully displayed.
        setState(() {
          isTyping = false; // Typing animation is complete.
        });
        _startBlinkingEffect(); // Start the blinking effect.
      }
    });
  }

  /// Starts the blinking animation for the displayed text.
  void _startBlinkingEffect() {
    blinkTimer.cancel(); // Ensure no other blinking timer is running.
    blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        isBlinking = !isBlinking; // Toggle the blinking state.
      });
    });
  }

  /// Handles the user tap gesture to skip typing or move to the next dialog.
  void _onTap() {
    blinkTimer.cancel(); // Stop the blinking timer.

    if (isTyping) {
      // If typing is in progress, display the full dialog immediately.
      setState(() {
        displayedText = widget.dialogs[currentDialogIndex];
        isTyping = false;
      });
    } else {
      // Move to the next dialog if available.
      if (currentDialogIndex < widget.dialogs.length - 1) {
        setState(() {
          currentDialogIndex++;
        });
        _startTypingEffect(widget.dialogs[currentDialogIndex]);
      } else {
        // Trigger the onComplete callback when all dialogs are done.
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
        setState(() {
          displayedText = ""; // Clear the displayed text.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap, // Handle user tap gestures.
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Stack(
          children: [
            if (widget.dialogs.isNotEmpty) ...[
              Center(
                child: AnimatedOpacity(
                  opacity: isBlinking
                      ? 0.5
                      : 1.0, // Adjust opacity for blinking effect.
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                      const Color.fromARGB(255, 51, 84, 116).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white70, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Assistant",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          displayedText,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 173, 167, 167),
                            fontSize: 30,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
