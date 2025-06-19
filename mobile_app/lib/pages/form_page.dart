import 'package:flutter/material.dart';
import 'dart:convert';

class OnboardingForm extends StatefulWidget {
  @override
  _OnboardingFormState createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  int age = 30;
  String language = 'Français';
  bool usedDevice = false;
  List<String> skills = [];
  List<String> difficulties = [];
  List<String> goals = [];
  List<String> accessibility = [];

  final skillOptions = ['Passer un appel', 'Envoyer un message', 'Naviguer sur Internet'];
  final difficultyOptions = ['Lire l’écran', 'Utiliser les petits boutons', 'Comprendre les menus'];
  final goalOptions = ['Utiliser WhatsApp', 'Faire une démarche en ligne', 'Envoyer un mail'];
  final accessibilityOptions = ['Texte agrandi', 'Aide audio', 'Aide d’un proche'];

  void submitForm() {
    final Map<String, dynamic> userProfile = {
      "age": age,
      "language": language,
      "usedDevice": usedDevice,
      "skills": skills,
      "difficulties": difficulties,
      "goals": goals,
      "accessibility": accessibility
    };

    print(jsonEncode(userProfile));
    // Tu peux maintenant sauvegarder ce JSON ou l’envoyer à ton backend.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenue")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Quel est votre âge ?"),
            Slider(
              min: 10,
              max: 90,
              value: age.toDouble(),
              divisions: 80,
              label: "$age",
              onChanged: (value) => setState(() => age = value.toInt()),
            ),
            SizedBox(height: 10),
            Text("Langue préférée"),
            DropdownButton<String>(
              value: language,
              items: ['Français', 'Créole', 'Anglais', 'Arabe'].map((lang) =>
                DropdownMenuItem(value: lang, child: Text(lang))).toList(),
              onChanged: (value) => setState(() => language = value!),
            ),
            SizedBox(height: 10),
            Text("Avez-vous déjà utilisé un appareil ?"),
            SwitchListTile(
              title: Text(usedDevice ? "Oui" : "Non"),
              value: usedDevice,
              onChanged: (val) => setState(() => usedDevice = val),
            ),
            SizedBox(height: 10),
            Text("Que savez-vous déjà faire ?"),
            ...skillOptions.map((option) => CheckboxListTile(
              title: Text(option),
              value: skills.contains(option),
              onChanged: (val) {
                setState(() {
                  val! ? skills.add(option) : skills.remove(option);
                });
              },
            )),
            SizedBox(height: 10),
            Text("Qu’est-ce qui est difficile pour vous ?"),
            ...difficultyOptions.map((option) => CheckboxListTile(
              title: Text(option),
              value: difficulties.contains(option),
              onChanged: (val) {
                setState(() {
                  val! ? difficulties.add(option) : difficulties.remove(option);
                });
              },
            )),
            SizedBox(height: 10),
            Text("Qu’aimeriez-vous apprendre ?"),
            ...goalOptions.map((option) => CheckboxListTile(
              title: Text(option),
              value: goals.contains(option),
              onChanged: (val) {
                setState(() {
                  val! ? goals.add(option) : goals.remove(option);
                });
              },
            )),
            SizedBox(height: 10),
            Text("Besoin d’une aide particulière ?"),
            ...accessibilityOptions.map((option) => CheckboxListTile(
              title: Text(option),
              value: accessibility.contains(option),
              onChanged: (val) {
                setState(() {
                  val! ? accessibility.add(option) : accessibility.remove(option);
                });
              },
            )),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Continuer"),
              onPressed: submitForm,
            )
          ],
        ),
      ),
    );
  }
}
