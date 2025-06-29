import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/basics_elements_of_a_page.dart';
import 'package:mobile_app/utils/fetchData.dart';
import 'package:mobile_app/widgets/actions_widgets.dart';
import 'package:mobile_app/widgets/confirm_exit_widget.dart';
import 'package:mobile_app/widgets/instructions_widgets.dart';
import 'package:mobile_app/services/api_service.dart';

/// A stateful widget representing a course page.
///
/// This page dynamically loads and displays course steps, including
/// instructions and actions required for the user to progress through the course.
class CoursePage extends StatefulWidget {
  final dynamic courseId; ///< The ID of the course to load.

  /// Constructor requiring a [courseId] to load the respective course data.
  ///
  /// [courseId] is a unique identifier for the course whose steps and
  /// associated content will be fetched and displayed.
  const CoursePage({super.key, required this.courseId});

  @override
  _CoursePage createState() => _CoursePage();
}

class _CoursePage extends State<CoursePage> {
  dynamic dialogs;
  int currentDialogIndex = 0;

  String stepName = '';
  int allSteps = 0;
  int currentStep = 0;
  String instructionDescription = '';
  List<Map<String, dynamic>> widgetInstructions = [];
  List<Map<String, dynamic>> widgetActions = [];

  /// Flag to check if course data has been loaded successfully.
  bool isDataLoaded = false;

  final ApiService _apiService = ApiService();

  /// Loads the course data and updates the state with the appropriate content.
  ///
  /// This function fetches the course steps from a service and updates the UI
  /// accordingly. It loads the step name, instructions, and any associated
  /// widgets such as instructions and actions.
  Future<void> loadData() async {
    try {
      List<dynamic> jsonData = await _apiService.fetch("courses/${widget.courseId}/steps", "assets/json/courses_pages.json");

      if (jsonData.isNotEmpty) {
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
        print("Error occurred during the courses data loading : $e");
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

  /// Moves to the next step of the course if available.
  ///
  /// If there are more steps, it increments the current step index
  /// and loads the next step. If the course has been completed, it shows
  /// a completion dialog.
  ///
  /// [life] can be used for managing lives or other gameplay elements, if applicable.
  void nextStep(int? life) async {
    if (currentStep < allSteps - 1) {
      setState(() {
        currentStep++;
      });
      loadData();
    } else {
      List<dynamic> response = await _apiService.put("courses/${widget.courseId}/complete", {});
      if (response.isNotEmpty && response[0] == "success") {
        if (kDebugMode) {
          print("Course completed successfully.");
        }
      } else {
        if (kDebugMode) {
          print("Error completing course: $response");
        }
      }
      _showCompletionDialog();
    }
  }

  /// Displays a pop-up dialog when the course is completed.
  ///
  /// The dialog displays a congratulatory message and provides an option
  /// to navigate back to the courses list or roadmap.
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cours complété"),
        content: Text("Félicitation tu as terminé ton cours."), //use var to load the correct msg
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/roadmap');
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Widget mainContentOfCourses() {
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
                  Text(stepName,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Text(instructionDescription,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20.0),
                  ...widgetInstructions.map(
                        (instruction) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: displayWidget(instruction, context),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ...widgetActions.map(
                        (action) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: displayWidget(action, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Displays a widget based on its type.
  ///
  /// This function supports displaying different types of widgets based
  /// on the type defined in the widget data (e.g., "image", "input_text").
  ///
  /// [widgetData] is a map containing the widget's data (e.g., type, description, etc.).
  /// [context] is the current build context of the widget.
  Widget displayWidget(Map<String, dynamic> widgetData, BuildContext context) {
    switch (widgetData["type"]) {
      case "image":
        return imageWidget(
            context, widgetData["data"], widgetData["description"]);
      case "input_text":
        return InputTextWidget(
            expectedValue: widgetData["expected_value"],
            description: widgetData["description"],
            nextStep: nextStep);
      default:
        return const SizedBox(); // Return an empty widget for unknown types
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmExitWrapper(
      child: Scaffold(
        appBar: buildAppBar("Cours"),
        body: isDataLoaded
            ? buildContent(stepColumn: mainContentOfCourses(), dialogs: dialogs, onAssistantComplete: () => setState(() => dialogs = []),)
            : buildLoadingIndicator("Chargement du cours..."),
      ),
    );
  }
}