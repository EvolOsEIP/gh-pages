import 'package:flutter/material.dart';
import 'package:mobile_app/utils/navbar.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.text_increase),
            title: Text("Taille du texte"),
            onTap: () {
              // À implémenter
            },
          ),
          ListTile(
            leading: Icon(Icons.volume_up),
            title: Text("Activer l’assistance vocale"),
            onTap: () {
              // À implémenter
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Confidentialité"),
            onTap: () {
              // À implémenter
            },
          ),
        ],
      ),

    bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(10.0),
        child: CustomNavbar(
            profileImageUrl:
                "https://randomuser.me/api/portraits/women/44.jpg"),
      )
    );
  }
}
