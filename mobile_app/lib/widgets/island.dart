import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:mobile_app/utils/colors.dart';

class HexagonItem extends StatelessWidget {
  final int state;
  final String hexLabel;
  final String title;
  final String description;
  final VoidCallback onTapAction;
  final String buttonText;

  const HexagonItem({super.key,
    required this.state,
    required this.hexLabel,
    required this.title,
    required this.description,
    required this.onTapAction,
    required this.buttonText,
  });

  Color getHexColor() {
    switch (state) {
      case 0:
        return Colors.green;
      case 1:
        return CustomColors.accent;
      case 2:
        return Colors.grey.shade400;
      default:
        return CustomColors.accent;
    }
  }

  bool isLocked() => state == 2;

  Color getBorderColor() {
    switch (state) {
      case 0:
        return Colors.green;
      case 1:
        return const Color.fromRGBO(55, 190, 240, 1);
      case 2:
        return Colors.grey;
      default:
        return const Color.fromRGBO(55, 190, 240, 1);
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenW = MediaQuery.of(context).size.width;
    double size = (screenW * 0.25).clamp(80.0, 150.0);
    double textWidth = (size /6).clamp(12.0, 18.0);

    return
      GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: getBorderColor()),
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: screenW * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(description, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (state == 2)  ...[
                    const Text(
                    "Ce cours n'est pas encore disponible.\nTerminez les cours précédents pour le débloquer.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: Ajouter ici une logique pour naviguer vers le cours inProgress
                      },
                      child: const Text("Aller au cours manquant"),
                    ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onTapAction();
                        },
                        child: Text(buttonText),
                      ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
      child: HexagonWidget.pointy(
        width: size,
        color: getHexColor(),
        elevation: 10,
        child: Center(
          child: Text(
            hexLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: textWidth,
            ),
          ),
        ),
      ),
    );
  }
}
