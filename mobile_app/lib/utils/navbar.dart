import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/services/dataCaching.dart';
import 'package:mobile_app/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

getProfile() async {
  final cachingService = CachingStorageService();
  final profile = await cachingService.getFromCache('profile');

  return profile.toString(); // Default image
}

class CustomNavbar extends StatelessWidget {
  final String profileImageUrl;

  const CustomNavbar({super.key, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double navbarHeight = screenWidth * 0.10;
    double iconSize = screenWidth * 0.07;
    double avatarSize = screenWidth * 0.07;

    dynamic userProfile = null;
    final cachingService = CachingStorageService();
    cachingService.getFromCache('profile').then((profile) {
      if (profile != null) {
        userProfile = jsonEncode(profile);
      } else {
        print("No profile found in cache.");
      }
    });

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(navbarHeight * 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (ModalRoute.of(context)!.settings.name != '/profile') {
                Navigator.pushNamed(context, '/profile');
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(avatarSize * 0.5),
              child: Image.network(
                "http://" + dotenv.env["HOST_URL"].toString() + "/api/images/step1.png",
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu_book,
                color: CustomColors.dark_accent, size: iconSize),
            onPressed: () {
              if (ModalRoute.of(context)!.settings.name != '/roadmap') {
                Navigator.pushNamed(context, '/roadmap');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.star_border,
                color: CustomColors.dark_accent, size: iconSize),
            onPressed: () {
              if (ModalRoute.of(context)!.settings.name != '/success') {
                Navigator.pushNamed(context, '/success');
              }
            },
          ),
        ],
      ),
    );
  }
}
