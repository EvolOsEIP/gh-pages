import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_app/utils/colors.dart';
import 'package:mobile_app/utils/navbar.dart';
import 'package:mobile_app/pages/settings_page.dart';


import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final int age;
  final String language;
  final String profileImageUrl;

  ProfilePage({
    this.userName = "Jean Dupont",
    this.age = 62,
    this.language = "Français",
    this.profileImageUrl = "https://i.pravatar.cc/150?img=3", // Image par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Mon Profil"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(height: 10),
                Text(userName,
                    style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Âge : $age", style: TextStyle(color: Colors.white70)),
                Text("Langue : $language", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          SizedBox(height: 30),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: Icon(Icons.settings, color: Colors.teal),
              title: Text("Paramètres"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
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
