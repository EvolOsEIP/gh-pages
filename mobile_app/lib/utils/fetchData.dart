import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchFromJson(String filePath) async {
  try {
    final String jsonString = await rootBundle.loadString(filePath);
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData;
  } catch (e) {
    throw Exception("Failed to load local JSON: $e");
  }
}

dynamic fetchFromApi(String endpoint,
    {Map<String, String>? headers}) async {
  var url = Uri.http(dotenv.env["HOST_URL"].toString(), endpoint);
  try {
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  } catch (e) {
    if (kDebugMode) {
      if (e.toString().contains('SocketException')) {
        print('Network error: Unable to connect to the server.');
      } else if (e.toString().contains('TimeoutException')) {
        print('Request timed out. Please try again later.');
      } else if (e.toString().contains('token')) {
        print('Authentication error: Please check your token or login again.');
        BuildContext context = headers?['context'] as BuildContext;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Error fetching data: $e from endpoint: $endpoint');
      }
    }
    return [e.toString()];
  }
}

dynamic postToApi(String endpoint, Object? body) async {
  var url = Uri.http(dotenv.env["HOST_URL"].toString(), endpoint);
  try {
    final response =
        await http.post(url, body: body).timeout(const Duration(milliseconds: 500));
    // print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

dynamic putToApi(String endpoint, Object? body,
    {Map<String, String>? headers}) async {
  var url = Uri.http(dotenv.env["HOST_URL"].toString(), endpoint);
  try {
    final response = await http.put(url, body: body, headers: headers)
        .timeout(const Duration(milliseconds: 500));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body));
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

Widget buildLoadingIndicator(String textToDisplay) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(textToDisplay),
      ],
    ),
  );
}
