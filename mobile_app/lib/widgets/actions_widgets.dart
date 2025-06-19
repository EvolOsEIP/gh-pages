import 'package:flutter/material.dart';

/// A widget that displays a text input field for user interaction.
///
/// This widget is designed to check the user's input against an expected value
/// and provide feedback on whether the input is correct or not.
///
/// [expectedValue] - The correct answer that the user must input.
/// [description] - Optional description that can be provided to describe the task.
/// [nextStep] - Callback function triggered when the correct input is submitted.
/// [life] - Optional parameter to track the number of attempts or lives remaining.
class InputTextWidget extends StatefulWidget {
  final String expectedValue;
  final String? description;
  final Function(int) nextStep;
  final VoidCallback? life;

  const InputTextWidget({
    super.key,
    required this.expectedValue,
    required this.nextStep,
    this.description,
    this.life
  });

  @override
  _InputTextWidgetState createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {

  TextEditingController controller = TextEditingController();
  String errorMessage = '';
  int currentLife = 2;

  void showSnackBar(String message, {Color backgroundColor = Colors.black}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  /// Handles input errors and provides feedback on the user’s answer.
  ///
  /// This function checks different scenarios for common input errors such as
  /// case sensitivity, missing spaces, or missing punctuation.
  ///
  /// [textEnter] - The input entered by the user.
  ///
  /// Returns a descriptive error message if the input is incorrect.
  String handleErrorInputText(String textEnter) {
    if (textEnter.toLowerCase() == widget.expectedValue.toLowerCase()) {
      return "Vérifier la majuscule: il pourrait y avoir des majuscules en trop ou manquants.";
    }

    if (textEnter.replaceAll(' ', '') == widget.expectedValue.replaceAll(' ', '')) {
      return 'Vérifiez les espaces : il pourrait y avoir des espaces en trop ou manquants.';
    }

    if (!textEnter.endsWith('.') && widget.expectedValue.endsWith('.')) {
      return 'Votre réponse manque un point à la fin.';
    }
    return "Votre réponse est incorrecte. Veuillez revoir l’instruction.";
  }

  /// Validates the user input and provides feedback through snackbars.
  ///
  /// If the input is correct, the next step is triggered with a success message.
  /// If the input is incorrect, an error message is displayed.
  void validateInput() {
    final userInput = controller.text;
    setState(() {
      if (userInput == widget.expectedValue) {
        showSnackBar("Bonne réponse ! 🎉", backgroundColor: Colors.green);
        errorMessage = '';
        controller.clear();
        widget.nextStep(currentLife);
      } else {
        if (widget.life != null) {
          currentLife--;
          widget.life!();
          if (currentLife <= 0) {
            showSnackBar("Plus de vies !", backgroundColor: Colors.red);
            errorMessage = '';
            controller.clear();
            widget.nextStep(0);
          }
        }
        errorMessage = handleErrorInputText(userInput);
      }
    });
  }

  /// Skips the current step and clears the input field.
  ///
  /// This is useful when the user is unsure about the answer and wants to move to the next step.
  void skipStep() {
    setState(() {
      errorMessage = '';
      controller.clear();
      widget.nextStep(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label for the input field
        Text(
          "Entrez :", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.grey[700]),
        ),
        const SizedBox(height: 5),

        // Display the expected value for reference
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            widget.expectedValue,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.blue),
          ),
        ),
        const SizedBox(height: 15),

        // Input field for user response
        Semantics(
          label: widget.description?.isNotEmpty == true ? widget.description : null,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder(),hintText: "Entrez votre réponse ici..."),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),

        // Action buttons for validation or skipping the step
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.life != null)
                ElevatedButton(
                  onPressed: skipStep,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Je ne sais", style: TextStyle(color: Colors.white)),
                ),
              if (widget.life != null)
                const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: validateInput,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Valider", style: TextStyle(color: Colors.white))
              )
            ]
        ),

        // Display the error message below the TextField
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}