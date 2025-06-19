import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_app/utils/navbar.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  // load json data
  Map<String, dynamic> data = {};
  bool isLoading = true;
  int totalAchievementsUnlocked = 0;
  int totalAchievements = 0;


  void loadJsonData() async {
    String jsonString = await DefaultAssetBundle.of(context).loadString("assets/json/success.json");
    setState(() {
      data = json.decode(jsonString);
      isLoading = false;
    });

    calculateTotalAchievements();
  }

  void calculateTotalAchievements() {
    if (data["islands"] == null) {
      if (kDebugMode) {
        print("JSON data is null");
      }
      return;
    }

    if (kDebugMode) {
      print(data);
    } // debug

    int unlocked = 0;
    int total = 0;

    for (var island in data["islands"]) {
      unlocked += (island["unlocked_achievements"] ?? 0) as int;
      total += (island["totalAchievements"] ?? 0) as int;
    }

    setState(() {
      totalAchievementsUnlocked = unlocked;
      totalAchievements = total;
    });
  }

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }
  @override
  Widget build(BuildContext context) {
    return (isLoading) ? const Center(child: CircularProgressIndicator())
    : Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "MES BADGES",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Row(
                children: [
                  const Icon(Icons.person, size: 50),
                  const Text(
                    "éclaireur",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 50),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$totalAchievementsUnlocked / $totalAchievements\nCOLLECTION TOTALE",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            // filter button
            Align(
              alignment: Alignment.centerRight,
              child:
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  // #227C9D
                  side: const BorderSide(color: Color.fromRGBO(34, 124, 157, 1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Filtres"),
              ),
            ),
            const SizedBox(height: 20),
            // badges
            Expanded(
              child: data["islands"] != null && data["islands"].isNotEmpty
                ? ListView.builder(
                    itemCount: data["islands"]?.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? value = data["islands"]?[index];
                      return BadgeSection(
                        title: value?["name"] ?? "Unknown Island",
                        description: value?["description"] ?? "No description available",
                        progress: value?["unlocked_achievements"] ?? 0,
                        total: value?["totalAchievements"] ?? 0,
                        achievements: value?["achievements"] ?? [],
                      );
                    },
                  )
                : const Center(child: Text('No islands data available')),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(10.0), // Marge autour de la navbar
        child: CustomNavbar(
            profileImageUrl:
                "https://randomuser.me/api/portraits/women/44.jpg"),
      ),
    );
  }
}

class BadgeSection extends StatelessWidget {
  final String? title;
  final String? description;
  final int? progress;
  final int? total;
  final List<dynamic>? achievements;

  const BadgeSection({
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.achievements,
    super.key,
  });


  Future<dynamic> displayDialog(BuildContext context, int index, List<dynamic>? achievements) {
    String unlockDate = achievements?[index]["unlock_date"] ?? "";
    String logo = achievements?[index]["logo"] ?? "";
    String title = achievements?[index]["name"] ?? "";
    String description = achievements?[index]["description"] ?? "";
    String status = achievements?[index]["status"] ?? "";



    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color.fromRGBO(55, 190, 240, 1)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$title",
                textAlign: TextAlign.center,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("$logo"),
              const SizedBox(height: 10),
              Text((status == "locked") ? "Verrouillé" : 
                (status == "pending") ? "" :
                  "Débloqué"),
              const SizedBox(height: 10),
              Text("$description"),
              const SizedBox(height: 10),
              // if status is pending, display a progress bar
              Text((status == "locked") ? "Pour le débloquer, il faut faire ça" :
                (status == "pending") ? "En cours de validation" :
                  "Obtenu le $unlockDate"),
              // progress bar for pending status
              if (status == "pending")
                LinearProgressIndicator(
                  value: 0.5,
                  color: Colors.orange,
                  backgroundColor: Colors.grey[300],
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (total != null && total! > 0) ? (progress! / total!) : 0.0,
                color: Colors.orange,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 5),
            Text("$progress/$total"),
            const SizedBox(width: 10),
            Container(
              width: 100,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  // borderRadius
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Voir le module",
                  style: TextStyle(
                    color: Colors.black,

                    ),
                  ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              total!,
              (index) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: () {
                    print("Badge $index");
                    displayDialog(context, index, achievements);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (achievements?[index]["status"] == "locked") ? Colors.grey[300] :
                        (achievements?[index]["status"] == "pending") ? Colors.grey[300] :
                          Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: achievements?[index]["status"] == "locked"
                        ? const Icon(Icons.lock, color: Colors.black)
                        : achievements?[index]["status"] == "pending" ? const Icon(Icons.hourglass_empty, color: Colors.black) :
                        const Icon(Icons.check, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
