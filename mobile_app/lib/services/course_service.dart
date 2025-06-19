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

    if (token == null) {
      if (kDebugMode) {
        print("No token found, loading local JSON: $jsonToLoad");
      }
      return fetchFromJson(jsonToLoad);
    }

    try {
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
}
