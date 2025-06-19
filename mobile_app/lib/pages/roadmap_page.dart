import 'package:flutter/material.dart';
import 'package:mobile_app/pages/evaluation_page.dart';
import 'package:mobile_app/widgets/island.dart';
import 'package:mobile_app/utils/navbar.dart';
import 'package:mobile_app/pages/course_page.dart';
import 'package:mobile_app/utils/colors.dart';
import 'package:mobile_app/services/roadmap_service.dart';

import 'package:mobile_app/services/dataCaching.dart';

import 'package:mobile_app/widgets/ConnectionBetweenHexa.dart';
/// Enum to define the alignment of the hexagon items.
enum HexagonAlignment { left, center, right }

/// A stateless widget that represents the roadmap page.
///
/// The roadmap page displays a list of modules and their courses, as well as evaluations.
/// It fetches module data asynchronously from the `ModuleService`.
class RoadmapPage extends StatelessWidget {
  final ModuleService moduleService = ModuleService();
  RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: moduleService.fetchModules(),
        builder: (context, snapshot) {
          // If the data is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there is an error during the fetch
          else if (snapshot.hasError) {
            return const Center(child: Text('Error loading roadmap'));
          }
          // If no modules are available
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No modules available'));
          }
          // Display the roadmap content
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 20),
                // Mapping through each module and creating a roadmap section
                ...snapshot.data!
                    .map((module) => RoadmapSection(module: module)),
              ],
            ),
          );
        },
      ),
      // Bottom navigation bar
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(10.0),
        child: CustomNavbar(
            profileImageUrl:
                "https://randomuser.me/api/portraits/women/44.jpg"),
      ),
    );
  }
}

/// A stateless widget representing a section of the roadmap.
///
/// It displays a module's name, a list of courses, and any associated evaluation.
class RoadmapSection extends StatelessWidget {
  final dynamic module;

  const RoadmapSection({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    // print(this.module);
    return Column(
      children: [
        // Divider with the module name
        DividerWidget(title: module['moduleName']),
        const SizedBox(height: 10),
        // Displays the courses and evaluation within the module
        if (module['courses'] != null && module['courses'].isNotEmpty)
          RoadmapWidget(
              courses: module['courses'], evaluation: module['evaluation'] == null ? {'title': 'Aucune évaluation', 'summary': '', 'evaluationId': '', 'scorePercentage': 0} : module['evaluation']),
 
        const SizedBox(height: 10)
      ],
    );
  }
}

/// A stateless widget that displays a divider with the module name.
///
/// This widget includes a title that is the module name, and adds dividers on both sides.
class DividerWidget extends StatelessWidget {
  final String title;

  const DividerWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(thickness: 1, color: CustomColors.primary)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            // Ajust the Text to fit the title if too long 
             

            child: Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.primary))),
        const Expanded(
            child: Divider(thickness: 1, color: CustomColors.primary)),
      ],
    );
  }
}

/// A stateless widget that displays a list of courses and an evaluation.
///
/// Each course is presented in a hexagonal format with a "Commencer" button. The evaluation is also displayed as a hexagon with a "Regarder" button.
class RoadmapWidget extends StatefulWidget {
  final List<dynamic> courses;
  final dynamic evaluation;

  const RoadmapWidget(
      {super.key, required this.courses, required this.evaluation});

  @override
  State<RoadmapWidget> createState() => _RoadmapWidgetState();
}

class _RoadmapWidgetState extends State<RoadmapWidget> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> hexKeys = [];
  final GlobalKey evalKey = GlobalKey();
  List<Offset> hexPositions = [];

  @override
  void initState() {
    super.initState();
    hexKeys.addAll(List.generate(widget.courses.length, (_) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        hexPositions = _getHexPositions();
      });
    });
  }

  List<Offset> _getHexPositions() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return [];

    final positions = hexKeys.map((key) {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final globalCenter = box.localToGlobal(box.size.center(Offset.zero));
        return stackBox.globalToLocal(globalCenter);
      }
      return Offset.zero;
    }).toList();

    final eval = evalKey.currentContext;
    if (eval != null) {
      final box = eval.findRenderObject() as RenderBox;
      final globCenter = box.localToGlobal(box.size.center(Offset.zero));
      final localOffset = stackBox.globalToLocal(globCenter);
      positions.add(localOffset);
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Stack(
          key: _stackKey,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: HexConnectionPainter(hexPositions),
              )),
              Column(
                  children: [
                    ...List.generate(widget.courses.length, (index) {
                      final course = widget.courses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: _getAlignment(course['courseIndex']),
                          children: [
                            Container(
                              key: hexKeys[index],
                              child : HexagonItem(
                                title: course['title'],
                                hexLabel: course['courseIndex'].toString(),
                                description: course['description'],
                                onTapAction: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CoursePage(courseId: course['courseId']),
                                  ),
                                ),
                                buttonText: "Commencer",
                                state: course['courseIndex'] == 1 && course['state'] == 2 ? 0 : course['state'],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              key: evalKey,
                              child: HexagonItem(
                                title: widget.evaluation['title'],
                                hexLabel: "Eval",
                                description: widget.evaluation['summary'],
                                onTapAction: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EvaluationPage(
                                      evaluationId: widget.evaluation['evaluationId'],
                                      score: widget.evaluation['scorePercentage'],
                                    ),
                                  ),
                                ),
                                buttonText: "Regarder",
                                state: 2,//widget.evaluation['state'],
                              ),
                            )
                          ],
                        )
                    ),
                  ]
              ),
    ]
    ));
  }

  /// Returns the alignment for the hexagon items based on the provided `alignment` value.
  ///
  /// This method decides whether the hexagon items should be aligned to the left, center, or right based on the alignment passed.
  MainAxisAlignment _getAlignment(int index) {
    final pattern = [
      MainAxisAlignment.start,
      MainAxisAlignment.center,
      MainAxisAlignment.end,
      MainAxisAlignment.center
    ];
    return pattern[index % pattern.length];
  }
}
