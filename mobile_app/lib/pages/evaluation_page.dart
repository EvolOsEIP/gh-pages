import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/utils/fetchData.dart';
import 'package:mobile_app/widgets/actions_widgets.dart';
import 'package:mobile_app/widgets/basics_elements_of_a_page.dart';
import 'package:mobile_app/widgets/confirm_exit_widget.dart';
import 'package:mobile_app/widgets/instructions_widgets.dart';
import 'package:mobile_app/services/evaluation_service.dart';
import 'package:mobile_app/utils/stars.dart';
import 'package:mobile_app/widgets/evaluation_widgets.dart';

/// A stateful widget representing an evaluation page.
///
/// This page dynamically loads and displays evaluation steps, including
/// instructions, actions, and dialogs, allowing the user to progress through
/// the evaluation and track their score.
class EvaluationPage extends StatefulWidget {
  final dynamic evaluationId;  ///< The ID of the evaluation to load.
  final dynamic score;         ///< The initial score passed to the page.

  /// Constructor requiring a [evaluationId] to load the respective evaluation data.
  const EvaluationPage({super.key, required this.evaluationId, required this.score});

  @override
  _EvaluationPage createState() => _EvaluationPage();
}

class _EvaluationPage extends State<EvaluationPage> {
  dynamic dialogs;  ///< List of dialogs for the evaluation step.
  int life = 2;     ///< Current life points (represents remaining attempts).
  double actualScore = 0;  ///< The accumulated score based on the user's progress.
  int currentDialogIndex = 0;  ///< Index of the current dialog for the assistant.
  String stepName = '';  ///< The name of the current step.
  int allSteps = 0;      ///< Total number of steps in the evaluation.
  int currentStep = 0;   ///< Index of the current evaluation step.
  String instructionDescription = ''; ///< Description of the current instruction.
  List<Map<String, dynamic>> widgetInstructions = []; ///< List of instructions for the current step.
  List<Map<String, dynamic>> widgetActions = [];     ///< List of actions for the current step.

  bool isDataLoaded = false;  ///< Flag indicating if data has been successfully loaded.

  final EvaluationService _evaluationService = EvaluationService();

  /// Loads the evaluation data from the server.
  ///
  /// This method fetches the evaluation steps, instructions, and actions, then updates the state.
  Future<void> loadData() async {
    try {
      List<dynamic> jsonData = await _evaluationService.fetchSteps(widget.evaluationId);
      if (jsonData.isNotEmpty && currentStep < jsonData.length) {
        Map<String, dynamic> step = jsonData[currentStep];
        setState(() {
          stepName = step["title"] ?? "";
          instructionDescription = step["instructions"] ?? "";
          widgetInstructions = List<Map<String, dynamic>>.from(
              step["widgets"]["instructions"] ?? []);
          widgetActions =
          List<Map<String, dynamic>>.from(step["widgets"]["actions"] ?? []);
          allSteps = jsonData.length;
          dialogs = step["dialogs"] ?? [];
          isDataLoaded = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred during the data loading of evaluation: $e");
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load data only if it has not been loaded yet.
    if (!isDataLoaded) {
      loadData();
    }
  }

  /// Moves to the next step if available, otherwise shows the completion dialog.
  ///
  /// The method updates the score and steps, and calls [loadData] to load the next step's data.
  /// If the last step is reached, it calculates the final score and calls [_showCompletionDialog].
  void nextStep(int currentLife) {
    if (currentStep < allSteps - 1) {
      setState(() {
        // Update score based on currentLife points.
        actualScore = finalScoreCalculation(currentLife, false);
        currentStep++;
        life = 2;
      });
      loadData();
    } else {
      _showCompletionDialog(finalScoreCalculation(currentLife, true));
    }
  }

  double finalScoreCalculation(int currentLife, bool lastStep) {
    if (currentLife == 2) {
      actualScore += 1;
    } else if (currentLife == 1) {
      actualScore += 0.5;
    }
    if (lastStep) {
      return ((actualScore / allSteps) * 100);
    }
    return actualScore;
  }

  void loseLife() {
    if (life > 0) {
      setState(() {
        life--;
      });
    }
  }

  /// Displays a pop-up when the evaluation is completed.
  ///
  /// The pop-up shows a completion message based on the user's score, along with a star rating.
  /// It provides feedback depending on whether the user passed or failed the evaluation.
  void _showCompletionDialog(double finalScore) {
    String message = "";

    String formattedScore = finalScore.toStringAsFixed(1);
    int stars = calculateStars(finalScore);

    switch (stars) {
      case 0:
        message = "Tu n'as pas réussi cette évaluation. Essaie de nouveau !";
      case 1:
        message = "Tu as réussi, mais il y a encore des progrès à faire.";
      case 2:
        message = "Bien joué, tu as réussi l'évaluation.";
      case 3:
        message = "Félicitations, tu as brillamment réussi !";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Évaluation terminée"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 20),
            Text("Score final : $formattedScore%"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentStep = 0;
                actualScore = 0;
                life = 2;
                isDataLoaded = false;
              });
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Recommencer"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/roadmap');
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Displays a widget based on its type.
  ///
  /// This method takes the [widgetData] and determines the widget type.
  /// It supports the "image" and "input_text" types and returns the appropriate widget.
  Widget displayWidget(Map<String, dynamic> widgetData, BuildContext context) {
    switch (widgetData["type"]) {
      case "image":
        return imageWidget(
            context, widgetData["data"], widgetData["description"]);
      case "input_text":
        return InputTextWidget(
          key: ValueKey(currentStep),
          expectedValue: widgetData["expected_value"],
          description: widgetData["description"],
          nextStep: nextStep,
          life: loseLife
        );
      default:
        return const SizedBox();
    }
  }

  Widget mainContentOfEvaluations() {
    return Column(
      children: [
        LinearProgressIndicator(value: currentStep / allSteps),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + vies
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stepName, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      buildHeart(life),
                    ],
                  ),
                  const SizedBox(height: 20.0),

                  // Description
                  Text(instructionDescription, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20.0),

                  // Instructions
                  for (var instruction in widgetInstructions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: displayWidget(instruction, context),
                    ),

                  const SizedBox(height: 16.0),

                  // Actions
                  for (var action in widgetActions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: displayWidget(action, context),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmExitWrapper(
      child: Scaffold(
        appBar: buildAppBar("Evaluations", actions: [
        Padding(
        padding: const EdgeInsets.only(right: 20.0),
          child: buildStars(widget.score))]),
        body: isDataLoaded
            ? buildContent(stepColumn: mainContentOfEvaluations(), dialogs: dialogs, onAssistantComplete: () => setState(() => dialogs = []),)
            : buildLoadingIndicator("Chargement de l'évaluation..."),
      ),
    );
  }
}