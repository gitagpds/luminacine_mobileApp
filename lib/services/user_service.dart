import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const baseUrl =
      "https://luminacine-be-901699795850.us-central1.run.app";

  // ✅ GET /users/:id (butuh token)
  static Future<User> getUserProfile(int idUser, String accessToken) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/$idUser"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final body = jsonDecode(response.body);
    return User.fromJson(body['data']);
  }

  // ✅ POST /users → Register user
  static Future<User> registerUser(Map<String, dynamic> userPayload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userPayload),
    );
    final body = jsonDecode(response.body);
    return User.fromJson(body['data']);
  }

  // ✅ POST /login → Login user
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed");
    }
  }

  // ✅ GET /token → Ambil access token baru (pakai refresh token dari cookie)
  static Future<String> getAccessToken() async {
    final response = await http.get(
      Uri.parse("$baseUrl/token"),
      // Cookie akan otomatis terkirim jika kamu pakai package seperti dio / webview / atau Flutter Web
      headers: {
        'Content-Type': 'application/json',
        // Jika pakai Flutter mobile, kamu mungkin harus atur cookie secara manual tergantung implementasi
      },
    );
    final body = jsonDecode(response.body);
    return body['accessToken']; // Sesuaikan jika respon key-nya beda
  }
}
