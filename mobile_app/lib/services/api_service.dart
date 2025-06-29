import 'package:flutter/foundation.dart';
import 'package:mobile_app/utils/fetchData.dart';
import 'package:mobile_app/services/dataCaching.dart';

/// Service class responsible for fetching information from an API
class ApiService {
  /// Fetches the required data from the API.
  ///
  /// [endpoint] - The endpoint which should be retrieved.
  /// [jsonToLoad] - The local JSON file to load if the API call fails.
  /// Returns the required data in Json format.
  Future<List<dynamic>> fetch(String endpoint, String jsonToLoad) async {
    final cachingService = CachingStorageService();
    final token = await cachingService.getFromCache("token");
    print("################# FETCHING DATA #################");

    if (token == null) {
      if (kDebugMode) {
        print("No token found, loading local JSON: $jsonToLoad");
      }
      return fetchFromJson(jsonToLoad);
    }

    try {
      print("Fetching data from API at endpoint: $endpoint");
      List<dynamic> data = await fetchFromApi(
          '/api/$endpoint',
          headers: {'Authorization': "Bearer " + token.toString()});

      print("################# JSON DATA #################");
      print("jsonData for course ${endpoint}: ${data}");
      if (data.isEmpty) {
        data = await fetchFromJson(jsonToLoad);
      }
      return data;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching from API, loading local JSON: $e");
      }
      return fetchFromJson(jsonToLoad);
    }
  }

  Future<List<dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final cachingService = CachingStorageService();
    final token = await cachingService.getFromCache("token");
    print("################# PUTTING DATA #################");

    if (token == null) {
      if (kDebugMode) {
        print("No token found, cannot put data.");
      }
      return [];
    }

    try {
      print("Putting data to API at endpoint: $endpoint");
      List<dynamic> response = await putToApi(
          '/api/$endpoint',
          data,
          headers: {'Authorization': "Bearer " + token.toString()});

      print("################# PUT RESPONSE #################");
      print("Response for ${endpoint}: ${response}");
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error putting data to API: $e");
      }
      return [];
    }
  }

  Future<List<dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final cachingService = CachingStorageService();
    final token = await cachingService.getFromCache("token");
    print("################# POSTING DATA #################");

    if (token == null) {
      if (kDebugMode) {
        print("No token found, cannot post data.");
      }
      return [];
    }

    try {
      print("Posting data to API at endpoint: $endpoint");
      List<dynamic> response = await postToApi(
          '/api/$endpoint',
          data,
          );

      print("################# POST RESPONSE #################");
      print("Response for ${endpoint}: ${response}");
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error posting data to API: $e");
      }
      return [];
    }
  }
  
}
