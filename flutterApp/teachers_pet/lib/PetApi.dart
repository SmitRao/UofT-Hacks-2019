import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert' show json;
class PetApi {
  static const String url = "localhost:500";
    /// Fetches and decodes a JSON object represented as a Dart [Map].
  /// Returns null if the API server is down, or the response is not JSON.
  Future<int> _getRawInt(String url) async {
    try {
      final String responseBody = (await http.get(url)).body;
              //(limitString != null ? prefixLimit + '=' + (limitString) : '')))
      print("Request to host returned: $responseBody");
      return int.parse(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }

    /// Fetches and decodes a JSON object represented as a Dart [Map].
  /// Returns null if the API server is down, or the response is not JSON.
  Future<List<dynamic>> _getJson(String url) async {
    try {

      final responseBody = (await http.get(url)).body;
              //(limitString != null ? prefixLimit + '=' + (limitString) : '')))
      print(responseBody);
      var decodedJson = json.decode(responseBody);
      if (decodedJson is List<dynamic>)
      {
        return json.decode(responseBody);
      }
      print('Query completed, but return value of wrong type:');
      return List();
      // Finally, the string is parsed into a JSON object.
      
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}