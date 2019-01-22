import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' show json;
class PetApi {
  static const String url = "http://100.64.130.40:5000/";
  Future<int> getIsHandRaised(){
    print("Ran is hand Raised");
    return getRawInt(url);
  }
    /// Fetches and decodes a JSON object represented as a Dart [Map].
  /// Returns null if the API server is down, or the response is not JSON.
  Future<int> getRawInt(String url) async {
    try {
      print("Ran GetIntRaw");

      final String responseBody = (await http.get(url)).body;
      print("Request to host returned: $responseBody");
      return int.parse(responseBody);
    } on Exception catch (e) {
      print("did not return int");
      print('$e');
      return null;
    }
  }
  Future<int> getIsHandRaisedLocation(){
    print("Ran is hand Raised");
    return getRawInt(url);
  }
    /// Fetches and decodes a JSON object represented as a Dart [Map].
  /// Returns null if the API server is down, or the response is not JSON.
  Future<int> getRaised(String url) async {
    try {
      print("Ran GetIntRaw");

      final String responseBody = (await http.get(url + "deep")).body;
      print("Request to host returned: $responseBody");
      return int.parse(responseBody);
    } on Exception catch (e) {
      print("did not return int");
      print('$e');
      return null;
    }
  }
    /// Fetches and decodes a JSON object represented as a Dart [Map].
  /// Returns null if the API server is down, or the response is not JSON.
  Future<List<dynamic>> getJson(String url) async {
    try {
      final responseBody = (await http.get(url)).body;
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