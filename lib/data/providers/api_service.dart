import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://localhost:44376/api/Auth";
  static String? jwtToken;

  static Future<String?> login(String documento, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "NumeroDocumento": documento,
        "Password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      jwtToken = data["token"];
      return jwtToken;
    }
    return null;
  }

  static Future<http.Response> getProtectedData(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    return await http.get(
      url,
      headers: {"Authorization": "Bearer $jwtToken"},
    );
  }
}
